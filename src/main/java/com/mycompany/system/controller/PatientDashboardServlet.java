package com.mycompany.system.controller;

import com.mycompany.system.dao.PatientDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/patient/dashboard")
public class PatientDashboardServlet extends HttpServlet {

    private PatientDashboardDao dao = new PatientDashboardDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();

        Map<String, Object> patientProfile = dao.getPatientProfile(patientId);
        if (patientProfile == null || patientProfile.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String, Object>> appointments = dao.getUpcomingAppointments(patientId);
        List<Map<String, Object>> queueTickets = dao.getQueueTickets(patientId);
        List<Map<String, Object>> notifications = dao.getLatestNotices(patientId);

        request.setAttribute("patientProfile", patientProfile);
        request.setAttribute("appointments", appointments);
        request.setAttribute("queueTickets", queueTickets);
        request.setAttribute("notifications", notifications);

        request.getRequestDispatcher("/patient/dashboard.jsp").forward(request, response);
    }
}