/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.PatientDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/patient/update-profile")
public class PatientProfileUpdateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();
        String action = request.getParameter("action");

        try {
            if ("changePassword".equals(action)) {
                // Password Change
                String oldPwd = request.getParameter("oldPwd");
                String newPwd = request.getParameter("newPwd");

                PatientBean patient = PatientDB.getById(patientId);
                if (patient == null || !patient.getPassword().equals(oldPwd)) {
                    request.setAttribute("error", "Current password is incorrect");
                } else if (PatientDB.updatePassword(patientId, newPwd)) {
                    request.setAttribute("success", "Password updated successfully");
                } else {
                    request.setAttribute("error", "Failed to update password");
                }
            } else {
                // Profile Update
                PatientBean patient = new PatientBean();
                patient.setId(patientId);
                patient.setRealName(request.getParameter("realName"));
                patient.setPhone(request.getParameter("phone"));
                patient.setEmail(request.getParameter("email"));
                patient.setAddress(request.getParameter("address"));

                if (PatientDB.update(patient)) {
                    request.setAttribute("success", "Profile updated successfully");
                    request.getRequestDispatcher("/patient/profile.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Failed to update profile");
                    request.getRequestDispatcher("/patient/profile.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error occurred");
        }

        response.sendRedirect(request.getContextPath() + "/patient/profile");
    }
}