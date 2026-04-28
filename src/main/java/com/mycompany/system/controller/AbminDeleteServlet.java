/*
 * AbminDeleteServlet - Handles Delete for Admin, Doctor & Patient
 */
package com.mycompany.system.controller;

import com.mycompany.system.db.AdminDB;
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

    private AdminDB adminDB;
    private DoctorDB doctorDB;
    private PatientDB patientDB;

    @Override
    public void init() {
        adminDB = new AdminDB();
        doctorDB = new DoctorDB();
        patientDB = new PatientDB();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String roleParam = request.getParameter("role");

        boolean success = false;

        if (idParam != null && idParam.matches("\\d+")) {
            Long id = Long.parseLong(idParam);

            try {
                switch (roleParam.toLowerCase()) {
                    case "admin":
                        success = AdminDB.deleteById(id);  
                        break;

                    case "doctor":
                        success = DoctorDB.deleteById(id);
                        break;

                    case "patient":
                        success = PatientDB.deleteById(id);
                        break;

                    default:
                        System.out.println("Invalid role: " + roleParam);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Redirect back to dashboard with message
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=delete_failed");
        }
    }
}