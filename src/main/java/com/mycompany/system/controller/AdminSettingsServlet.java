/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
public class AdminSettingsServlet extends HttpServlet {
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

        String maxActiveBookings = request.getParameter("max_active_bookings_per_patient");
        String cancelDeadlineHours = request.getParameter("cancel_deadline_hours");
        String sameDayQueueEnabled = request.getParameter("same_day_queue_enabled");
        String bookingApprovalRequired = request.getParameter("booking_approval_required");
        String walkinEnabledClinics = request.getParameter("walkin_enabled_clinics");

        if (walkinEnabledClinics == null) walkinEnabledClinics = "";

        Map<String, String> settings = new HashMap<>();
        settings.put("max_active_bookings_per_patient", maxActiveBookings);
        settings.put("cancel_deadline_hours", cancelDeadlineHours);
        settings.put("same_day_queue_enabled", sameDayQueueEnabled);
        settings.put("booking_approval_required", bookingApprovalRequired);
        settings.put("walkin_enabled_clinics", walkinEnabledClinics);

        AdminDashboardDao dao = new AdminDashboardDao();
        boolean success = dao.saveSettings(settings);

        if (success) {
            response.setStatus(HttpServletResponse.SC_OK);
            result.put("success", true);
            result.put("message", "Settings saved successfully");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Failed to save settings");
        }

        response.getWriter().write(gson.toJson(result));
    }
}