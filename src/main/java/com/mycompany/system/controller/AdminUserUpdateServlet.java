/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.AdminDB;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/user/update")
public class AdminUserUpdateServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        String type = request.getParameter("type");
        String realName = request.getParameter("realName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String title = request.getParameter("title");
        String genderStr = request.getParameter("gender");
        String departmentIdStr = request.getParameter("departmentId");
        String address = request.getParameter("address");

        if (idStr == null || type == null) {
            request.setAttribute("error", "Missing required parameters");
            request.getRequestDispatcher("/admin/edit.jsp").forward(request, response);
            return;
        }

        boolean success = false;

        try {
            Long id = Long.parseLong(idStr);

            if ("doctor".equalsIgnoreCase(type)) {
                DoctorBean d = new DoctorBean();
                d.setId(id);
                d.setRealName(realName);
                d.setPhone(phone);
                d.setEmail(email);
                d.setTitle(title);
                if (genderStr != null && !genderStr.isBlank()) {
                    d.setGender(Integer.parseInt(genderStr));
                }
                if (departmentIdStr != null && !departmentIdStr.isBlank()) {
                    d.setDepartmentId(Long.parseLong(departmentIdStr));
                }
                success = DoctorDB.update(d);

            } else if ("patient".equalsIgnoreCase(type)) {
                PatientBean p = new PatientBean();
                p.setId(id);
                p.setRealName(realName);
                p.setPhone(phone);
                p.setEmail(email);
                p.setAddress(address);
                if (genderStr != null && !genderStr.isBlank()) {
                    p.setGender(Integer.parseInt(genderStr));
                }
                success = PatientDB.update(p);

            } else if ("admin".equalsIgnoreCase(type)) {
                AdminBean a = new AdminBean();
                a.setId(id);
                a.setRealName(realName);
                a.setPhone(phone);
                a.setEmail(email);
                success = AdminDB.update(a);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (success) {
            // Redirect on success (as you requested)
            response.sendRedirect(request.getContextPath() + "/admin/users.jsp");
        } else {
            // Show error on edit page
            request.setAttribute("error", "Update failed. Please try again.");
            request.getRequestDispatcher("/admin/edit.jsp").forward(request, response);
        }
    }
}