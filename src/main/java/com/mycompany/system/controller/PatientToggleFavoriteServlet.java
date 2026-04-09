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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

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
        String clinicName = request.getParameter("clinicName");

        if (clinicName == null || clinicName.trim().isEmpty()) {
            writeJson(response, 400, false, "Clinic name required");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM patient_favorite_clinic WHERE patient_id = ? AND clinic_name = ?")) {
                ps.setLong(1, patientId);
                ps.setString(2, clinicName);
                ResultSet rs = ps.executeQuery();
                exists = rs.next();
            }

            if (exists) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM patient_favorite_clinic WHERE patient_id = ? AND clinic_name = ?")) {
                    ps.setLong(1, patientId);
                    ps.setString(2, clinicName);
                    ps.executeUpdate();
                }
                writeJson(response, 200, true, "Removed from favorites");
            } else {
                try (PreparedStatement ps = conn.prepareStatement("INSERT INTO patient_favorite_clinic (patient_id, clinic_name) VALUES (?, ?)")) {
                    ps.setLong(1, patientId);
                    ps.setString(2, clinicName);
                    ps.executeUpdate();
                }
                writeJson(response, 200, true, "Added to favorites");
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, 500, false, "Server error");
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}