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

@WebServlet("/patient/cancel-booking")
public class PatientCancelBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            writeJson(response, 401, false, "Unauthorized");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();
        Long registrationId = parseLong(request.getParameter("registrationId"));

        if (registrationId == null) {
            writeJson(response, 400, false, "Missing registrationId");
            return;
        }

        String checkSql = "SELECT r.schedule_id, r.status, s.clinic_id FROM registration r JOIN schedule s ON r.schedule_id = s.id WHERE r.id = ? AND r.patient_id = ?";
        String updateRegSql = "UPDATE registration SET status = 2, cancel_time = NOW(), update_time = NOW() WHERE id = ?";
        String updateScheduleSql = "UPDATE schedule SET booked_count = GREATEST(booked_count - 1, 0) WHERE id = ?";
        String updateQueueSql = "UPDATE queue SET status = 'skipped', updated_time = NOW() WHERE patient_id = ? AND clinic_id = ? AND status = 'waiting'";
        String insertNotificationSql = "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) VALUES (?, 3, ?, ?, 'warning', 0, NOW())";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            Long scheduleId = null;
            Long clinicId = null;
            int status = 0;

            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setLong(1, registrationId);
                ps.setLong(2, patientId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        writeJson(response, 404, false, "Booking not found");
                        return;
                    }
                    scheduleId = rs.getLong("schedule_id");
                    clinicId = rs.getLong("clinic_id");
                    status = rs.getInt("status");
                }
            }

            if (status != 1) {
                conn.rollback();
                writeJson(response, 409, false, "Only booked appointments can be cancelled");
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement(updateRegSql)) {
                ps.setLong(1, registrationId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(updateScheduleSql)) {
                ps.setLong(1, scheduleId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(updateQueueSql)) {
                ps.setLong(1, patientId);
                ps.setLong(2, clinicId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(insertNotificationSql)) {
                ps.setLong(1, patientId);
                ps.setString(2, "Appointment Cancelled");
                ps.setString(3, "Your appointment has been cancelled successfully.");
                ps.executeUpdate();
            }

            conn.commit();
            writeJson(response, 200, true, "Booking cancelled successfully");

        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, 500, false, "Server error");
        }
    }

    private Long parseLong(String v) {
        try { return Long.parseLong(v); } catch (Exception e) { return null; }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}