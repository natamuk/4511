/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.dao.AdminDashboardDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/clinic/manage")
public class AdminClinicManageServlet extends HttpServlet {
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

        String action = request.getParameter("action");
        if (action == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing action");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        AdminDashboardDao dao = new AdminDashboardDao();

        try {
            if ("add".equalsIgnoreCase(action)) {
                String name = request.getParameter("name");
                String address = request.getParameter("address");
                String phone = request.getParameter("phone");
                boolean success = dao.createClinic(name, address, phone);
                result.put("success", success);
                result.put("message", success ? "Clinic created" : "Create failed");
            } else if ("update".equalsIgnoreCase(action)) {
                String idStr = request.getParameter("id");
                if (idStr == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.put("success", false);
                    result.put("message", "Missing id");
                    response.getWriter().write(gson.toJson(result));
                    return;
                }
                Long id = Long.parseLong(idStr);
                String name = request.getParameter("name");
                String address = request.getParameter("address");
                String phone = request.getParameter("phone");
                boolean success = dao.updateClinic(id, name, address, phone);
                result.put("success", success);
                result.put("message", success ? "Clinic updated" : "Update failed");
            } else if ("disable".equalsIgnoreCase(action)) {
                String idStr = request.getParameter("id");
                if (idStr == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.put("success", false);
                    result.put("message", "Missing id");
                    response.getWriter().write(gson.toJson(result));
                    return;
                }
                Long id = Long.parseLong(idStr);
                boolean success = dao.disableClinic(id);
                result.put("success", success);
                result.put("message", success ? "Clinic disabled" : "Operation failed");
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                result.put("success", false);
                result.put("message", "Unknown action");
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