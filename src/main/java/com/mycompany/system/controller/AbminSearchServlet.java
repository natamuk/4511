/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.DoctorDB;
import com.mycompany.system.db.PatientDB;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 *
 * @author USER
 */
@WebServlet(name = "AbminSearchServlet", urlPatterns = {"/AbminSearchServlet"})
public class AbminSearchServlet extends HttpServlet {

    @Override
    public void init() {
        List<DoctorBean> doctorList = DoctorDB.getAll();
        List<PatientBean> patientList = PatientDB.getAll();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String docSearch = request.getParameter("docSearchInput");
        String patSearch = request.getParameter("patSearchInput");

        List<DoctorBean> doctorList = DoctorDB.getAll();
        if (docSearch != null && !docSearch.trim().isEmpty()) {
            String keyword = docSearch.toLowerCase();
            doctorList = doctorList.stream()
                    .filter(d -> Objects.toString(d.getRealName(), "").toLowerCase().contains(keyword)
                    || Objects.toString(d.getPhone(), "").toLowerCase().contains(keyword)
                    || Objects.toString(d.getEmail(), "").toLowerCase().contains(keyword))
                    .collect(Collectors.toList());
        }
        request.setAttribute("doctorUsers", doctorList);

        List<PatientBean> patientList = PatientDB.getAll();
        if (patSearch != null && !patSearch.trim().isEmpty()) {
            String keyword = patSearch.toLowerCase();
            patientList = patientList.stream()
                    .filter(p -> Objects.toString(p.getRealName(), "").toLowerCase().contains(keyword)
                    || Objects.toString(p.getPhone(), "").toLowerCase().contains(keyword)
                    || Objects.toString(p.getEmail(), "").toLowerCase().contains(keyword))
                    .collect(Collectors.toList());
        }
        request.setAttribute("patientUsers", patientList);

        request.getRequestDispatcher("/admin/contents/users-contents.jsp").forward(request, response);
    }

}
