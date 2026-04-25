/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.PatientDB;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 *
 * @author USER
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    private PatientDB patientDB;

    @Override
    public void init() {
        String dbUrl = "jdbc:mysql://localhost:3306/hospital_system";
        String dbUser = "root";
        String dbPassword = "";
        patientDB = new PatientDB();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String targetURL;
        PatientBean patient = new PatientBean();
        patient.setUsername(request.getParameter("username"));
        patient.setPassword(request.getParameter("password"));
        patient.setRealName(request.getParameter("real_name"));
        patient.setPhone(request.getParameter("phone"));
        patient.setGender(Integer.parseInt(request.getParameter("gender")));
        patient.setEmail(request.getParameter("email"));
        patient.setIdCard(request.getParameter("id_card"));
        String birthdayStr = request.getParameter("birthday");
        if (birthdayStr != null && !birthdayStr.isEmpty()) {
            patient.setBirthday(LocalDate.parse(birthdayStr));
        } else {
            patient.setBirthday(null);
        }
        patient.setAddress(request.getParameter("address"));

        patient.setBalance(BigDecimal.ZERO);
        patient.setStatus(1);

        boolean success = PatientDB.insert(patient);
        if (success) {
            targetURL ="login.jsp";
        } else {
            request.setAttribute("errorMessage", "Registration failed: username already exists.");
            targetURL="/error/RegisterError.jsp";
        }

        request.getRequestDispatcher(targetURL).forward(request, response);
    }
}
