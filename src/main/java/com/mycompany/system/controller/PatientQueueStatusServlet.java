/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.dao.PatientDashboardDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/patient/queue/status")
public class PatientQueueStatusServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        PatientDashboardDao dao = new PatientDashboardDao();
        boolean enabled = dao.isWalkinQueueEnabled();
        List<Map<String, Object>> clinics = enabled ? dao.getAvailableWalkinClinics() : List.of();

        Map<String, Object> result = new HashMap<>();
        result.put("enabled", enabled);
        result.put("clinics", clinics);

        response.setContentType("application/json");
        gson.toJson(result, response.getWriter());
    }
}