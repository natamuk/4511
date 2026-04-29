/*
 * Doctor Profile Update Servlet
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/doctor/update-profile")
public class DoctorProfileUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"doctor".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = loginUser.getId();
        String action = request.getParameter("action");

        try {
            if ("changePassword".equals(action)) {
                // ==================== CHANGE PASSWORD ====================
                String oldPwd = request.getParameter("oldPwd");
                String newPwd = request.getParameter("newPwd");

                if (oldPwd == null || newPwd == null || newPwd.trim().isEmpty()) {
                    request.setAttribute("error", "Current and new password are required");
                } else {
                    DoctorBean doctor = DoctorDB.getById(doctorId);
                    if (doctor == null || !doctor.getPassword().equals(oldPwd)) {
                        request.setAttribute("error", "Current password is incorrect");
                    } else if (DoctorDB.updatePassword(doctorId, newPwd)) {
                        request.setAttribute("success", "Password updated successfully");
                    } else {
                        request.setAttribute("error", "Failed to update password");
                    }
                }

            } else {
                // ==================== UPDATE PROFILE ====================
                DoctorBean doctor = new DoctorBean();
                doctor.setId(doctorId);
                doctor.setRealName(request.getParameter("realName"));
                doctor.setPhone(request.getParameter("phone"));
                doctor.setEmail(request.getParameter("email"));
                doctor.setTitle(request.getParameter("title"));

                // Handle Department ID
                String deptStr = request.getParameter("departmentId");
                if (deptStr != null && !deptStr.trim().isEmpty()) {
                    try {
                        doctor.setDepartmentId(Long.parseLong(deptStr));
                    } catch (NumberFormatException e) {
                        doctor.setDepartmentId(null);
                    }
                }

                if (DoctorDB.update(doctor)) {
                    request.setAttribute("success", "Profile updated successfully");
                    request.getRequestDispatcher("/doctor/profile.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Failed to update profile");
                    request.getRequestDispatcher("/doctor/profile.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
        }

        // Always redirect (best practice to prevent duplicate form submission)
        response.sendRedirect(request.getContextPath() + "/doctor/profile");
    }
}