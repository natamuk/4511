package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/doctor/notifications")
public class DoctorNotificationsServlet extends HttpServlet {

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

        DoctorDashboardServlet dash = new DoctorDashboardServlet();
        Map<String, Object> profile = dash.getStaffProfile(doctorId);
        List<Map<String, Object>> notifications = dash.getNotifications(doctorId);
        
        // 获取取消预约记录（issue_type = 'Cancellation'）
        List<Map<String, Object>> cancellations = getIssuesByType(doctorId, "Cancellation");
        // 获取其他运营问题记录（issue_type != 'Cancellation'）
        List<Map<String, Object>> operationalIssues = getOperationalIssues(doctorId); // 改用专用方法

        request.setAttribute("staffProfile", profile);
        request.setAttribute("notifications", notifications);
        request.setAttribute("cancellations", cancellations);
        request.setAttribute("operationalIssues", operationalIssues);
        request.getRequestDispatcher("/doctor/notifications.jsp").forward(request, response);
    }

    // 获取指定类型的问题
    private List<Map<String, Object>> getIssuesByType(Long doctorId, String issueType) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, issue_type AS type, detail, created_at FROM doctor_issue " +
                     "WHERE doctor_id = ? AND issue_type = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            ps.setString(2, issueType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("type", rs.getString("type"));
                    row.put("detail", rs.getString("detail"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 获取运营问题（排除 Cancellation 类型）
    private List<Map<String, Object>> getOperationalIssues(Long doctorId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, issue_type AS type, detail, created_at FROM doctor_issue " +
                     "WHERE doctor_id = ? AND issue_type != 'Cancellation' ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("type", rs.getString("type"));
                    row.put("detail", rs.getString("detail"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}