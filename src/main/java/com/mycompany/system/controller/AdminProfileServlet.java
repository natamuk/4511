package com.mycompany.system.controller;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/profile")
public class AdminProfileServlet extends HttpServlet {
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
        AdminBean admin = AdminDB.getById(user.getId());
        request.setAttribute("adminProfile", admin);
        request.getRequestDispatcher("/admin/profile.jsp").forward(request, response);
    }
}