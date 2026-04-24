/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/user/create")
public class AdminUserCreateServlet extends HttpServlet {
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

        String type = request.getParameter("type");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String realName = request.getParameter("realName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String title = request.getParameter("title");
        String departmentIdStr = request.getParameter("departmentId");

        if (isBlank(type) || isBlank(username) || isBlank(password) || isBlank(realName)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing required fields");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            boolean success = false;

            switch (type.toLowerCase()) {
                case "patient":
                    PatientBean p = new PatientBean();
                    p.setUsername(username);
                    p.setPassword(password);
                    p.setRealName(realName);
                    p.setPhone(phone);
                    p.setEmail(email);
                    p.setBalance(BigDecimal.ZERO);
                    p.setStatus(1);
                    success = PatientDB.insert(p);
                    break;
                case "doctor":
                    DoctorBean d = new DoctorBean();
                    d.setUsername(username);
                    d.setPassword(password);
                    d.setRealName(realName);
                    d.setPhone(phone);
                    d.setEmail(email);
                    d.setTitle(title);
                    if (!isBlank(departmentIdStr)) {
                        d.setDepartmentId(Long.parseLong(departmentIdStr));
                    } else {
                        d.setDepartmentId(1L); 
                    }
                    d.setStatus(1);
                    success = DoctorDB.insert(d);
                    break;
                case "admin":
                    AdminBean a = new AdminBean();
                    a.setUsername(username);
                    a.setPassword(password);
                    a.setRealName(realName);
                    a.setPhone(phone);
                    a.setEmail(email);
                    a.setStatus(1);
                    success = AdminDB.insert(a);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.put("success", false);
                    result.put("message", "Invalid user type");
                    response.getWriter().write(gson.toJson(result));
                    return;
            }

            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                result.put("success", true);
                result.put("message", "User created successfully");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                result.put("success", false);
                result.put("message", "Database insert failed");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Invalid department ID format");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
            e.printStackTrace();
        }

        response.getWriter().write(gson.toJson(result));
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}