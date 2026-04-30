package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/issue")
public class DoctorIssueServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        LoginUser user = (session == null) ? null : (LoginUser) session.getAttribute("loginUser");
        if (user == null || !"doctor".equals(session.getAttribute("role"))) {
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String issueType = request.getParameter("issueType");
        String detail = request.getParameter("detail");

        if (detail == null || detail.trim().isEmpty()) {
            result.put("success", false);
            result.put("message", "Detail description is required");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        if (issueType == null || issueType.trim().isEmpty()) {
            issueType = "Manual Report";
        }

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "INSERT INTO doctor_issue (doctor_id, issue_type, clinic_name, detail, status, created_at) " +
                         "VALUES (?, ?, '', ?, 'Open', NOW())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, user.getId());
                ps.setString(2, issueType);
                ps.setString(3, detail);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    result.put("success", true);
                    result.put("message", "Issue reported successfully");
                } else {
                    result.put("success", false);
                    result.put("message", "Failed to insert record");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Database error: " + e.getMessage());
        }
        response.getWriter().write(gson.toJson(result));
    }
}