package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/patient/reschedule")
public class PatientRescheduleServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        Map<String, Object> result = new HashMap<>();

        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        Long patientId = user.getId();
        Long registrationId = parseLong(request.getParameter("registrationId"));
        String newDate = request.getParameter("newDate");
        String newSlot = request.getParameter("newSlot");

        if (registrationId == null || newDate == null || newSlot == null) {
            result.put("success", false);
            result.put("message", "Missing parameters");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            String checkSql = "SELECT clinic_id, doctor_id, department_id, status FROM registration WHERE id = ? AND patient_id = ?";
            Long clinicId = null;
            int status = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setLong(1, registrationId);
                ps.setLong(2, patientId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        clinicId = rs.getLong("clinic_id");
                        status = rs.getInt("status");
                    } else {
                        result.put("success", false);
                        result.put("message", "Appointment not found");
                        response.getWriter().write(gson.toJson(result));
                        return;
                    }
                }
            }
            if (status != 1) {
                result.put("success", false);
                result.put("message", "Only booked appointments can be rescheduled");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            String checkSlotSql = "SELECT cts.capacity, COUNT(r.id) AS booked FROM clinic_time_slot cts " +
                    "LEFT JOIN registration r ON cts.clinic_id = r.clinic_id AND cts.slot_time = r.slot_time AND r.reg_date = ? " +
                    "AND r.status NOT IN (2,6) " +
                    "WHERE cts.clinic_id = ? AND cts.slot_time = ? AND cts.status = 1";
            int capacity = 0;
            int booked = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkSlotSql)) {
                ps.setString(1, newDate);
                ps.setLong(2, clinicId);
                ps.setString(3, newSlot);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        capacity = rs.getInt("capacity");
                        booked = rs.getInt("booked");
                    } else {
                        result.put("success", false);
                        result.put("message", "Invalid time slot");
                        response.getWriter().write(gson.toJson(result));
                        return;
                    }
                }
            }
            if (capacity - booked <= 0) {
                result.put("success", false);
                result.put("message", "Selected time slot is fully booked");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            String updateSql = "UPDATE registration SET reg_date = ?, slot_time = ?, update_time = NOW() WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newDate);
                ps.setString(2, newSlot);
                ps.setLong(3, registrationId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    result.put("success", true);
                    result.put("message", "Appointment rescheduled successfully");
                } else {
                    result.put("success", false);
                    result.put("message", "Failed to reschedule");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
        }
        response.getWriter().write(gson.toJson(result));
    }

    private Long parseLong(String v) {
        try { return v == null ? null : Long.parseLong(v); } catch (Exception e) { return null; }
    }
}