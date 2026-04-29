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

@WebServlet("/patient/toggle-favorite")
public class PatientToggleFavoriteServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            writeJson(response, 401, false, "Unauthorized");
            return;
        }

        Long patientId = ((LoginUser) session.getAttribute("loginUser")).getId();
        Long clinicId = parseLong(request.getParameter("clinicId"));

        if (clinicId == null) {
            writeJson(response, 400, false, "Clinic ID required");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM patient_favorite_clinic WHERE patient_id = ? AND clinic_id = ?")) {
                ps.setLong(1, patientId);
                ps.setLong(2, clinicId);
                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM patient_favorite_clinic WHERE patient_id = ? AND clinic_id = ?")) {
                    ps.setLong(1, patientId);
                    ps.setLong(2, clinicId);
                    ps.executeUpdate();
                }
                writeJson(response, 200, true, "Removed from favorites");
            } else {
                try (PreparedStatement ps = conn.prepareStatement("INSERT INTO patient_favorite_clinic (patient_id, clinic_id) VALUES (?, ?)")) {
                    ps.setLong(1, patientId);
                    ps.setLong(2, clinicId);
                    ps.executeUpdate();
                }
                writeJson(response, 200, true, "Added to favorites");
            }
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