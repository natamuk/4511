package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/doctor/myAppointments")
public class DoctorMyAppointmentsServlet extends HttpServlet {

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
        List<Map<String, Object>> myAppointments = getMyAppointments(doctorId);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("myAppointments", myAppointments);
        request.getRequestDispatcher("/doctor/myAppointments.jsp").forward(request, response);
    }

    private List<Map<String, Object>> getMyAppointments(Long doctorId) {
        String sql = "SELECT r.id, r.reg_date, r.reg_no AS ticketNo, r.queue_no, r.status, " +
                "p.real_name AS patient, dep.dept_name AS service, s.time_slot " +
                "FROM registration r JOIN patient p ON r.patient_id = p.id " +
                "JOIN department dep ON r.department_id = dep.id " +
                "LEFT JOIN schedule s ON r.schedule_id = s.id " +
                "WHERE r.doctor_id = ? AND r.reg_date >= CURDATE() ORDER BY r.reg_date, r.queue_no";
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
                    row.put("statusCode", rs.getInt("status"));
                    row.put("status", statusToText(rs.getInt("status")));
                    row.put("queueNo", rs.getInt("queue_no"));
                    row.put("timeSlot", rs.getInt("time_slot") == 1 ? "Morning" : (rs.getInt("time_slot") == 2 ? "Afternoon" : "Evening"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private String statusToText(int status) {
        switch (status) {
            case 1: return "Booked";
            case 3: return "Called";
            case 4: return "Consulting";
            case 5: return "Completed";
            default: return "Unknown";
        }
    }
}