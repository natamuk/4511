package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.db.ClinicDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/clinic/delete")
public class AdminClinicDeleteServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing clinic id");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            boolean success = ClinicDB.deleteById(id);
            result.put("success", success);
            result.put("message", success ? "Clinic deleted" : "Delete failed (maybe clinic has related data?)");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Invalid id format");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
        }
        response.getWriter().write(gson.toJson(result));
    }
}