/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/user/update")
public class AdminUserUpdateServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String idStr = request.getParameter("id");
        String type = request.getParameter("type");
        String realName = request.getParameter("realName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String title = request.getParameter("title");
        String departmentIdStr = request.getParameter("departmentId");

        if (idStr == null || type == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing required parameters");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            boolean success = false;

            if ("doctor".equalsIgnoreCase(type)) {
                DoctorBean d = new DoctorBean();
                d.setId(id);
                d.setRealName(realName);
                d.setPhone(phone);
                d.setEmail(email);
                d.setTitle(title);
                if (departmentIdStr != null && !departmentIdStr.isBlank()) {
                    d.setDepartmentId(Long.parseLong(departmentIdStr));
                } else {
                    d.setDepartmentId(1L);
                }
                success = DoctorDB.update(d);
            } else if ("patient".equalsIgnoreCase(type)) {
                PatientBean p = new PatientBean();
                p.setId(id);
                p.setRealName(realName);
                p.setPhone(phone);
                p.setEmail(email);
                success = PatientDB.update(p);
            } else {
                result.put("success", false);
                result.put("message", "Invalid user type");
                response.getWriter().write(gson.toJson(result));
                return;
            }

            if (success) {
                result.put("success", true);
                result.put("message", "User updated successfully");
            } else {
                result.put("success", false);
                result.put("message", "Update failed or user not found");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
            e.printStackTrace();
        }

        response.getWriter().write(gson.toJson(result));
    }
}