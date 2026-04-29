/*
 * Admin Profile Update Servlet
 */
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
        if (session == null || session.getAttribute("loginUser") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long adminId = loginUser.getId();
        String action = request.getParameter("action");

        try {
            if ("changePassword".equals(action)) {
                // ==================== CHANGE PASSWORD ====================
                String oldPwd = request.getParameter("oldPwd");
                String newPwd = request.getParameter("newPwd");

                if (oldPwd == null || newPwd == null || newPwd.trim().isEmpty()) {
                    request.setAttribute("error", "Current and new password are required");
                } else {
                    AdminBean admin = AdminDB.getById(adminId);
                    if (admin == null || !admin.getPassword().equals(oldPwd)) {
                        request.setAttribute("error", "Current password is incorrect");
                    } else if (AdminDB.updatePassword(adminId, newPwd)) {
                        request.setAttribute("success", "Password updated successfully");
                    } else {
                        request.setAttribute("error", "Failed to update password");
                    }
                }

            } else {
                // ==================== UPDATE PROFILE ====================
                AdminBean admin = new AdminBean();
                admin.setId(adminId);
                admin.setRealName(request.getParameter("realName"));
                admin.setPhone(request.getParameter("phone"));
                admin.setEmail(request.getParameter("email"));

                if (AdminDB.update(admin)) {
                    request.setAttribute("success", "Profile updated successfully");
                    request.getRequestDispatcher("/admin/profile.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Failed to update profile");
                    request.getRequestDispatcher("/admin/profile.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
        }

    }
}
