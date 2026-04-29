package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.db.DepartmentDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/department/delete")
public class AdminDepartmentDeleteServlet extends HttpServlet {
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
            result.put("message", "Missing department id");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            boolean success = DepartmentDB.delete(id);
            result.put("success", success);
            result.put("message", success ? "Service deleted" : "Delete failed");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Invalid id");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Server error");
        }
        response.getWriter().write(gson.toJson(result));
    }
}