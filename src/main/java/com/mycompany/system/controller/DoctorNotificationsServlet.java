package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/doctor/notifications")
public class DoctorNotificationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"doctor".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = user.getId();

        DoctorDashboardServlet dash = new DoctorDashboardServlet();
        Map<String, Object> profile = dash.getStaffProfile(doctorId);
        List<Map<String, Object>> notifications = dash.getNotifications(doctorId);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("notifications", notifications);
        request.getRequestDispatcher("/doctor/notifications.jsp").forward(request, response);
    }
}