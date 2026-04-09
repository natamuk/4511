/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
            String sql = "INSERT INTO operation_log (user_type, user_id, operation, detail, create_time) VALUES (2, ?, 'Issue Report', ?, NOW())";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, user.getId());
                ps.setString(2, detail);
                ps.executeUpdate();
            }
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
        }
        response.getWriter().write(gson.toJson(result));
    }
}