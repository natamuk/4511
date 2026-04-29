package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/profile")
public class DoctorProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"doctor".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = loginUser.getId();

        // 获取医生完整资料（复用 Dashboard 中的方法或直接查询）
        Map<String, Object> staffProfile = getStaffProfile(doctorId);

        request.setAttribute("staffProfile", staffProfile);
        request.getRequestDispatcher("/doctor/profile.jsp").forward(request, response);
    }

    /**
     * 从数据库获取医生的完整资料（包括姓名、职称、科室、电话、邮箱等）
     */
    private Map<String, Object> getStaffProfile(Long doctorId) {
        String sql = "SELECT d.id, d.username, d.real_name, d.phone, d.email, d.title, d.avatar, " +
                     "d.department_id, dept.dept_name AS department_name " +
                     "FROM doctor d " +
                     "JOIN department dept ON d.department_id = dept.id " +
                     "WHERE d.id = ?";

        Map<String, Object> profile = new HashMap<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    profile.put("id", rs.getLong("id"));
                    profile.put("username", rs.getString("username"));
                    profile.put("realName", rs.getString("real_name"));
                    profile.put("phone", rs.getString("phone"));
                    profile.put("email", rs.getString("email"));
                    profile.put("title", rs.getString("title"));
                    profile.put("avatar", rs.getString("avatar"));
                    profile.put("departmentId", rs.getLong("department_id"));
                    profile.put("departmentName", rs.getString("department_name"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return profile;
    }
}