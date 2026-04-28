package com.mycompany.system.controller;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminUpdateUserServlet", urlPatterns = {"/AdminUpdateUserServlet"})
public class AdminUpdateUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String roleParam = request.getParameter("role");   // doctor, patient, admin

        if (idParam == null || roleParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/userList?error=invalid");
            return;
        }

        Long id = Long.parseLong(idParam);
        boolean success = false;

        try {
            switch (roleParam.toLowerCase()) {
                case "doctor":
                    DoctorBean doctor = new DoctorBean();
                    doctor.setId(id);
                    doctor.setRealName(request.getParameter("realName"));
                    doctor.setUsername(request.getParameter("username"));
                    doctor.setPhone(request.getParameter("phone"));
                    doctor.setEmail(request.getParameter("email"));
                    doctor.setTitle(request.getParameter("title"));
                    doctor.setStatus(Integer.parseInt(request.getParameter("status")));

                    success = DoctorDB.update(doctor);
                    break;

                case "patient":
                    PatientBean patient = new PatientBean();
                    patient.setId(id);
                    patient.setRealName(request.getParameter("realName"));
                    patient.setUsername(request.getParameter("username"));
                    patient.setPhone(request.getParameter("phone"));
                    patient.setEmail(request.getParameter("email"));
                    patient.setAddress(request.getParameter("address"));
                    patient.setStatus(Integer.parseInt(request.getParameter("status")));

                    success = PatientDB.update(patient);
                    break;

                case "admin":
                    AdminBean admin = new AdminBean();
                    admin.setId(id);
                    admin.setRealName(request.getParameter("realName"));
                    admin.setUsername(request.getParameter("username"));
                    admin.setPhone(request.getParameter("phone"));
                    admin.setEmail(request.getParameter("email"));
                    admin.setStatus(Integer.parseInt(request.getParameter("status")));

                    success = AdminDB.update(admin);
                    break;

                default:
                    success = false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            success = false;
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?success=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=update_failed");
        }
    }
}