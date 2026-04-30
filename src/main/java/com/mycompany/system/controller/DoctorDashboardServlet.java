package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/doctor/dashboard")
public class DoctorDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"doctor".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = loginUser.getId();

        Map<String, Object> profile = getStaffProfile(doctorId);
        List<Map<String, Object>> appointments = getTodayAppointments(doctorId, 50);
        List<Map<String, Object>> queueList = getQueueList(doctorId, 50);
        List<Map<String, Object>> notifications = getNotifications(doctorId);
        Map<String, Object> stats = buildStats(appointments, queueList);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("stats", stats);
        request.setAttribute("appointments", appointments);
        request.setAttribute("queueList", queueList);
        request.setAttribute("notifications", notifications);

        request.getRequestDispatcher("/doctor/dashboard.jsp").forward(request, response);
    }

    protected Map<String, Object> getStaffProfile(Long doctorId) {
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

    protected List<Map<String, Object>> getTodayAppointments(Long doctorId, int limit) {
        String sql = "SELECT r.id, r.reg_no, r.reg_date, r.queue_no, r.status, " +
                "p.real_name AS patient_name, dep.dept_name AS service, r.call_time " +
                "FROM registration r JOIN patient p ON r.patient_id = p.id " +
                "JOIN department dep ON r.department_id = dep.id " +
                "WHERE r.doctor_id = ? AND r.reg_date = CURDATE() ORDER BY r.queue_no ASC LIMIT ?";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("ticketNo", rs.getString("reg_no"));
                    row.put("patient", rs.getString("patient_name"));
                    row.put("service", rs.getString("service"));
                    row.put("statusCode", rs.getInt("status"));
                    row.put("status", statusToText(rs.getInt("status")));
                    row.put("queueNo", rs.getInt("queue_no"));
                    row.put("callTime", rs.getTimestamp("call_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    protected List<Map<String, Object>> getQueueList(Long doctorId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String regSql = "SELECT r.id, r.reg_no AS ticket_no, p.real_name AS patient_name, dep.dept_name AS service, r.status, r.queue_no, 'REG' AS source " +
                "FROM registration r JOIN patient p ON r.patient_id = p.id JOIN department dep ON r.department_id = dep.id " +
                "WHERE r.doctor_id = ? AND r.status IN (1,3,4) AND r.reg_date = CURDATE() ORDER BY r.queue_no ASC";
        String queueSql = "SELECT q.id, q.queue_no AS ticket_no, p.real_name AS patient_name, c.clinic_name AS service, " +
                "CASE q.status WHEN 'waiting' THEN 1 WHEN 'called' THEN 3 ELSE 1 END AS status, q.queue_no, 'QUEUE' AS source " +
                "FROM queue q JOIN patient p ON q.patient_id = p.id JOIN clinic c ON q.clinic_id = c.id " +
                "WHERE (q.doctor_id = ? OR q.doctor_id IS NULL) AND q.status IN ('waiting','called') " +
                "ORDER BY q.created_time ASC LIMIT ?";
        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(regSql)) {
                ps.setLong(1, doctorId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("id", rs.getLong("id"));
                        row.put("ticketNo", rs.getString("ticket_no"));
                        row.put("patient", rs.getString("patient_name"));
                        row.put("service", rs.getString("service"));
                        row.put("statusCode", rs.getInt("status"));
                        row.put("source", rs.getString("source"));
                        row.put("queueNo", rs.getInt("queue_no"));
                        list.add(row);
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(queueSql)) {
                ps.setLong(1, doctorId);
                ps.setInt(2, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("id", rs.getLong("id"));
                        row.put("ticketNo", rs.getString("ticket_no"));
                        row.put("patient", rs.getString("patient_name"));
                        row.put("service", rs.getString("service"));
                        row.put("statusCode", rs.getInt("status"));
                        row.put("source", rs.getString("source"));
                        row.put("queueNo", rs.getString("queue_no"));
                        list.add(row);
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        list.sort((a, b) -> {
            int ca = (int) a.get("statusCode");
            int cb = (int) b.get("statusCode");
            if (ca != cb) return Integer.compare(ca, cb);
            String qa = String.valueOf(a.get("queueNo"));
            String qb = String.valueOf(b.get("queueNo"));
            int na = extractNumber(qa);
            int nb = extractNumber(qb);
            return Integer.compare(na, nb);
        });
        return list;
    }

    private int extractNumber(String s) {
        try {
            return Integer.parseInt(s.replaceAll("\\D+", ""));
        } catch (Exception e) { return Integer.MAX_VALUE; }
    }

    protected List<Map<String, Object>> getNotifications(Long doctorId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, title, content AS message, publish_time AS time, 'info' AS type " +
                "FROM notice WHERE status = 1 ORDER BY publish_time DESC LIMIT 20";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("title", rs.getString("title"));
                    row.put("message", rs.getString("message"));
                    row.put("time", rs.getTimestamp("time"));
                    row.put("type", rs.getString("type"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private Map<String, Object> buildStats(List<Map<String, Object>> appointments, List<Map<String, Object>> queueList) {
        Map<String, Object> stats = new HashMap<>();
        int booked = 0, called = 0, consulting = 0, completed = 0, waiting = 0;
        for (Map<String, Object> a : appointments) {
            int code = (int) a.get("statusCode");
            if (code == 1) booked++;
            else if (code == 3) called++;
            else if (code == 4) consulting++;
            else if (code == 5) completed++;
        }
        for (Map<String, Object> q : queueList) {
            int code = (int) q.get("statusCode");
            if (code == 1) waiting++;
        }
        stats.put("bookedCount", booked);
        stats.put("calledCount", called);
        stats.put("consultingCount", consulting);
        stats.put("completedCount", completed);
        stats.put("waitingCount", waiting);
        return stats;
    }

    private String statusToText(int status) {
        switch (status) {
            case 1: return "Booked";
            case 3: return "Called";
            case 4: return "Consulting";
            case 5: return "Completed";
            default: return "Unknown";
        }
    }
}