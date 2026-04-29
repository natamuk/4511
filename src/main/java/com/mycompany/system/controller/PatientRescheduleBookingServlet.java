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

        int newTimeSlot = resolveTimeSlot(newTime);
        if (newTimeSlot == -1) {
            writeJson(response, 400, false, "Invalid time slot");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            Long oldScheduleId, doctorId, clinicId;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT r.schedule_id, r.doctor_id, s.clinic_id FROM registration r " +
                    "JOIN schedule s ON r.schedule_id = s.id " +
                    "WHERE r.id = ? AND r.patient_id = ? AND r.status = 1 FOR UPDATE")) {
                ps.setLong(1, regId);
                ps.setLong(2, patientId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        writeJson(response, 400, false, "Booking not found or cannot be rescheduled");
                        return;
                    }
                    oldScheduleId = rs.getLong("schedule_id");
                    doctorId = rs.getLong("doctor_id");
                    clinicId = rs.getLong("clinic_id");
                }
            }

            String checkCapacitySql = "SELECT cts.capacity, (SELECT COUNT(*) FROM registration r JOIN schedule s ON r.schedule_id = s.id WHERE s.clinic_id = ? AND r.reg_date = ? AND s.time_slot = ? AND r.status IN (1,3,4,5)) AS booked_count FROM clinic_time_slot cts WHERE cts.clinic_id = ? AND cts.slot_time = ? AND cts.status = 1";
            int capacity = 0, bookedCount = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkCapacitySql)) {
                ps.setLong(1, clinicId);
                ps.setString(2, newDate);
                ps.setInt(3, newTimeSlot);
                ps.setLong(4, clinicId);
                ps.setString(5, newTime);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        writeJson(response, 400, false, "Selected time slot unavailable");
                        return;
                    }
                    capacity = rs.getInt("capacity");
                    bookedCount = rs.getInt("booked_count");
                }
            }
            if (bookedCount >= capacity) {
                conn.rollback();
                writeJson(response, 409, false, "Time slot is full");
                return;
            }

            Long newScheduleId = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM schedule WHERE doctor_id = ? AND schedule_date = ? AND time_slot = ? AND clinic_id = ? AND status = 1 AND booked_count < max_count LIMIT 1 FOR UPDATE")) {
                ps.setLong(1, doctorId);
                ps.setString(2, newDate);
                ps.setInt(3, newTimeSlot);
                ps.setLong(4, clinicId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        newScheduleId = rs.getLong("id");
                    } else {
                        conn.rollback();
                        writeJson(response, 400, false, "No available schedule for this doctor on the selected date/time");
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

            int newQueueNo = 1;
            try (PreparedStatement ps = conn.prepareStatement("SELECT COALESCE(MAX(queue_no), 0) + 1 FROM registration WHERE reg_date = ? AND schedule_id = ?")) {
                ps.setString(1, newDate);
                ps.setLong(2, newScheduleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) newQueueNo = rs.getInt(1);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement("UPDATE registration SET schedule_id = ?, reg_date = ?, queue_no = ?, update_time = NOW() WHERE id = ?")) {
                ps.setLong(1, newScheduleId);
                ps.setString(2, newDate);
                ps.setInt(3, newQueueNo);
                ps.setLong(4, regId);
                ps.executeUpdate();
            }

            conn.commit();
            writeJson(response, 200, true, "Rescheduled successfully");
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, 500, false, "Server error");
        }
    }

    private int resolveTimeSlot(String time) {
        try {
            LocalTime t = LocalTime.parse(time);
            if (!t.isBefore(LocalTime.of(9, 0)) && !t.isAfter(LocalTime.of(11, 30))) return 1;
            if (!t.isBefore(LocalTime.of(13, 0)) && !t.isAfter(LocalTime.of(15, 30))) return 2;
            if (!t.isBefore(LocalTime.of(16, 0)) && !t.isAfter(LocalTime.of(17, 30))) return 3;
        } catch (Exception e) {}
        return -1;
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