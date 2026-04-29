package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/issue")
public class DoctorIssueServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws java.io.IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        LoginUser user = (LoginUser) request.getSession().getAttribute("loginUser");
        if (user == null) {
            result.put("success", false);
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String detail = request.getParameter("detail");

        try (Connection conn = DBUtil.getConnection()) {
            // 插入到 doctor_issue 表（而不是 operation_log），以便 Issues 页面统一显示
            String sql = "INSERT INTO doctor_issue (doctor_id, issue_type, clinic_name, detail, status, created_at) VALUES (?, 'Manual Report', '', ?, 'Open', NOW())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, user.getId());
                ps.setString(2, detail);
                ps.executeUpdate();
            }
            result.put("success", true);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
        }
        response.getWriter().write(gson.toJson(result));
    }
}