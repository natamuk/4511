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

        Long id = parseLong(request.getParameter("regId"));     
        String source = request.getParameter("source");         
        String diagnosis = request.getParameter("diagnosis");
        String prescription = request.getParameter("prescription");
        String advice = request.getParameter("advice");

        if (id == null) {
            result.put("success", false);
            result.put("message", "Missing record ID");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        if (source == null) source = "REG";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Long registrationId = null;
                Long patientId = null;
                Long doctorId = user.getId();

                if ("REG".equalsIgnoreCase(source)) {
                    registrationId = id;
                    patientId = getPatientIdByRegistration(conn, registrationId);
                    if (patientId == null) throw new Exception("Registration not found");
                } else if ("QUEUE".equalsIgnoreCase(source)) {
                    patientId = getPatientIdByQueue(conn, id);
                    if (patientId == null) throw new Exception("Queue record not found");

                    registrationId = findOrCreateRegistrationForQueue(conn, patientId, doctorId, id);
                } else {
                    throw new Exception("Unknown source type: " + source);
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO consultation (registration_id, patient_id, doctor_id, diagnosis, medical_advice, prescription, consultation_time, status) " +
                                "VALUES (?, ?, ?, ?, ?, ?, NOW(), 2)")) {
                    ps.setLong(1, registrationId);
                    ps.setLong(2, patientId);
                    ps.setLong(3, doctorId);
                    ps.setString(4, diagnosis);
                    ps.setString(5, advice);
                    ps.setString(6, prescription);
                    ps.executeUpdate();
                }

                if ("REG".equalsIgnoreCase(source)) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE registration SET status = 5, update_time = NOW() WHERE id = ? AND doctor_id = ?")) {
                        ps.setLong(1, registrationId);
                        ps.setLong(2, doctorId);
                        ps.executeUpdate();
                    }
                } else if ("QUEUE".equalsIgnoreCase(source)) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE queue SET status = 'completed', updated_time = NOW() WHERE id = ?")) {
                        ps.setLong(1, id);
                        ps.executeUpdate();
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) " +
                                "VALUES (?, 3, ?, ?, 'success', 0, NOW())")) {
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
                e.printStackTrace();
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }

        response.getWriter().write(gson.toJson(result));
    }

    private Long getPatientIdByRegistration(Connection conn, Long registrationId) throws Exception {
        String sql = "SELECT patient_id FROM registration WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong("patient_id");
                return null;
            }
        }
    }

    private Long getPatientIdByQueue(Connection conn, Long queueId) throws Exception {
        String sql = "SELECT patient_id FROM queue WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, queueId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong("patient_id");
                return null;
            }
        }
    }

    private Long findOrCreateRegistrationForQueue(Connection conn, Long patientId, Long doctorId, Long queueId) throws Exception {
        String findSql = "SELECT id FROM registration WHERE patient_id = ? AND doctor_id = ? AND reg_date = CURDATE() AND status IN (1,3,4) LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(findSql)) {
            ps.setLong(1, patientId);
            ps.setLong(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong("id");
            }
        }

        String insertSql = "INSERT INTO registration (reg_no, patient_id, doctor_id, department_id, schedule_id, reg_date, queue_no, fee, status, create_time, update_time) " +
                "VALUES (?, ?, ?, (SELECT department_id FROM doctor WHERE id = ?), NULL, CURDATE(), 0, 0.00, 5, NOW(), NOW())";
        String regNo = "QR-" + System.currentTimeMillis();
        try (PreparedStatement ps = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, regNo);
            ps.setLong(2, patientId);
            ps.setLong(3, doctorId);
            ps.setLong(4, doctorId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
                else throw new Exception("Failed to create registration record");
            }
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