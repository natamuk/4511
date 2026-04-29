/*
 * Admin Delete Servlet (Doctor / Patient / Admin)
 */
package com.mycompany.system.controller;

import com.mycompany.system.db.AdminDB;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 *
 * @author USER
 */
@WebServlet(name = "AbminDeleteServlet", urlPatterns = {"/AbminDeleteServlet"})
public class AbminDeleteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        LoginUser loginUser = (LoginUser) (session != null ? session.getAttribute("loginUser") : null);

        // Security Check
        if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        String roleParam = request.getParameter("role");

        if (idParam != null && idParam.matches("\\d+")) {
            Long id = Long.parseLong(idParam);

            boolean deleted = false;

            try {
                if ("doctor".equalsIgnoreCase(roleParam)) {
                    deleted = DoctorDB.deleteById(id);
                } 
                else if ("patient".equalsIgnoreCase(roleParam)) {
                    deleted = PatientDB.deleteById(id);
                } 
                else if ("admin".equalsIgnoreCase(roleParam)) {
                    // Prevent deleting yourself
                    if (id.equals(loginUser.getId())) {
                        request.setAttribute("error", "You cannot delete your own account!");
                    } 
                    // Optional: Protect default admin accounts (id 1 and 2)
                    else if (id == 1 || id == 2) {
                        request.setAttribute("error", "Cannot delete default admin accounts!");
                    } 
                    else {
                        deleted = AdminDB.deleteById(id);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Delete failed: " + e.getMessage());
            }

            if (deleted) {
                request.setAttribute("success", "User deleted successfully");
            }
        }

        // Forward back to users page
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }
}