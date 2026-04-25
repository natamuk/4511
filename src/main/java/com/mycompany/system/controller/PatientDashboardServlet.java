/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.dao.PatientDashboardDao;
import com.mycompany.system.model.LoginUser;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/patient/dashboard")
public class PatientDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();

        PatientDashboardDao dao = new PatientDashboardDao();

        request.setAttribute("patientProfile", dao.getPatientProfile(patientId));
        request.setAttribute("notifications", dao.getLatestNotices(patientId));
        request.setAttribute("records", dao.getRecentMedicalRecords(patientId));
        request.setAttribute("queue", dao.getQueueTickets(patientId));
        request.setAttribute("favorites", dao.getFavorites(patientId));

        List<Map<String, Object>> appointments = dao.getUpcomingAppointments(patientId);
        request.setAttribute("appointmentsJson", new Gson().toJson(appointments));

        List<Map<String, Object>> clinics = dao.getClinics();
        Map<Long, List<Map<String, Object>>> clinicSlots = dao.getClinicSlots();

        Gson gson = new Gson();
        request.setAttribute("clinicsJson", gson.toJson(clinics));
        request.setAttribute("clinicSlotsJson", gson.toJson(clinicSlots));

        request.getRequestDispatcher("/patient/home.jsp").forward(request, response);
    }
}