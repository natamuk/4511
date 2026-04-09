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
import java.time.LocalTime;

@WebServlet("/patient/reschedule-booking")
public class PatientRescheduleBookingServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null || !"patient".equals(session.getAttribute("role"))) {
            writeJson(response, 401, false, "Unauthorized");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();

        Long regId = parseLong(request.getParameter("registrationId"));
        String newDate = request.getParameter("newDate");
        String newTime = request.getParameter("newTime");

        if (regId == null || newDate == null || newTime == null) {
            writeJson(response, 400, false, "Missing parameters");
            return;
        }

        int timeSlot = resolveTimeSlot(newTime);
        if (timeSlot == 0) {
            writeJson(response, 400, false, "Invalid time slot");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Long oldScheduleId;
                Long doctorId;

                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT schedule_id, doctor_id, status FROM registration WHERE id = ? AND patient_id = ?")) {
                    ps.setLong(1, regId);
                    ps.setLong(2, patientId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || rs.getInt("status") != 1) {
                            writeJson(response, 400, false, "Invalid booking or cannot be rescheduled");
                            return;
                        }
                        oldScheduleId = rs.getLong("schedule_id");
                        doctorId = rs.getLong("doctor_id");
                    }
                }

                Long newScheduleId = null;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT id FROM schedule WHERE doctor_id = ? AND schedule_date = ? AND time_slot = ? AND booked_count < max_count LIMIT 1")) {
                    ps.setLong(1, doctorId);
                    ps.setString(2, newDate);
                    ps.setInt(3, timeSlot);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            newScheduleId = rs.getLong("id");
                        } else {
                            writeJson(response, 400, false, "The selected time slot is full or unavailable.");
                            return;
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement("UPDATE schedule SET booked_count = booked_count - 1 WHERE id = ?")) {
                    ps.setLong(1, oldScheduleId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement("UPDATE schedule SET booked_count = booked_count + 1 WHERE id = ?")) {
                    ps.setLong(1, newScheduleId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE registration SET schedule_id = ?, reg_date = ?, update_time = NOW() WHERE id = ?")) {
                    ps.setLong(1, newScheduleId);
                    ps.setString(2, newDate);
                    ps.setLong(3, regId);
                    ps.executeUpdate();
                }

                conn.commit();
                writeJson(response, 200, true, "Rescheduled successfully");
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, 500, false, "Server error");
        }
    }

    private int resolveTimeSlot(String newTime) {
        if (newTime == null || newTime.trim().isEmpty()) return 0;

        LocalTime t;
        try {
            t = LocalTime.parse(newTime);
        } catch (Exception e) {
            return 0;
        }

        if (!t.isBefore(LocalTime.of(9, 0)) && !t.isAfter(LocalTime.of(11, 30))) return 1;
        if (!t.isBefore(LocalTime.of(13, 0)) && !t.isAfter(LocalTime.of(15, 30))) return 2;
        if (!t.isBefore(LocalTime.of(16, 0)) && !t.isAfter(LocalTime.of(17, 30))) return 3;
        return 0;
    }

    private Long parseLong(String v) {
        try {
            return v == null ? null : Long.parseLong(v);
        } catch (Exception e) {
            return null;
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}