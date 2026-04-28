package com.mycompany.system.controller;

import com.mycompany.system.dao.AdminDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/quota")
public class AdminQuotaServlet extends HttpServlet {
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
        request.setAttribute("quota", dao.getQuota());
        request.setAttribute("clinics", dao.getClinics());
        request.getRequestDispatcher("/admin/quota.jsp").forward(request, response);
    }
}