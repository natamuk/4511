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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/patient/update-profile")
public class PatientProfileUpdateServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null || !"patient".equals(session.getAttribute("role"))) {
            writeJson(response, 401, false, "Unauthorized");
            return;
        }

        Long patientId = ((LoginUser) session.getAttribute("loginUser")).getId();
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String avatar = request.getParameter("avatar");
        String oldPwd = request.getParameter("oldPwd");
        String newPwd = request.getParameter("newPwd");

        try (Connection conn = DBUtil.getConnection()) {
            // 處理密碼變更
            if (newPwd != null && !newPwd.trim().isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT password FROM patient WHERE id = ?")) {
                    ps.setLong(1, patientId);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next() && !rs.getString("password").equals(oldPwd)) {
                        writeJson(response, 400, false, "Incorrect current password");
                        return;
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement("UPDATE patient SET password = ? WHERE id = ?")) {
                    ps.setString(1, newPwd);
                    ps.setLong(2, patientId);
                    ps.executeUpdate();
                }
            }

            // 處理資料更新
            String sql = "UPDATE patient SET real_name=?, phone=?, email=?, address=?, avatar=?, update_time=NOW() WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, name);
                ps.setString(2, phone);
                ps.setString(3, email);
                ps.setString(4, address);
                ps.setString(5, avatar);
                ps.setLong(6, patientId);
                ps.executeUpdate();
            }
            writeJson(response, 200, true, "Profile updated successfully");
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, 500, false, "Server error");
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}