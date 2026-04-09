/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/action")
public class DoctorActionServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession();
        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        if (user == null || !"doctor".equals(session.getAttribute("role"))) {
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String action = request.getParameter("action");
        Long id = parseLong(request.getParameter("id"));
        Long statusParam = parseLong(request.getParameter("status"));
        String sourceType = request.getParameter("sourceType"); // 新增：判斷來源

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if ("approve".equals(action)) {
                    approveRegistration(conn, user.getId(), id);
                    writeNotification(conn, getPatientIdByRegistration(conn, id), "Appointment Approved", "Your appointment has been approved.", "success");
                } else if ("reject".equals(action)) {
                    Long patientId = getPatientIdByRegistration(conn, id);
                    rejectRegistration(conn, user.getId(), id);
                    writeNotification(conn, patientId, "Appointment Rejected", "Your appointment has been rejected.", "warning");
                } else if ("update".equals(action)) {
                    if (statusParam == null) throw new IllegalArgumentException("Missing status");
                    updateStatus(conn, user.getId(), id, sourceType, statusParam.intValue());
                } else if ("skip".equals(action)) {
                    skipBySource(conn, user.getId(), id, sourceType);
                } else if ("callNext".equals(action)) {
                    callNext(conn, user.getId());
                } else {
                    throw new IllegalArgumentException("Unknown action");
                }

                conn.commit();
                result.put("success", true);
            } catch (Exception e) {
                conn.rollback();
                result.put("success", false);
                result.put("message", e.getMessage());
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        response.getWriter().write(gson.toJson(result));
    }

    private void approveRegistration(Connection conn, Long doctorId, Long regId) throws Exception {
        String sql = "UPDATE registration SET status = 3, call_time = NOW(), update_time = NOW() WHERE id = ? AND doctor_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, regId); ps.setLong(2, doctorId);
            if (ps.executeUpdate() == 0) throw new Exception("Appointment not found");
        }
    }

    private void rejectRegistration(Connection conn, Long doctorId, Long regId) throws Exception {
        String findSql = "SELECT schedule_id FROM registration WHERE id = ? AND doctor_id = ?";
        Long scheduleId = null;
        try (PreparedStatement ps = conn.prepareStatement(findSql)) {
            ps.setLong(1, regId); ps.setLong(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) scheduleId = rs.getLong("schedule_id");
            }
        }
        try (PreparedStatement ps = conn.prepareStatement("UPDATE registration SET status = 2, cancel_time = NOW(), update_time = NOW() WHERE id = ?")) {
            ps.setLong(1, regId);
            ps.executeUpdate();
        }
    }

    private void updateStatus(Connection conn, Long doctorId, Long id, String sourceType, int status) throws Exception {
        if ("QUEUE".equalsIgnoreCase(sourceType)) {
            String qStatus = status == 3 ? "called" : (status == 4 ? "consulting" : "completed");
            try (PreparedStatement ps = conn.prepareStatement("UPDATE queue SET status = ?, updated_time = NOW() WHERE id = ?")) {
                ps.setString(1, qStatus); ps.setLong(2, id);
                if (ps.executeUpdate() == 0) throw new Exception("Queue record not found");
            }
        } else {
            try (PreparedStatement ps = conn.prepareStatement("UPDATE registration SET status = ?, update_time = NOW() WHERE id = ? AND doctor_id = ?")) {
                ps.setInt(1, status); ps.setLong(2, id); ps.setLong(3, doctorId);
                if (ps.executeUpdate() == 0) throw new Exception("Registration not found");
            }
        }
    }

    // 修正：依照來源精確更新，避免 ID 碰撞，並發送通知
    private void skipBySource(Connection conn, Long doctorId, Long id, String sourceType) throws Exception {
        if ("QUEUE".equalsIgnoreCase(sourceType)) {
            try (PreparedStatement ps = conn.prepareStatement("UPDATE queue SET status = 'skipped', updated_time = NOW() WHERE id = ?")) {
                ps.setLong(1, id);
                if (ps.executeUpdate() == 0) throw new Exception("Queue not found");
            }
        } else {
            try (PreparedStatement ps = conn.prepareStatement("UPDATE registration SET status = 6, update_time = NOW() WHERE id = ? AND doctor_id = ?")) {
                ps.setLong(1, id); ps.setLong(2, doctorId);
                if (ps.executeUpdate() == 0) throw new Exception("Registration not found");
            }
            Long patientId = getPatientIdByRegistration(conn, id);
            writeNotification(conn, patientId, "Turn Skipped", "You missed your turn and have been skipped.", "warning");
        }
    }

    // 修正：綜合排序後叫號，並發送通知
    private void callNext(Connection conn, Long doctorId) throws Exception {
        Long regId = null, queueId = null;
        try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM registration WHERE doctor_id = ? AND status = 1 AND reg_date = CURDATE() ORDER BY queue_no ASC LIMIT 1")) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) regId = rs.getLong("id"); }
        }
        // 如果預約名單為空，才找現場排隊
        if (regId != null) {
            try (PreparedStatement ps = conn.prepareStatement("UPDATE registration SET status = 3, call_time = NOW(), update_time = NOW() WHERE id = ?")) {
                ps.setLong(1, regId); ps.executeUpdate();
            }
            writeNotification(conn, getPatientIdByRegistration(conn, regId), "Please enter", "It is your turn for consultation.", "info");
            return;
        }

        try (PreparedStatement ps = conn.prepareStatement("SELECT id, patient_id FROM queue WHERE (doctor_id = ? OR doctor_id IS NULL) AND status = 'waiting' AND DATE(created_time) = CURDATE() ORDER BY created_time ASC LIMIT 1")) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    queueId = rs.getLong("id");
                    writeNotification(conn, rs.getLong("patient_id"), "Please enter", "It is your turn for consultation.", "info");
                }
            }
        }
        if (queueId != null) {
            try (PreparedStatement ps = conn.prepareStatement("UPDATE queue SET status = 'called', called_time = NOW(), updated_time = NOW() WHERE id = ?")) {
                ps.setLong(1, queueId); ps.executeUpdate();
            }
            return;
        }
        throw new Exception("No waiting patients.");
    }

    private Long getPatientIdByRegistration(Connection conn, Long regId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("SELECT patient_id FROM registration WHERE id = ?")) {
            ps.setLong(1, regId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getLong("patient_id"); }
        }
        return null;
    }

    private void writeNotification(Connection conn, Long patientId, String title, String message, String type) throws Exception {
        if (patientId == null) return;
        try (PreparedStatement ps = conn.prepareStatement("INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) VALUES (?, 3, ?, ?, ?, 0, NOW())")) {
            ps.setLong(1, patientId); ps.setString(2, title); ps.setString(3, message); ps.setString(4, type);
            ps.executeUpdate();
        }
    }

    private Long parseLong(String v) {
        try { return v == null ? null : Long.parseLong(v); } catch (Exception e) { return null; }
    }
}