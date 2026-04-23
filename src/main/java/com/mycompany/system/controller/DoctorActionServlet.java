/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
// DoctorActionServlet.java（替換現有檔案）
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
        // 基本回傳結構
        Map<String, Object> result = new HashMap<>();
        boolean success = false;
        String message = null;

        HttpSession session = request.getSession(false);
        LoginUser user = session == null ? null : (LoginUser) session.getAttribute("loginUser");
        if (user == null || session == null || !"doctor".equals(session.getAttribute("role"))) {
            message = "Unauthorized";
            respond(request, response, false, message, HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        Long id = parseLong(request.getParameter("id"));
        Long statusParam = parseLong(request.getParameter("status"));
        String sourceType = request.getParameter("sourceType"); // optional

        if (action == null || id == null) {
            message = "Missing parameters";
            respond(request, response, false, message, HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if ("approve".equalsIgnoreCase(action)) {
                    approveRegistration(conn, user.getId(), id);
                    Long patientId = getPatientIdByRegistration(conn, id);
                    writeNotification(conn, patientId, "Appointment Approved", "Your appointment has been approved.", "success");
                    success = true;
                } else if ("reject".equalsIgnoreCase(action)) {
                    Long patientId = getPatientIdByRegistration(conn, id);
                    rejectRegistration(conn, user.getId(), id);
                    writeNotification(conn, patientId, "Appointment Rejected", "Your appointment has been rejected.", "warning");
                    success = true;
                } else if ("update".equalsIgnoreCase(action)) {
                    if (statusParam == null) throw new IllegalArgumentException("Missing status");
                    updateStatus(conn, user.getId(), id, sourceType, statusParam.intValue());
                    success = true;
                } else if ("skip".equalsIgnoreCase(action)) {
                    skipBySource(conn, user.getId(), id, sourceType);
                    success = true;
                } else if ("callNext".equalsIgnoreCase(action)) {
                    callNext(conn, user.getId());
                    success = true;
                } else {
                    throw new IllegalArgumentException("Unknown action");
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                message = e.getMessage();
                success = false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
            success = false;
        }

        // 最後回應：若為 AJAX -> JSON；否則放 flash 並 redirect 回 referer
        respond(request, response, success, message, HttpServletResponse.SC_OK);
    }

    // 判斷並回應（JSON 或 redirect）
    private void respond(HttpServletRequest request, HttpServletResponse response, boolean success, String message, int successStatus) throws IOException {
        // 判斷是否為 AJAX
        String ajaxHeader = request.getHeader("X-Requested-With");
        String accept = request.getHeader("Accept");
        boolean wantsJson = (ajaxHeader != null && "XMLHttpRequest".equalsIgnoreCase(ajaxHeader))
                || (accept != null && accept.contains("application/json"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"));

        if (wantsJson) {
            response.setContentType("application/json;charset=UTF-8");
            response.setStatus(success ? successStatus : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> r = new HashMap<>();
            r.put("success", success);
            if (!success) r.put("message", message == null ? "Operation failed" : message);
            response.getWriter().write(gson.toJson(r));
        } else {
            // 同步表單：使用 flash message 並 redirect 回 referer（沒有 referer 則導到 dashboard）
            HttpSession session = request.getSession(true);
            if (success) session.setAttribute("flash_success", "Operation succeeded");
            else session.setAttribute("flash_error", message == null ? "Operation failed" : message);

            String referer = request.getHeader("Referer");
            if (referer == null || referer.isBlank()) {
                // fallback 頁面：醫生 dashboard
                response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
            } else {
                response.sendRedirect(referer);
            }
        }
    }

    // 以下為原有業務邏輯函式（我保留你的實作，若你已有其他邏輯可替換）
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

    private void callNext(Connection conn, Long doctorId) throws Exception {
        Long regId = null, queueId = null;
        try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM registration WHERE doctor_id = ? AND status = 1 AND reg_date = CURDATE() ORDER BY queue_no ASC LIMIT 1")) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) regId = rs.getLong("id"); }
        }
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