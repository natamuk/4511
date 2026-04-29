package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/doctor/appointments")
public class DoctorAppointmentsServlet extends HttpServlet {

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

        DoctorDashboardServlet dash = new DoctorDashboardServlet();
        Map<String, Object> profile = dash.getStaffProfile(doctorId);
        List<Map<String, Object>> appointments = getPendingAppointments(doctorId);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("appointments", appointments);
        request.getRequestDispatcher("/doctor/appointments.jsp").forward(request, response);
    }

    private List<Map<String, Object>> getPendingAppointments(Long doctorId) {
        String sql = "SELECT r.id, r.reg_date, r.reg_no AS ticketNo, p.real_name AS patient, dep.dept_name AS service, r.status AS statusCode " +
                "FROM registration r JOIN patient p ON r.patient_id = p.id JOIN department dep ON r.department_id = dep.id " +
                "WHERE r.doctor_id = ? AND r.status = 1 AND r.reg_date >= CURDATE() ORDER BY r.reg_date, r.queue_no";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("date", rs.getDate("reg_date"));
                    row.put("ticketNo", rs.getString("ticketNo"));
                    row.put("patient", rs.getString("patient"));
                    row.put("service", rs.getString("service"));
                    row.put("statusCode", rs.getInt("statusCode"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}