/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
/*
 */
package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.dao.AdminDashboardDao;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/quota/update")
public class AdminQuotaUpdateServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "Unauthorized");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        String idStr = request.getParameter("id");
        String capacityStr = request.getParameter("capacity");
        String service = request.getParameter("service");

        if (idStr == null || capacityStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing id or capacity");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            int capacity = Integer.parseInt(capacityStr);

            AdminDashboardDao dao = new AdminDashboardDao();
            boolean success = dao.updateQuota(id, capacity, service);

            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                result.put("success", true);
                result.put("message", "Allocation updated successfully");
            } else {
                result.put("success", false);
                result.put("message", "Update failed or quota does not exist.");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "ID or capacity format error");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
            e.printStackTrace();
        }

        response.getWriter().write(gson.toJson(result));
    }
}