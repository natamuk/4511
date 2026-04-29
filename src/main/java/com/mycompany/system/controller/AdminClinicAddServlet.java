package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.ClinicBean;
import com.mycompany.system.db.ClinicDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/clinic/add")
public class AdminClinicAddServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        // 权限检查
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String name = request.getParameter("name");
        String location = request.getParameter("location");
        if (name == null || name.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Clinic name is required");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        ClinicBean clinic = new ClinicBean();
        clinic.setClinicName(name.trim());
        clinic.setLocation(location != null ? location.trim() : "");
        clinic.setStatus(1); // 默认启用
        clinic.setSortNum(0);

        boolean success = ClinicDB.insert(clinic);
        result.put("success", success);
        result.put("message", success ? "Clinic added successfully" : "Failed to add clinic");
        response.getWriter().write(gson.toJson(result));
    }
}