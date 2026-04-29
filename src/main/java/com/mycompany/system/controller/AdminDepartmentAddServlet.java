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

@WebServlet("/admin/department/add")
public class AdminDepartmentAddServlet extends HttpServlet {
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

        String name = request.getParameter("name");
        String code = request.getParameter("code");
        String desc = request.getParameter("desc");

        if (name == null || name.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Department name required");
            response.getWriter().write(gson.toJson(result));
            return;
        }

        DepartmentBean dept = new DepartmentBean();
        dept.setDeptName(name.trim());
        dept.setDeptCode(code != null ? code.trim() : "");
        dept.setDescription(desc != null ? desc.trim() : "");
        dept.setStatus(1);

        boolean success = DepartmentDB.add(dept);
        result.put("success", success);
        result.put("message", success ? "Service added" : "Add failed");
        response.getWriter().write(gson.toJson(result));
    }
}