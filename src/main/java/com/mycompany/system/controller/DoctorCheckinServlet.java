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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/doctor/checkin")
public class DoctorCheckinServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"doctor".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = user.getId();

        Map<String, Object> profile = getStaffProfile(doctorId);
        List<Map<String, Object>> pendingConsultations = getPendingConsultations(doctorId);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("pendingConsultations", pendingConsultations);
        request.getRequestDispatcher("/doctor/checkin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

    private Map<String, Object> getStaffProfile(Long doctorId) {
        String sql = "SELECT d.id, d.username, d.real_name, d.title, d.avatar, d.department_id, dept.dept_name " +
                "FROM doctor d JOIN department dept ON d.department_id = dept.id WHERE d.id = ?";
        Map<String, Object> profile = new HashMap<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    profile.put("id", rs.getLong("id"));
                    profile.put("username", rs.getString("username"));
                    profile.put("realName", rs.getString("real_name"));
                    profile.put("title", rs.getString("title"));
                    profile.put("avatar", rs.getString("avatar"));
                    profile.put("departmentId", rs.getLong("department_id"));
                    profile.put("departmentName", rs.getString("dept_name"));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return profile;
    }

    private List<Map<String, Object>> getPendingConsultations(Long doctorId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT r.id, r.reg_no AS ticketNo, p.real_name AS patient, dep.dept_name AS service, r.status AS statusCode, 'REG' AS source " +
                "FROM registration r " +
                "JOIN patient p ON r.patient_id = p.id " +
                "JOIN department dep ON r.department_id = dep.id " +
                "WHERE r.doctor_id = ? AND r.status IN (3,4) AND r.reg_date = CURDATE() " +
                "ORDER BY r.queue_no";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("ticketNo", rs.getString("ticketNo"));
                    row.put("patient", rs.getString("patient"));
                    row.put("service", rs.getString("service"));
                    row.put("statusCode", rs.getInt("statusCode"));
                    row.put("source", rs.getString("source"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}