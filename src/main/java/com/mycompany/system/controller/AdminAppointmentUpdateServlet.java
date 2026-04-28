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

@WebServlet("/admin/appointment/update")
public class AdminAppointmentUpdateServlet extends HttpServlet {
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
        String status = request.getParameter("status");    
        String doctorIdStr = request.getParameter("doctorId"); 

        if (idStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing id");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        AdminDashboardDao dao = new AdminDashboardDao();

        try {
            Long id = Long.parseLong(idStr);
            boolean anySuccess = true;

            if (status != null && !status.isBlank()) {
                boolean ok = dao.updateAppointmentStatus(id, status);
                anySuccess = anySuccess && ok;
            }
            if (doctorIdStr != null && !doctorIdStr.isBlank()) {
                Long doctorId = Long.parseLong(doctorIdStr);
                boolean ok = dao.reassignDoctor(id, doctorId);
                anySuccess = anySuccess && ok;
            }

            if (anySuccess) {
                result.put("success", true);
                result.put("message", "Appointment updated");
            } else {
                result.put("success", false);
                result.put("message", "No changes applied or update failed");
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