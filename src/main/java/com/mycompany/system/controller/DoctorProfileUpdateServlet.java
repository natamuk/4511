/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/update-profile")
public class DoctorProfileUpdateServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null || !"doctor".equals(session.getAttribute("role"))) {
            writeJson(response, 401, false, "Unauthorized", result);
            return;
        }

        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = user.getId();
        String oldPwd = request.getParameter("oldPwd");
        String newPwd = request.getParameter("newPwd");

        if (newPwd == null || newPwd.trim().isEmpty()) {
            writeJson(response, 200, true, "Profile updated successfully", result);
            return;
        }

        try {
            DoctorBean doctor = DoctorDB.getById(doctorId);
            if (doctor == null) {
                writeJson(response, 404, false, "User not found", result);
                return;
            }
            if (!doctor.getPassword().equals(oldPwd)) {
                writeJson(response, 400, false, "Incorrect current password", result);
                return;
            }
            if (DoctorDB.updatePassword(doctorId, newPwd)) {
                writeJson(response, 200, true, "Password updated successfully", result);
            } else {
                writeJson(response, 500, false, "Failed to update password", result);
            }
        } catch (Exception e) {
            writeJson(response, 500, false, "Server error: " + e.getMessage(), result);
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message, Map<String, Object> map) throws IOException {
        response.setStatus(status);
        map.put("success", success);
        map.put("message", message);
        response.getWriter().write(gson.toJson(map));
    }
}