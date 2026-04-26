/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author USER
 */
@WebServlet(name = "AbminDeleteServlet", urlPatterns = {"/AbminDeleteServlet"})
public class AbminDeleteServlet extends HttpServlet {

    private DoctorDB doctorDB;
    private PatientDB patientDB;

    @Override
    public void init() {
        String dbUrl = "jdbc:mysql://localhost:3306/hospital_system";
        String dbUser = "root";
        String dbPassword = "";
        doctorDB = new DoctorDB();
        patientDB = new PatientDB();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String roleParam = request.getParameter("role");

        if (idParam != null && idParam.matches("\\d+")) {
            Long id = Long.parseLong(idParam);

            if ("doctor".equalsIgnoreCase(roleParam)) {
                DoctorDB.deleteById(id);
            } else if ("patient".equalsIgnoreCase(roleParam)) {
                PatientDB.deleteById(id);
            }
        }
        request.getRequestDispatcher("/admin/dashboard").forward(request, response);
    }
}
