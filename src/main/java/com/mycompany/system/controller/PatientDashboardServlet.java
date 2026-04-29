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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("PatientDashboardServlet.doGet() called");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null
                || !"patient".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        PatientDashboardDao dao = new PatientDashboardDao();
        request.setAttribute("patientProfile", dao.getPatientProfile(user.getId()));
        request.setAttribute("appointments", dao.getUpcomingAppointments(user.getId()));
        request.setAttribute("queueTickets", dao.getQueueTickets(user.getId()));
        request.setAttribute("notifications", dao.getLatestNotices(user.getId()));
        request.getRequestDispatcher("/patient/dashboard.jsp").forward(request, response);
    }
}
