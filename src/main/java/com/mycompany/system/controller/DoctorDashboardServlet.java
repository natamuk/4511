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

        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";

        Map<String, Object> profile = getStaffProfile(doctorId);
        List<Map<String, Object>> appointments = getTodayAppointments(doctorId, 50);
        List<Map<String, Object>> queueList = getQueueList(doctorId, 50);
        List<Map<String, Object>> notifications = getNotifications(20);
        List<Map<String, Object>> issues = getIssues(doctorId, 20);
        List<Map<String, Object>> consultations = getConsultations(doctorId, 50);
        List<Map<String, Object>> searchResults = searchPatients(doctorId, keyword, 20);
        List<Map<String, Object>> recordResults = searchConsultationRecords(doctorId, keyword, 20);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("appointments", appointments);
        request.setAttribute("queueList", queueList);
        request.setAttribute("notifications", notifications);
        request.setAttribute("issues", issues);
        request.setAttribute("consultations", consultations);
        request.setAttribute("searchResults", searchResults);
        request.setAttribute("recordResults", recordResults);
        request.setAttribute("stats", buildStats(appointments, queueList, issues, consultations));

        List<Map<String, String>> menuItems = new ArrayList<>();
        menuItems.add(createMenu("dashboard", "fa-chart-pie", "Dashboard"));
        menuItems.add(createMenu("myAppointments", "fa-user-doctor", "My Appointments"));
        menuItems.add(createMenu("appointments", "fa-calendar-days", "All Appointments"));
        menuItems.add(createMenu("queue", "fa-users-line", "Queue Management"));
        menuItems.add(createMenu("checkin", "fa-clipboard-check", "Consultation"));
        menuItems.add(createMenu("search", "fa-magnifying-glass", "Patient Search"));
        menuItems.add(createMenu("issues", "fa-triangle-exclamation", "Issue Reporting"));
        menuItems.add(createMenu("notifications", "fa-bell", "Notifications"));
        menuItems.add(createMenu("profile", "fa-user-gear", "Profile & Security"));
        request.setAttribute("menuItems", menuItems);

        request.getRequestDispatcher("/doctor/home.jsp").forward(request, response);
    }

    private Map<String, String> createMenu(String id, String icon, String name) {
        Map<String, String> m = new HashMap<>();
        m.put("id", id);
        m.put("icon", icon);
        m.put("name", name);
        return m;
    }

    private Map<String, Object> buildStats(List<Map<String, Object>> appointments,
                                           List<Map<String, Object>> queueList,
                                           List<Map<String, Object>> issues,
                                           List<Map<String, Object>> consultations) {
        Map<String, Object> stats = new HashMap<>();
        int bookedCount = 0, calledCount = 0, consultingCount = 0, completedCount = 0, noShowCount = 0, waitingCount = 0;

        for (Map<String, Object> a : appointments) {
            int code = getInt(a.get("statusCode"));
            if (code == 1) bookedCount++;
            if (code == 3) calledCount++;
            if (code == 4) consultingCount++;
            if (code == 5) completedCount++;
            if (code == 6) noShowCount++;
        }

        for (Map<String, Object> q : queueList) {
            int code = getInt(q.get("statusCode"));
            if (code == 1) waitingCount++;
        }

        stats.put("bookedCount", bookedCount);
        stats.put("calledCount", calledCount);
        stats.put("consultingCount", consultingCount);
        stats.put("completedCount", completedCount);
        stats.put("noShowCount", noShowCount);
        stats.put("waitingCount", waitingCount);
        stats.put("issueCount", issues.size());
        stats.put("consultationCount", consultations.size());
        return stats;
    }

    private int getInt(Object v) {
        if (v == null) return 0;
        if (v instanceof Number) return ((Number) v).intValue();
        try { return Integer.parseInt(String.valueOf(v)); } catch (Exception e) { return 0; }
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

    private List<Map<String, Object>> getTodayAppointments(Long doctorId, int limit) {
        String sql = "SELECT r.id, r.reg_no, r.reg_date, r.queue_no, r.status, r.call_time, " +
                "p.real_name AS patient_name, p.phone AS patient_phone, " +
                "dep.dept_name AS dept_name, s.time_slot, s.max_count, s.booked_count " +
                "FROM registration r JOIN patient p ON r.patient_id = p.id " +
                "JOIN schedule s ON r.schedule_id = s.id JOIN department dep ON r.department_id = dep.id " +
                "WHERE r.doctor_id = ? AND r.reg_date = CURDATE() ORDER BY r.queue_no ASC LIMIT ?";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("date", rs.getDate("reg_date"));
                    row.put("timeSlot", rs.getInt("time_slot"));
                    row.put("patient", rs.getString("patient_name"));
                    row.put("phone", rs.getString("patient_phone"));
                    row.put("service", rs.getString("dept_name"));
                    row.put("statusCode", rs.getInt("status"));
                    row.put("status", statusToText(rs.getInt("status")));
                    row.put("callTime", rs.getTimestamp("call_time"));
                    row.put("ticketNo", rs.getString("reg_no"));
                    row.put("queueNo", rs.getInt("queue_no"));
                    row.put("maxCount", rs.getInt("max_count"));
                    row.put("bookedCount", rs.getInt("booked_count"));
                    row.put("source", "REG");
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private List<Map<String, Object>> getQueueList(Long doctorId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();

        String regSql = "SELECT r.id AS source_id, r.reg_no AS ticket_no, r.reg_date AS visit_date, r.queue_no AS queue_no, r.status AS status_code, " +
                "r.call_time AS call_time, r.create_time AS created_time, " +
                "p.real_name AS patient_name, p.phone AS patient_phone, dept.dept_name AS dept_name, s.time_slot AS time_slot, 'REG' AS source_type " +
                "FROM registration r JOIN patient p ON r.patient_id = p.id JOIN schedule s ON r.schedule_id = s.id JOIN department dept ON r.department_id = dept.id " +
                "WHERE r.doctor_id = ? AND r.status IN (1,3,4) AND r.reg_date = CURDATE() ORDER BY r.queue_no ASC LIMIT ?";

        String queueSql = "SELECT q.id AS source_id, q.queue_no AS ticket_no, CURDATE() AS visit_date, q.queue_no AS queue_no, " +
                "CASE q.status WHEN 'waiting' THEN 1 WHEN 'called' THEN 3 WHEN 'completed' THEN 5 WHEN 'skipped' THEN 6 ELSE 1 END AS status_code, " +
                "q.called_time AS call_time, q.created_time AS created_time, " +
                "p.real_name AS patient_name, p.phone AS patient_phone, c.clinic_name AS dept_name, NULL AS time_slot, 'QUEUE' AS source_type " +
                "FROM queue q JOIN patient p ON q.patient_id = p.id JOIN clinic c ON q.clinic_id = c.id " +
                "WHERE (q.doctor_id = ? OR q.doctor_id IS NULL) AND DATE(q.created_time) = CURDATE() AND q.status IN ('waiting', 'called') ORDER BY q.created_time ASC LIMIT ?";

        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(regSql)) {
                ps.setLong(1, doctorId);
                ps.setInt(2, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("id", rs.getLong("source_id"));
                        row.put("ticketNo", rs.getString("ticket_no"));
                        row.put("patient", rs.getString("patient_name"));
                        row.put("phone", rs.getString("patient_phone"));
                        row.put("service", rs.getString("dept_name"));
                        row.put("date", rs.getDate("visit_date"));
                        row.put("statusCode", rs.getInt("status_code"));
                        row.put("status", queueStatusToText(rs.getInt("status_code")));
                        row.put("queueNo", rs.getInt("queue_no"));
                        row.put("createdTime", rs.getTimestamp("created_time"));
                        row.put("callTime", rs.getTimestamp("call_time"));
                        row.put("source", "REG");
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
                        row.put("id", rs.getLong("source_id"));
                        row.put("ticketNo", rs.getString("ticket_no"));
                        row.put("patient", rs.getString("patient_name"));
                        row.put("phone", rs.getString("patient_phone"));
                        row.put("service", rs.getString("dept_name"));
                        row.put("date", rs.getDate("visit_date"));
                        row.put("statusCode", rs.getInt("status_code"));
                        row.put("status", queueStatusToText(rs.getInt("status_code")));
                        row.put("queueNo", rs.getString("queue_no"));
                        row.put("createdTime", rs.getTimestamp("created_time"));
                        row.put("callTime", rs.getTimestamp("call_time"));
                        row.put("source", "QUEUE");
                        list.add(row);
                    }
                }
            }

            list.sort((a, b) -> {
                int c1 = getInt(a.get("statusCode"));
                int c2 = getInt(b.get("statusCode"));
                if (c1 != c2) return Integer.compare(c1, c2);

                String q1 = String.valueOf(a.get("queueNo"));
                String q2 = String.valueOf(b.get("queueNo"));
                int n1 = extractQueueNumber(q1);
                int n2 = extractQueueNumber(q2);
                if (n1 != n2) return Integer.compare(n1, n2);

                Timestamp t1 = (Timestamp) a.get("createdTime");
                Timestamp t2 = (Timestamp) b.get("createdTime");
                if (t1 == null && t2 == null) return 0;
                if (t1 == null) return 1;
                if (t2 == null) return -1;
                return t1.compareTo(t2);
            });

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private int extractQueueNumber(String queueNo) {
        if (queueNo == null) return Integer.MAX_VALUE;
        String digits = queueNo.replaceAll("\\D+", "");
        try {
            return digits.isEmpty() ? Integer.MAX_VALUE : Integer.parseInt(digits);
        } catch (Exception e) {
            return Integer.MAX_VALUE;
        }
    }

    private List<Map<String, Object>> getNotifications(int limit) {
        String sql = "SELECT id, title, content, publish_time FROM notice WHERE status = 1 ORDER BY publish_time DESC, create_time DESC LIMIT ?";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("title", rs.getString("title"));
                    row.put("message", rs.getString("content"));
                    row.put("time", rs.getTimestamp("publish_time"));
                    row.put("type", "info");
                    row.put("read", false);
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private List<Map<String, Object>> getIssues(Long doctorId, int limit) {
        String sql = "SELECT id, operation, detail, create_time FROM operation_log WHERE user_type = 2 AND user_id = ? ORDER BY create_time DESC LIMIT ?";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("type", rs.getString("operation"));
                    row.put("detail", rs.getString("detail"));
                    row.put("status", "Logged");
                    row.put("createdAt", rs.getTimestamp("create_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private List<Map<String, Object>> getConsultations(Long doctorId, int limit) {
        String sql = "SELECT c.id, c.registration_id, c.patient_id, c.doctor_id, c.diagnosis, c.medical_advice, c.prescription, c.consultation_time, c.status, p.real_name AS patient_name, r.reg_no, r.reg_date, dept.dept_name " +
                "FROM consultation c JOIN patient p ON c.patient_id = p.id JOIN registration r ON c.registration_id = r.id JOIN department dept ON r.department_id = dept.id " +
                "WHERE c.doctor_id = ? ORDER BY c.consultation_time DESC LIMIT ?";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("patient", rs.getString("patient_name"));
                    row.put("diagnosis", rs.getString("diagnosis"));
                    row.put("medicalAdvice", rs.getString("medical_advice"));
                    row.put("consultationTime", rs.getTimestamp("consultation_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private List<Map<String, Object>> searchPatients(Long doctorId, String keyword, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) return list;
        String sql = "SELECT DISTINCT p.id, p.real_name, p.phone, p.email, p.id_card, p.birthday, p.address, r.reg_no, r.reg_date, r.status AS reg_status, dept.dept_name " +
                "FROM patient p LEFT JOIN registration r ON p.id = r.patient_id LEFT JOIN department dept ON r.department_id = dept.id " +
                "WHERE (p.real_name LIKE ? OR p.phone LIKE ? OR p.id_card LIKE ?) AND (r.doctor_id = ? OR r.doctor_id IS NULL) ORDER BY p.real_name ASC LIMIT ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + keyword.trim() + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setLong(4, doctorId);
            ps.setInt(5, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("name", rs.getString("real_name"));
                    row.put("phone", rs.getString("phone"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private List<Map<String, Object>> searchConsultationRecords(Long doctorId, String keyword, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) return list;
        String sql = "SELECT c.id, c.diagnosis, c.medical_advice, c.prescription, c.consultation_time, p.real_name AS patient_name, dept.dept_name AS dept_name " +
                "FROM consultation c JOIN patient p ON c.patient_id = p.id JOIN registration r ON c.registration_id = r.id JOIN department dept ON r.department_id = dept.id " +
                "WHERE c.doctor_id = ? AND (p.real_name LIKE ? OR c.diagnosis LIKE ? OR c.prescription LIKE ? OR c.medical_advice LIKE ?) ORDER BY c.consultation_time DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + keyword.trim() + "%";
            ps.setLong(1, doctorId);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);
            ps.setString(5, like);
            ps.setInt(6, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("patient", rs.getString("patient_name"));
                    row.put("departmentName", rs.getString("dept_name"));
                    row.put("diagnosis", rs.getString("diagnosis"));
                    row.put("medicalAdvice", rs.getString("medical_advice"));
                    row.put("consultationTime", rs.getTimestamp("consultation_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private String statusToText(int status) {
        switch (status) {
            case 1: return "Booked";
            case 2: return "Cancelled";
            case 3: return "Called";
            case 4: return "Consulting";
            case 5: return "Completed";
            case 6: return "Transferred";
            default: return "Unknown";
        }
    }

    private String queueStatusToText(int status) {
        switch (status) {
            case 1: return "Waiting";
            case 3: return "Called";
            case 4: return "Consulting";
            case 5: return "Completed";
            default: return "Waiting";
        }
    }
}