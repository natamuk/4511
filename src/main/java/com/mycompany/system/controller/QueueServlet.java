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

@WebServlet("/patient/join-queue")
public class QueueServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Unauthorized");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();
        Long clinicId = parseLong(request.getParameter("clinicId"));

        if (clinicId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing clinicId");
            return;
        }

        String checkSql =
                "SELECT id FROM queue WHERE patient_id = ? AND clinic_id = ? AND status = 'waiting'";

        String maxSql =
                "SELECT COALESCE(MAX(CAST(queue_no AS UNSIGNED)), 0) + 1 AS next_no FROM queue WHERE clinic_id = ?";

        String insertSql =
                "INSERT INTO queue (patient_id, clinic_id, queue_no, status, created_time, updated_time) " +
                "VALUES (?, ?, ?, 'waiting', NOW(), NOW())";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setLong(1, patientId);
                    ps.setLong(2, clinicId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            conn.rollback();
                            response.setStatus(HttpServletResponse.SC_CONFLICT);
                            response.getWriter().write("You are already in queue");
                            return;
                        }
                    }
                }

                int nextNo = 1;
                try (PreparedStatement ps = conn.prepareStatement(maxSql)) {
                    ps.setLong(1, clinicId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) nextNo = rs.getInt("next_no");
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setLong(1, patientId);
                    ps.setLong(2, clinicId);
                    ps.setString(3, String.valueOf(nextNo));
                    ps.executeUpdate();
                }

                conn.commit();
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":true,\"message\":\"Joined queue successfully\"}");

            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Server error");
        }
    }

    private Long parseLong(String v) {
        try {
            return v == null ? null : Long.parseLong(v);
        } catch (Exception e) {
            return null;
        }
    }
}