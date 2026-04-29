package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.ClinicBean;
import com.mycompany.system.db.ClinicDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/clinic/update")
public class AdminClinicUpdateServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String location = request.getParameter("location");
        String statusStr = request.getParameter("status");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing clinic id");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            ClinicBean clinic = ClinicDB.getById(id);
            if (clinic == null) {
                result.put("success", false);
                result.put("message", "Clinic not found");
                response.getWriter().write(gson.toJson(result));
                return;
            }
            if (name != null && !name.trim().isEmpty()) clinic.setClinicName(name.trim());
            if (location != null) clinic.setLocation(location.trim());
            if (statusStr != null && !statusStr.trim().isEmpty()) {
                clinic.setStatus(Integer.parseInt(statusStr));
            }
            boolean success = ClinicDB.update(clinic);
            result.put("success", success);
            result.put("message", success ? "Clinic updated" : "Update failed");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Invalid id format");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
        }
        response.getWriter().write(gson.toJson(result));
    }
}