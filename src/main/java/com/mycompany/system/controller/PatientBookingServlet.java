/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/patient/book")
public class PatientBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Unauthorized");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();

        Long clinicId = parseLong(request.getParameter("clinicId"));
        String regDate = request.getParameter("regDate");
        String slotTime = request.getParameter("slotTime");

        if (clinicId == null || isBlank(regDate) || isBlank(slotTime)) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Missing required parameters");
            return;
        }

        Integer timeSlot = resolveTimeSlot(slotTime);
        if (timeSlot == null) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid slotTime");
            return;
        }

        String checkClinicSlotSql =
                "SELECT id, capacity FROM clinic_time_slot " +
                "WHERE clinic_id = ? AND slot_time = ? AND status = 1 " +
                "LIMIT 1 FOR UPDATE";

        String usedClinicSlotSql =
                "SELECT " +
                " (SELECT COUNT(*) FROM queue q WHERE q.clinic_id = ? AND DATE(q.created_time) = ? AND q.status IN ('waiting','called','completed')) + " +
                " (SELECT COUNT(*) FROM registration r " +
                "   JOIN schedule s ON r.schedule_id = s.id " +
                "   WHERE s.clinic_id = ? AND r.reg_date = ? AND s.time_slot = ? AND r.status IN (1,3,4,5)) AS used_count";

        String pickScheduleSql =
                "SELECT s.id AS schedule_id, s.doctor_id, s.department_id, d.register_fee, s.max_count, s.booked_count " +
                "FROM schedule s " +
                "JOIN doctor d ON d.id = s.doctor_id " +
                "WHERE s.schedule_date = ? " +
                "  AND s.time_slot = ? " +
                "  AND s.status = 1 " +
                "  AND d.status = 1 " +
                "ORDER BY (s.max_count - s.booked_count) DESC, s.id ASC " +
                "LIMIT 1 FOR UPDATE";

        String queueNoSql =
                "SELECT COALESCE(MAX(queue_no), 0) + 1 AS next_no " +
                "FROM registration " +
                "WHERE reg_date = ? AND schedule_id = ?";

        String insertSql =
                "INSERT INTO registration " +
                "(reg_no, patient_id, doctor_id, department_id, schedule_id, reg_date, queue_no, fee, status, create_time, update_time) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())";

        String updateScheduleSql =
                "UPDATE schedule SET booked_count = booked_count + 1 WHERE id = ?";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                int clinicCapacity;
                try (PreparedStatement ps = conn.prepareStatement(checkClinicSlotSql)) {
                    ps.setLong(1, clinicId);
                    ps.setString(2, slotTime);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Clinic slot not found");
                            return;
                        }
                        clinicCapacity = rs.getInt("capacity");
                    }
                }

                int used;
                try (PreparedStatement ps = conn.prepareStatement(usedClinicSlotSql)) {
                    ps.setLong(1, clinicId);
                    ps.setString(2, regDate);
                    ps.setLong(3, clinicId);
                    ps.setString(4, regDate);
                    ps.setInt(5, timeSlot);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        used = rs.getInt("used_count");
                    }
                }

                if (used >= clinicCapacity) {
                    conn.rollback();
                    writeJson(response, HttpServletResponse.SC_CONFLICT, false, "This clinic time slot is full");
                    return;
                }

                Long scheduleId;
                Long doctorId;
                Long departmentId;
                double fee;
                int maxCount;
                int bookedCount;

                try (PreparedStatement ps = conn.prepareStatement(pickScheduleSql)) {
                    ps.setString(1, regDate);
                    ps.setInt(2, timeSlot);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "No schedule available");
                            return;
                        }
                        scheduleId = rs.getLong("schedule_id");
                        doctorId = rs.getLong("doctor_id");
                        departmentId = rs.getLong("department_id");
                        fee = rs.getDouble("register_fee");
                        maxCount = rs.getInt("max_count");
                        bookedCount = rs.getInt("booked_count");
                    }
                }

                if (bookedCount >= maxCount) {
                    conn.rollback();
                    writeJson(response, HttpServletResponse.SC_CONFLICT, false, "Doctor schedule is full");
                    return;
                }

                int nextQueueNo = 1;
                try (PreparedStatement ps = conn.prepareStatement(queueNoSql)) {
                    ps.setString(1, regDate);
                    ps.setLong(2, scheduleId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) nextQueueNo = rs.getInt("next_no");
                    }
                }

                String regNo = "REG" + System.currentTimeMillis();
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setString(1, regNo);
                    ps.setLong(2, patientId);
                    ps.setLong(3, doctorId);
                    ps.setLong(4, departmentId);
                    ps.setLong(5, scheduleId);
                    ps.setString(6, regDate);
                    ps.setInt(7, nextQueueNo);
                    ps.setDouble(8, fee);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(updateScheduleSql)) {
                    ps.setLong(1, scheduleId);
                    ps.executeUpdate();
                }

                conn.commit();
                writeJson(response, HttpServletResponse.SC_OK, true, "Booking completed successfully");

            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Server error");
        }
    }

    private Integer resolveTimeSlot(String slotTime) {
        if (slotTime == null) return null;
        if (slotTime.compareTo("09:00") >= 0 && slotTime.compareTo("11:30") <= 0) return 1;
        if (slotTime.compareTo("13:00") >= 0 && slotTime.compareTo("15:30") <= 0) return 2;
        if (slotTime.compareTo("16:00") >= 0 && slotTime.compareTo("17:30") <= 0) return 3;
        return null;
    }

    private Long parseLong(String v) {
        try { return v == null ? null : Long.parseLong(v); } catch (Exception e) { return null; }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
    }

    private String escapeJson(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}