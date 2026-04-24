package com.mycompany.system.controller;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.dao.AdminDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

        List<Map<String, String>> menuItems = new ArrayList<>();
        menuItems.add(createMenu("dashboard", "fa-chart-pie", "Dashboard"));
        menuItems.add(createMenu("users", "fa-users", "User Management"));
        menuItems.add(createMenu("appointments", "fa-calendar-days", "Appointments"));
        menuItems.add(createMenu("queue", "fa-users-line", "Queue"));
        menuItems.add(createMenu("quota", "fa-sliders", "Clinic Settings"));
        menuItems.add(createMenu("reports", "fa-chart-line", "Reports"));
        menuItems.add(createMenu("logs", "fa-clipboard-list", "Audit Trail"));
        menuItems.add(createMenu("notifications", "fa-bell", "Notifications"));
        menuItems.add(createMenu("settings", "fa-gear", "System Settings"));
        menuItems.add(createMenu("csv", "fa-file-csv", "CSV Import/Export"));
        menuItems.add(createMenu("profile", "fa-user-shield", "Profile & Security"));
        request.setAttribute("menuItems", menuItems);

        request.getRequestDispatcher("/admin/home.jsp").forward(request, response);
    }

    private Map<String, String> createMenu(String id, String icon, String name) {
        Map<String, String> m = new HashMap<>();
        m.put("id", id);
        m.put("icon", icon);
        m.put("name", name);
        return m;
    }
}