package com.mycompany.system.controller;

import com.mycompany.system.dao.PatientDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/patient/queue")
public class PatientQueueServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        PatientDashboardDao dao = new PatientDashboardDao();
        request.setAttribute("queueTickets", dao.getQueueTickets(user.getId()));
        request.setAttribute("queueEnabled", dao.isWalkinQueueEnabled());
        request.setAttribute("walkinClinics", dao.getAvailableWalkinClinics());
        request.getRequestDispatcher("/patient/queue.jsp").forward(request, response);
    }
}