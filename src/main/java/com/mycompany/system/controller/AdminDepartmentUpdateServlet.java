package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.DepartmentBean;
import com.mycompany.system.db.DepartmentDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/department/update")
public class AdminDepartmentUpdateServlet extends HttpServlet {
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
        String name = request.getParameter("name");
        String code = request.getParameter("code");
        String desc = request.getParameter("desc");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Missing department id");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            DepartmentBean dept = new DepartmentBean();
            dept.setId(id);
            dept.setDeptName(name != null ? name.trim() : "");
            dept.setDeptCode(code != null ? code.trim() : "");
            dept.setDescription(desc != null ? desc.trim() : "");
            boolean success = DepartmentDB.update(dept);
            result.put("success", success);
            result.put("message", success ? "Service updated" : "Update failed");
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