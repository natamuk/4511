package com.mycompany.system.controller;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.dao.AdminDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        AdminDashboardDao dao = new AdminDashboardDao();

        AdminBean adminProfile = AdminDB.getById(user.getId());
        request.setAttribute("adminProfile", adminProfile);
        request.setAttribute("appointments", dao.getAppointments());
        request.setAttribute("queueList", dao.getQueueList());
        request.setAttribute("notifications", dao.getNotifications(user.getId()));
        request.setAttribute("issues", dao.getIssues());
        request.setAttribute("logs", dao.getLogs());
        request.setAttribute("doctorUsers", dao.getDoctors());
        request.setAttribute("patientUsers", dao.getPatients());
        request.setAttribute("clinics", dao.getClinics());
        request.setAttribute("quota", dao.getQuota());
        request.setAttribute("settings", dao.getSettings());

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}