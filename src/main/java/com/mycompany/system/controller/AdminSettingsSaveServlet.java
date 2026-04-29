package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.dao.AdminDashboardDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/settings/save")
public class AdminSettingsSaveServlet extends HttpServlet {

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

        Map<String, String> settings = new HashMap<>();
        String maxActive = request.getParameter("max_active_bookings_per_patient");
        String cancelHours = request.getParameter("cancel_deadline_hours");
        String queueEnabled = request.getParameter("same_day_queue_enabled");
        String approvalRequired = request.getParameter("booking_approval_required");
        String walkinClinics = request.getParameter("walkin_enabled_clinics");

        if (maxActive != null) settings.put("max_active_bookings_per_patient", maxActive);
        if (cancelHours != null) settings.put("cancel_deadline_hours", cancelHours);
        if (queueEnabled != null) settings.put("same_day_queue_enabled", queueEnabled);
        if (approvalRequired != null) settings.put("booking_approval_required", approvalRequired);
        if (walkinClinics != null) settings.put("walkin_enabled_clinics", walkinClinics);

        if (settings.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "No settings provided");
            response.getWriter().write(gson.toJson(result));
            return;
        }


        AdminDashboardDao dao = new AdminDashboardDao();
        boolean success = dao.saveSettings(settings);

        if (success) {
            result.put("success", true);
            result.put("message", "Settings saved successfully");
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            result.put("success", false);
            result.put("message", "Failed to save settings (database error)");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        response.getWriter().write(gson.toJson(result));
    }
}