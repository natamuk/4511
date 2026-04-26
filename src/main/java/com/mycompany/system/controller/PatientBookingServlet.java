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
import java.time.LocalTime;

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

        if (clinicId == null || regDate == null || regDate.trim().isEmpty() || slotTime == null || slotTime.trim().isEmpty()) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Missing required parameters");
            return;
        }

        int timeSlot = resolveTimeSlot(slotTime);
        if (timeSlot == -1) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid slotTime");
            return;
        }

        String checkClinicSlotCapacitySql =
            "SELECT cts.capacity, " +
            "(SELECT COUNT(*) FROM registration r " +
            " JOIN schedule s ON r.schedule_id = s.id " +
            " WHERE s.clinic_id = ? AND r.reg_date = ? AND s.time_slot = ? " +
            " AND r.status IN (1,3,4,5)) AS booked_count " +
            "FROM clinic_time_slot cts " +
            "WHERE cts.clinic_id = ? AND cts.slot_time = ? AND cts.status = 1";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            int capacity = 0;
            int bookedCount = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkClinicSlotCapacitySql)) {
                ps.setLong(1, clinicId);
                ps.setString(2, regDate);
                ps.setInt(3, timeSlot);
                ps.setLong(4, clinicId);
                ps.setString(5, slotTime);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Clinic slot not available");
                        return;
                    }
                    capacity = rs.getInt("capacity");
                    bookedCount = rs.getInt("booked_count");
                }
            }

            if (bookedCount >= capacity) {
                conn.rollback();
                writeJson(response, HttpServletResponse.SC_CONFLICT, false, "This time slot is full");
                return;
            }

            String pickScheduleSql =
                "SELECT s.id AS schedule_id, s.doctor_id, s.department_id, d.register_fee, s.max_count, s.booked_count " +
                "FROM schedule s " +
                "JOIN doctor d ON d.id = s.doctor_id " +
                "WHERE s.schedule_date = ? " +
                "  AND s.time_slot = ? " +
                "  AND s.clinic_id = ? " +
                "  AND s.status = 1 " +
                "  AND d.status = 1 " +
                "ORDER BY (s.max_count - s.booked_count) DESC, s.id ASC " +
                "LIMIT 1 FOR UPDATE";

            Long scheduleId = null;
            Long doctorId = null;
            Long departmentId = null;
            double fee = 0;
            int maxCount = 0;
            int currentBooked = 0;
            try (PreparedStatement ps = conn.prepareStatement(pickScheduleSql)) {
                ps.setString(1, regDate);
                ps.setInt(2, timeSlot);
                ps.setLong(3, clinicId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "No doctor available for this clinic and time");
                        return;
                    }
                    scheduleId = rs.getLong("schedule_id");
                    doctorId = rs.getLong("doctor_id");
                    departmentId = rs.getLong("department_id");
                    fee = rs.getDouble("register_fee");
                    maxCount = rs.getInt("max_count");
                    currentBooked = rs.getInt("booked_count");
                }
            }

            if (currentBooked >= maxCount) {
                conn.rollback();
                writeJson(response, HttpServletResponse.SC_CONFLICT, false, "Doctor schedule is full");
                return;
            }

            String queueNoSql = "SELECT COALESCE(MAX(queue_no), 0) + 1 FROM registration WHERE reg_date = ? AND schedule_id = ?";
            int nextQueueNo = 1;
            try (PreparedStatement ps = conn.prepareStatement(queueNoSql)) {
                ps.setString(1, regDate);
                ps.setLong(2, scheduleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) nextQueueNo = rs.getInt(1);
                }
            }

            String insertSql = "INSERT INTO registration (reg_no, patient_id, doctor_id, department_id, schedule_id, reg_date, queue_no, fee, status, create_time, update_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())";
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

            String updateScheduleSql = "UPDATE schedule SET booked_count = booked_count + 1 WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateScheduleSql)) {
                ps.setLong(1, scheduleId);
                ps.executeUpdate();
            }

            String deductSql = "UPDATE patient SET balance = balance - ? WHERE id = ? AND balance >= ?";
            try (PreparedStatement ps = conn.prepareStatement(deductSql)) {
                ps.setDouble(1, fee);
                ps.setLong(2, patientId);
                ps.setDouble(3, fee);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    writeJson(response, HttpServletResponse.SC_PAYMENT_REQUIRED, false, "Insufficient balance");
                    return;
                }
            }

            // Insert user notification for booking success (so user will see personal notification)
            String insertNotifSql = "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) VALUES (?, 3, ?, ?, 'success', 0, NOW())";
            try (PreparedStatement ps = conn.prepareStatement(insertNotifSql)) {
                ps.setLong(1, patientId);
                ps.setString(2, "Booking Confirmed");
                ps.setString(3, "Your booking " + regNo + " on " + regDate + " has been confirmed.");
                ps.executeUpdate();
            }

            conn.commit();
            writeJson(response, HttpServletResponse.SC_OK, true, "Booking completed successfully");

        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Server error");
        }
    }

    private int resolveTimeSlot(String slotTime) {
        try {
            LocalTime t = LocalTime.parse(slotTime);
            if (!t.isBefore(LocalTime.of(9, 0)) && !t.isAfter(LocalTime.of(11, 30))) return 1;
            if (!t.isBefore(LocalTime.of(13, 0)) && !t.isAfter(LocalTime.of(15, 30))) return 2;
            if (!t.isBefore(LocalTime.of(16, 0)) && !t.isAfter(LocalTime.of(17, 30))) return 3;
        } catch (Exception ignored) {}
        return -1;
    }

    private Long parseLong(String v) {
        try { return v == null ? null : Long.parseLong(v); } catch (Exception e) { return null; }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}