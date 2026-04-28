/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/update-profile")
public class AdminProfileUpdateServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null || !"admin".equals(session.getAttribute("role"))) {
            writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Unauthorized", result);
            return;
        }

        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        Long adminId = user.getId();

        String oldPwd = request.getParameter("oldPwd");
        String newPwd = request.getParameter("newPwd");

        if (newPwd == null || newPwd.trim().isEmpty()) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "New password is required", result);
            return;
        }
        if (oldPwd == null || oldPwd.trim().isEmpty()) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, false, "Current password is required", result);
            return;
        }

        try {
            AdminBean admin = AdminDB.getById(adminId);
            if (admin == null) {
                writeJson(response, HttpServletResponse.SC_NOT_FOUND, false, "Admin user not found", result);
                return;
            }
            if (!admin.getPassword().equals(oldPwd)) {
                writeJson(response, HttpServletResponse.SC_FORBIDDEN, false, "Incorrect current password", result);
                return;
            }
            if (AdminDB.updatePassword(adminId, newPwd)) {
                writeJson(response, HttpServletResponse.SC_OK, true, "Password updated successfully", result);
            } else {
                writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Failed to update password", result);
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Server error: " + e.getMessage(), result);
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message, Map<String, Object> map) throws IOException {
        response.setStatus(status);
        map.put("success", success);
        map.put("message", message);
        response.getWriter().write(gson.toJson(map));
    }
}