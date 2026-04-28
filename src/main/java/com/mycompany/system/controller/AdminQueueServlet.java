package com.mycompany.system.controller;

import com.mycompany.system.dao.AdminDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/queue")
public class AdminQueueServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        AdminDashboardDao dao = new AdminDashboardDao();
        request.setAttribute("queueList", dao.getQueueList());
        request.setAttribute("sameDayQueueEnabled", dao.isWalkinQueueEnabled());
        request.setAttribute("availableWalkinClinics", dao.getAvailableWalkinClinics());
        request.getRequestDispatcher("/admin/queue.jsp").forward(request, response);
    }
}