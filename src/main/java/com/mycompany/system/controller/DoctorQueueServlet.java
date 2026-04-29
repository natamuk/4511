package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/doctor/queue")
public class DoctorQueueServlet extends HttpServlet {

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
        List<Map<String, Object>> queueList = dash.getQueueList(doctorId, 100);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("queueList", queueList);
        request.getRequestDispatcher("/doctor/queue.jsp").forward(request, response);
    }
}