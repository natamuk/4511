package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/doctor/search")
public class DoctorSearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"doctor".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        LoginUser user = (LoginUser) session.getAttribute("loginUser");
        Long doctorId = user.getId();
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";

        DoctorDashboardServlet dash = new DoctorDashboardServlet();
        Map<String, Object> profile = dash.getStaffProfile(doctorId);
        List<Map<String, Object>> searchResults = searchPatients(doctorId, keyword);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("searchResults", searchResults);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("/doctor/search.jsp").forward(request, response);
    }

    private List<Map<String, Object>> searchPatients(Long doctorId, String keyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) return list;
        String sql = "SELECT DISTINCT p.id, p.real_name AS name, p.phone, p.email " +
                "FROM patient p LEFT JOIN registration r ON p.id = r.patient_id " +
                "WHERE (p.real_name LIKE ? OR p.phone LIKE ? OR p.id_card LIKE ?) " +
                "AND (r.doctor_id = ? OR r.doctor_id IS NULL) ORDER BY p.real_name LIMIT 20";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + keyword.trim() + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setLong(4, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("name", rs.getString("name"));
                    row.put("phone", rs.getString("phone"));
                    row.put("email", rs.getString("email"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}