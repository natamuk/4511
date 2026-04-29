package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/doctor/checkin-page")
public class DoctorCheckinPageServlet extends HttpServlet {
    // 注意：原来的 @WebServlet("/doctor/checkin") 用于POST签到，所以此页面映射到 /doctor/checkin-page
    // 但在原 JSP 中，您需要修改链接为 /doctor/checkin-page。若想直接使用 /doctor/checkin 作为 GET，
    // 请删除原 DoctorCheckinServlet 或修改其注解。
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
        List<Map<String, Object>> consultations = getPendingConsultations(doctorId);

        request.setAttribute("staffProfile", profile);
        request.setAttribute("pendingConsultations", consultations);
        request.getRequestDispatcher("/doctor/checkin.jsp").forward(request, response);
    }

    private List<Map<String, Object>> getPendingConsultations(Long doctorId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT r.id, r.reg_no AS ticketNo, p.real_name AS patient, dep.dept_name AS service, r.status AS statusCode, 'REG' AS source " +
                "FROM registration r JOIN patient p ON r.patient_id = p.id JOIN department dep ON r.department_id = dep.id " +
                "WHERE r.doctor_id = ? AND r.status IN (3,4) AND r.reg_date = CURDATE() " +
                "UNION " +
                "SELECT q.id, q.queue_no AS ticketNo, p.real_name AS patient, c.clinic_name AS service, " +
                "CASE q.status WHEN 'called' THEN 3 WHEN 'consulting' THEN 4 ELSE 1 END AS statusCode, 'QUEUE' AS source " +
                "FROM queue q JOIN patient p ON q.patient_id = p.id JOIN clinic c ON q.clinic_id = c.id " +
                "WHERE (q.doctor_id = ? OR q.doctor_id IS NULL) AND q.status IN ('called','consulting')";
        try (java.sql.Connection conn = com.mycompany.system.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, doctorId);
            ps.setLong(2, doctorId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new java.util.HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("ticketNo", rs.getString("ticketNo"));
                    row.put("patient", rs.getString("patient"));
                    row.put("service", rs.getString("service"));
                    row.put("statusCode", rs.getInt("statusCode"));
                    row.put("source", rs.getString("source"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}