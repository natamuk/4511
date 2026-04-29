/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.dao.PatientDashboardDao;
import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Set;

@WebServlet("/patient/queue/join")
public class PatientQueueJoinServlet extends HttpServlet {

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

        if (clinicId == null) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "clinicId is required");
            return;
        }

        PatientDashboardDao dao = new PatientDashboardDao();
        if (!dao.isWalkinQueueEnabled()) {
            writeJson(response, HttpServletResponse.SC_FORBIDDEN, false, "Walk-in queue is disabled by administrator");
            return;
        }

        Set<Long> allowedClinics = dao.getWalkinEnabledClinicIds();
        if (!allowedClinics.contains(clinicId)) {
            writeJson(response, HttpServletResponse.SC_FORBIDDEN, false, "This clinic does not allow walk-in queue at this time");
            return;
        }

        String checkAlreadyWaitingSql = "SELECT id FROM queue WHERE patient_id = ? AND status = 'waiting' LIMIT 1";
        String nextNoSql = "SELECT COALESCE(MAX(CAST(SUBSTRING(queue_no,10) AS UNSIGNED)), 0) + 1 AS next_no " +
                           "FROM queue WHERE clinic_id = ? AND DATE(created_time) = CURDATE()";
        String insertSql = "INSERT INTO queue (patient_id, doctor_id, clinic_id, queue_no, status, created_time, updated_time) " +
                           "VALUES (?, NULL, ?, ?, 'waiting', NOW(), NOW())";

        String insertNotifSql = "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) VALUES (?, ?, ?, ?, ?, 0, NOW())";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(checkAlreadyWaitingSql)) {
                    ps.setLong(1, patientId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            conn.rollback();
                            writeJson(response, HttpServletResponse.SC_CONFLICT, false, "You already have a waiting queue number");
                            return;
                        }
                    }
                }

                int nextNo = 1;
                try (PreparedStatement ps = conn.prepareStatement(nextNoSql)) {
                    ps.setLong(1, clinicId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) nextNo = rs.getInt("next_no");
                    }
                }

                String queueNo = "Q" + new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date()) +
                                 String.format("%03d", nextNo);

                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setLong(1, patientId);
                    ps.setLong(2, clinicId);
                    ps.setString(3, queueNo);
                    ps.executeUpdate();
                }

                try (PreparedStatement nps = conn.prepareStatement(insertNotifSql)) {
                    String title = "Joined Walk-in Queue";
                    String message = "You joined the walk-in queue: " + queueNo;
                    nps.setLong(1, patientId);
                    nps.setInt(2, 3); 
                    nps.setString(3, title);
                    nps.setString(4, message);
                    nps.setString(5, "success");
                    nps.executeUpdate();
                }

                conn.commit();
                writeJsonWithQueue(response, HttpServletResponse.SC_OK, true, "Queue joined: " + queueNo, queueNo);

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

    private Long parseLong(String v) {
        try { return v == null ? null : Long.parseLong(v); } catch (Exception e) { return null; }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
    }

    private void writeJsonWithQueue(HttpServletResponse response, int status, boolean success, String message, String queueNo) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\",\"queueNo\":\"" + escapeJson(queueNo) + "\"}");
    }

    private String escapeJson(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}