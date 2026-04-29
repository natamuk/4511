/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null) username = "";
        if (password == null) password = "";

        username = username.trim();

        LoginUser user = null;
        String realName = null;

        AdminBean admin = AdminDB.login(username, password);
        if (admin != null) {
            user = new LoginUser();
            user.setId(admin.getId());
            user.setUsername(admin.getUsername());
            user.setRealName(admin.getRealName());
            user.setRole("admin");
            realName = admin.getRealName();
        } else {
            DoctorBean doctor = DoctorDB.login(username, password);
            if (doctor != null) {
                user = new LoginUser();
                user.setId(doctor.getId());
                user.setUsername(doctor.getUsername());
                user.setRealName(doctor.getRealName());
                user.setRole("doctor");
                realName = doctor.getRealName();
            } else {
                PatientBean patient = PatientDB.login(username, password);
                if (patient != null) {
                    user = new LoginUser();
                    user.setId(patient.getId());
                    user.setUsername(patient.getUsername());
                    user.setRealName(patient.getRealName());
                    user.setRole("patient");
                    realName = patient.getRealName();
                }
            }
        }

        if (user != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("loginUser", user);
            session.setAttribute("role", user.getRole());
            session.setAttribute("realName", realName);   

            switch (user.getRole()) {
                case "admin":
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    break;
                case "doctor":
                    response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
                    break;
                case "patient":
                    response.sendRedirect(request.getContextPath() + "/patient/dashboard");
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    break;
            }
        } else {
            request.setAttribute("errorMsg", "Invalid username or password.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}