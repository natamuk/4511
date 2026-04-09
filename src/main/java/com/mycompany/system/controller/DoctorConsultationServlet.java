/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/consultation")
public class DoctorConsultationServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
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

        Long regId = parseLong(request.getParameter("regId"));
        String diagnosis = request.getParameter("diagnosis");
        String prescription = request.getParameter("prescription");
        String advice = request.getParameter("advice");

        if (regId == null) {
            result.put("success", false);
            result.put("message", "Missing regId");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Long patientId = null;
                Long doctorId = user.getId();

                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT patient_id FROM registration WHERE id = ? AND doctor_id = ?")) {
                    ps.setLong(1, regId);
                    ps.setLong(2, doctorId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            patientId = rs.getLong("patient_id");
                        } else {
                            throw new Exception("Registration not found");
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO consultation (registration_id, patient_id, doctor_id, diagnosis, medical_advice, prescription, consultation_time, status) " +
                                "VALUES (?, ?, ?, ?, ?, ?, NOW(), 2)")) {
                    ps.setLong(1, regId);
                    ps.setLong(2, patientId);
                    ps.setLong(3, doctorId);
                    ps.setString(4, diagnosis);
                    ps.setString(5, advice);
                    ps.setString(6, prescription);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE registration SET status = 5, update_time = NOW() WHERE id = ? AND doctor_id = ?")) {
                    ps.setLong(1, regId);
                    ps.setLong(2, doctorId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) VALUES (?, 3, ?, ?, 'success', 0, NOW())")) {
                    ps.setLong(1, patientId);
                    ps.setString(2, "Consultation Completed");
                    ps.setString(3, "Your consultation has been completed. Please check your prescription.");
                    ps.executeUpdate();
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

    private Long parseLong(String v) {
        try {
            return v == null ? null : Long.parseLong(v);
        } catch (Exception e) {
            return null;
        }
    }
}