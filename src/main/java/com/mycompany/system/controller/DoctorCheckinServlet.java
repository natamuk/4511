/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/checkin")
public class DoctorCheckinServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"doctor".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = user.getId();
        LocalDate today = LocalDate.now();

        try (Connection conn = DBUtil.getConnection()) {
            String checkSql = "SELECT checkin_time FROM doctor_attendance WHERE doctor_id = ? AND date = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setLong(1, doctorId);
                ps.setDate(2, Date.valueOf(today));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Timestamp checkinTs = rs.getTimestamp("checkin_time");
                        String checkinTime = checkinTs.toLocalDateTime().format(DateTimeFormatter.ofPattern("HH:mm:ss"));
                        result.put("success", false);
                        result.put("alreadyChecked", true);
                        result.put("checkinTime", checkinTime);
                        result.put("message", "Already checked in today at " + checkinTime);
                        response.getWriter().write(gson.toJson(result));
                        return;
                    }
                }
            }

            String insertSql = "INSERT INTO doctor_attendance (doctor_id, checkin_time, date, status) VALUES (?, NOW(), ?, 1)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setLong(1, doctorId);
                ps.setDate(2, Date.valueOf(today));
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    result.put("success", true);
                    result.put("message", "Check-in successful");
                    try (Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT NOW() as now")) {
                        if (rs.next()) {
                            Timestamp now = rs.getTimestamp("now");
                            String timeStr = now.toLocalDateTime().format(DateTimeFormatter.ofPattern("HH:mm:ss"));
                            result.put("checkinTime", timeStr);
                        }
                    }
                } else {
                    result.put("success", false);
                    result.put("message", "Check-in failed, please try again");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Database error: " + e.getMessage());
        }

        response.getWriter().write(gson.toJson(result));
    }
}