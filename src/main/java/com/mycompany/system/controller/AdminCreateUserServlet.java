/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.math.BigDecimal;

/**
 *
 * @author USER
 */
@WebServlet(name = "AdminCreateUserServlet", urlPatterns = {"/AdminCreateUserServlet"})
public class AdminCreateUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String type = request.getParameter("type"); // patient / doctor / admin
        boolean success = false;

        try {
            if ("admin".equalsIgnoreCase(type)) {
                AdminBean admin = new AdminBean();
                admin.setUsername(request.getParameter("username"));
                admin.setPassword(request.getParameter("password"));
                admin.setRealName(request.getParameter("realName"));
                admin.setPhone(request.getParameter("phone"));
                admin.setEmail(request.getParameter("email"));
                admin.setStatus(1);
                success = AdminDB.insert(admin);

            } else if ("doctor".equalsIgnoreCase(type)) {
                DoctorBean doctor = new DoctorBean();
                doctor.setUsername(request.getParameter("username"));
                doctor.setPassword(request.getParameter("password"));
                doctor.setRealName(request.getParameter("realName"));
                doctor.setPhone(request.getParameter("phone"));
                doctor.setEmail(request.getParameter("email"));
                doctor.setTitle(request.getParameter("title"));
                String deptParam = request.getParameter("departmentId");
                if (deptParam != null && deptParam.matches("\\d+")) {
                    doctor.setDepartmentId(Long.parseLong(deptParam)); 
                } else {
                    doctor.setDepartmentId(1L);
                }
                doctor.setAvatar("default.png");
                doctor.setStatus(1);
                success = DoctorDB.insert(doctor);

            } else if ("patient".equalsIgnoreCase(type)) {
                PatientBean patient = new PatientBean();
                patient.setUsername(request.getParameter("username"));
                patient.setPassword(request.getParameter("password"));
                patient.setRealName(request.getParameter("realName"));
                patient.setPhone(request.getParameter("phone"));
                patient.setEmail(request.getParameter("email"));
                patient.setAddress(request.getParameter("address"));
                patient.setAvatar("default.png");
                patient.setBalance(BigDecimal.ZERO);
                patient.setStatus(1);
                success = PatientDB.insert(patient);
            }
            
            

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                request.setAttribute("error", "Create user failed");
                request.getRequestDispatcher("/admin/add-user.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error: " + e.getMessage());
            request.getRequestDispatcher("/admin/contents/add-user.jsp").forward(request, response);
        }
    }
}
