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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null) username = "";
        if (password == null) password = "";

        username = username.trim();

        LoginUser user = null;

        user = loginFromTable("admin", username, password, "admin");
        if (user == null) {
            user = loginFromTable("doctor", username, password, "doctor");
        }
        if (user == null) {
            user = loginFromTable("patient", username, password, "patient");
        }

        if (user != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("loginUser", user);
            session.setAttribute("role", user.getRole());

            switch (user.getRole()) {
                case "admin":
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    break;
                case "doctor":
                    response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
                    break;
                case "patient":
                    response.sendRedirect(request.getContextPath() + "/patient/home.jsp");
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    break;
            }
        } else {
            request.setAttribute("errorMsg", "Invalid username or password.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private LoginUser loginFromTable(String table, String username, String password, String role) {
        String sql = "SELECT id, username, real_name FROM " + table +
                     " WHERE username = ? AND password = ? AND status = 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LoginUser user = new LoginUser();
                    user.setId(rs.getLong("id"));
                    user.setUsername(rs.getString("username"));
                    user.setRealName(rs.getString("real_name"));
                    user.setRole(role);
                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}