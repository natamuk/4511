package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

public class PatientBookingLogic {

    public void handleBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Connection conn = null;
        try {
            // 1. 权限校验
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("loginUser") == null ||
                    !"patient".equals(session.getAttribute("role"))) {
                writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Unauthorized");
                return;
            }

            LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
            Long patientId = loginUser.getId();

            // 2. 获取参数
            Long clinicId = parseLong(request.getParameter("clinicId"));
            String regDate = request.getParameter("regDate");
            String slotTime = request.getParameter("slotTime");

            if (clinicId == null || regDate == null || regDate.trim().isEmpty() ||
                    slotTime == null || slotTime.trim().isEmpty()) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Missing required parameters");
                return;
            }

            try {
                LocalDate.parse(regDate);
            } catch (DateTimeParseException e) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid regDate format (required: yyyy-MM-dd)");
                return;
            }

            int timeSlot = resolveTimeSlot(slotTime);
            if (timeSlot == -1) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid slotTime");
                return;
            }

            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 3. 校验诊所时段容量（使用 registration.slot_time）
            if (!checkClinicSlotCapacity(conn, clinicId, regDate, slotTime, response)) {
                return;
            }

            // 4. 获取该诊所对应的医生（必须包含 department_id）
            DoctorInfo doctorInfo = getDoctorByClinic(conn, clinicId, response);
            if (doctorInfo == null) {
                return;
            }

            // 5. 生成排队号（按诊所+日期）
            int nextQueueNo = getNextQueueNoForClinic(conn, regDate, clinicId);
            if (nextQueueNo == -1) {
                rollback(conn);
                writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Failed to generate queue number");
                return;
            }

            // 6. 插入预约记录（务必包含 department_id, slot_time, clinic_id）
            String regNo = "REG" + System.currentTimeMillis();
            if (!insertRegistration(conn, regNo, patientId, clinicId, doctorInfo, regDate, nextQueueNo, slotTime, response)) {
                return;
            }

            // 7. 插入通知（不扣费）
            insertSuccessNotification(conn, patientId, regNo, regDate);

            conn.commit();
            writeJson(response, HttpServletResponse.SC_OK, true, "Booking completed successfully");

        } catch (Exception e) {
            e.printStackTrace();
            rollback(conn);
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Server error: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // 校验诊所时段容量（基于 clinic_time_slot 和 registration 的 slot_time 列）
    private boolean checkClinicSlotCapacity(Connection conn, Long clinicId, String regDate, String slotTime, HttpServletResponse response) throws SQLException, IOException {
        String sql = "SELECT cts.capacity, " +
                "(SELECT COUNT(*) FROM registration r " +
                " WHERE r.clinic_id = ? AND r.reg_date = ? AND r.slot_time = ? " +
                " AND r.status IN (1,3,4,5)) AS booked_count " +
                "FROM clinic_time_slot cts " +
                "WHERE cts.clinic_id = ? AND cts.slot_time = ? AND cts.status = 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, clinicId);
            ps.setString(2, regDate);
            ps.setString(3, slotTime);
            ps.setLong(4, clinicId);
            ps.setString(5, slotTime);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    rollback(conn);
                    writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Clinic slot not available");
                    return false;
                }
                int capacity = rs.getInt("capacity");
                int bookedCount = rs.getInt("booked_count");
                if (bookedCount >= capacity) {
                    rollback(conn);
                    writeJson(response, HttpServletResponse.SC_CONFLICT, false, "This time slot is full");
                    return false;
                }
            }
        }
        return true;
    }

    // 获取诊所固定医生（必须包含 department_id）
    private DoctorInfo getDoctorByClinic(Connection conn, Long clinicId, HttpServletResponse response) throws SQLException, IOException {
        String sql = "SELECT id, register_fee, department_id FROM doctor WHERE primary_clinic_id = ? AND status = 1 LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, clinicId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    rollback(conn);
                    writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "No doctor assigned to this clinic");
                    return null;
                }
                long doctorId = rs.getLong("id");
                double fee = rs.getDouble("register_fee");
                long departmentId = rs.getLong("department_id");
                // 如果 departmentId 为 0（理论上不会，因为 doctor 表 department_id NOT NULL），则使用默认科室 1
                if (departmentId == 0) {
                    departmentId = 1;
                }
                return new DoctorInfo(doctorId, fee, departmentId);
            }
        }
    }

    // 生成排队号（按诊所+日期）
    private int getNextQueueNoForClinic(Connection conn, String regDate, Long clinicId) throws SQLException {
        String sql = "SELECT COALESCE(MAX(queue_no), 0) + 1 FROM registration WHERE reg_date = ? AND clinic_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, regDate);
            ps.setLong(2, clinicId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 1;
    }

    // 插入预约记录（明确提供所有 NOT NULL 字段）
    private boolean insertRegistration(Connection conn, String regNo, Long patientId, Long clinicId,
                                       DoctorInfo doctorInfo, String regDate, int queueNo,
                                       String slotTime, HttpServletResponse response) throws SQLException, IOException {
        // 注意：department_id 从 doctorInfo 获取，不能为 NULL
        String sql = "INSERT INTO registration (reg_no, patient_id, clinic_id, doctor_id, department_id, reg_date, queue_no, fee, slot_time, status, create_time, update_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, regNo);
            ps.setLong(2, patientId);
            ps.setLong(3, clinicId);
            ps.setLong(4, doctorInfo.getDoctorId());
            ps.setLong(5, doctorInfo.getDepartmentId());   // 关键：必须非 NULL
            ps.setString(6, regDate);
            ps.setInt(7, queueNo);
            ps.setDouble(8, doctorInfo.getFee());
            ps.setString(9, slotTime);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            rollback(conn);
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Failed to create booking: " + e.getMessage());
            return false;
        }
    }

    private void insertSuccessNotification(Connection conn, Long patientId, String regNo, String regDate) throws SQLException {
        String sql = "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) " +
                "VALUES (?, 3, ?, ?, 'success', 0, NOW())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, patientId);
            ps.setString(2, "Booking Confirmed");
            ps.setString(3, "Your booking " + regNo + " on " + regDate + " has been confirmed.");
            ps.executeUpdate();
        }
    }

    private Long parseLong(String v) {
        try { return v == null ? null : Long.parseLong(v); } catch (NumberFormatException e) { return null; }
    }

    private int resolveTimeSlot(String slotTime) {
        try {
            LocalTime t = LocalTime.parse(slotTime);
            if (t.compareTo(LocalTime.of(9, 0)) >= 0 && t.compareTo(LocalTime.of(11, 30)) <= 0) return 1;
            if (t.compareTo(LocalTime.of(13, 0)) >= 0 && t.compareTo(LocalTime.of(15, 30)) <= 0) return 2;
            if (t.compareTo(LocalTime.of(16, 0)) >= 0 && t.compareTo(LocalTime.of(17, 30)) <= 0) return 3;
        } catch (Exception ignored) {}
        return -1;
    }

    private void rollback(Connection conn) {
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        String json = String.format("{\"success\":%b,\"message\":\"%s\"}", success, message.replace("\"", "\\\""));
        response.getWriter().write(json);
    }

    // 内部类封装医生信息
    private static class DoctorInfo {
        private final Long doctorId;
        private final double fee;
        private final Long departmentId;
        public DoctorInfo(Long doctorId, double fee, Long departmentId) {
            this.doctorId = doctorId;
            this.fee = fee;
            this.departmentId = departmentId;
        }
        public Long getDoctorId() { return doctorId; }
        public double getFee() { return fee; }
        public Long getDepartmentId() { return departmentId; }
    }
}