package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/doctor/issues")
public class DoctorIssuesServlet extends HttpServlet {

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
        List<Map<String, Object>> issues = getIssues(doctorId);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("issues", issues);
        request.getRequestDispatcher("/doctor/issues.jsp").forward(request, response);
    }

    private List<Map<String, Object>> getIssues(Long doctorId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, operation AS type, detail, create_time FROM operation_log " +
                "WHERE user_type = 2 AND user_id = ? ORDER BY create_time DESC LIMIT 50";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("type", rs.getString("type"));
                    row.put("detail", rs.getString("detail"));
                    row.put("createdAt", rs.getTimestamp("create_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}