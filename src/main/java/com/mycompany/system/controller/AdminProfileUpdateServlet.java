package com.mycompany.system.controller;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/update-profile")
public class AdminProfileUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        LoginUser loginUser = (LoginUser) (session != null ? session.getAttribute("loginUser") : null);

        if (loginUser == null || !"admin".equals(loginUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        Long adminId = loginUser.getId();

        try {
            if ("changePassword".equals(action)) {
                // Password Change
                String oldPwd = request.getParameter("oldPwd");
                String newPwd = request.getParameter("newPwd");

                AdminBean admin = AdminDB.getById(adminId);
                if (admin == null || !admin.getPassword().equals(oldPwd)) {
                    request.setAttribute("error", "Current password is incorrect");
                } else if (AdminDB.updatePassword(adminId, newPwd)) {
                    request.setAttribute("success", "Password updated successfully");
                } else {
                    request.setAttribute("error", "Failed to update password");
                }
            } else {
                // Profile Update
                AdminBean admin = new AdminBean();
                admin.setId(adminId);
                admin.setRealName(request.getParameter("realName"));
                admin.setEmail(request.getParameter("email"));
                admin.setPhone(request.getParameter("phone"));

                if (AdminDB.update(admin)) {
                    request.setAttribute("success", "Profile updated successfully");
                } else {
                    request.setAttribute("error", "Failed to update profile");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error occurred");
        }

        // Redirect back to profile page
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
    }
}