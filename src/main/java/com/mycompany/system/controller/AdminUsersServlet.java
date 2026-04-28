package com.mycompany.system.controller;

import com.mycompany.system.dao.AdminDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {
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
        request.setAttribute("doctorUsers", dao.getDoctors());
        request.setAttribute("patientUsers", dao.getPatients());
        // 如果需要 admin 列表，请在 DAO 中实现 getAdminUsers()，此处暂不添加
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }
}