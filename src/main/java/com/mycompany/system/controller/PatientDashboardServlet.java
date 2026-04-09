/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/patient/dashboard")
public class PatientDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();

        request.setAttribute("patientProfile", getPatientProfile(patientId));
        request.setAttribute("appointments", getAppointments(patientId));
        request.setAttribute("notifications", getNotifications());
        request.setAttribute("records", getMedicalRecords(patientId));
        request.setAttribute("clinics", getClinics());
        request.setAttribute("clinicSlots", getClinicSlots());
        request.setAttribute("queue", getQueue(patientId));
        request.setAttribute("favorites", getFavorites(patientId));
        request.setAttribute("clinicQueueCount", getClinicQueueCount());

        request.getRequestDispatcher("/patient/home.jsp").forward(request, response);
    }

    private Map<String, Object> getPatientProfile(Long patientId) {
        String sql =
                "SELECT p.id, p.username, p.real_name, p.phone, p.email, p.id_card, p.birthday, p.address, p.avatar, p.balance " +
                "FROM patient p WHERE p.id = ?";

        Map<String, Object> profile = new HashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, patientId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    profile.put("id", rs.getLong("id"));
                    profile.put("username", rs.getString("username"));
                    profile.put("realName", rs.getString("real_name"));
                    profile.put("phone", rs.getString("phone"));
                    profile.put("email", rs.getString("email"));
                    profile.put("idCard", rs.getString("id_card"));
                    profile.put("birthday", rs.getDate("birthday"));
                    profile.put("address", rs.getString("address"));
                    profile.put("avatar", rs.getString("avatar"));
                    profile.put("balance", rs.getBigDecimal("balance"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return profile;
    }

    private List<Map<String, Object>> getAppointments(Long patientId) {
        String sql =
                "SELECT r.id, r.reg_no, r.reg_date, r.queue_no, r.fee, r.status, r.cancel_time, r.call_time, " +
                "d.real_name AS doctor_name, d.title AS doctor_title, dep.dept_name AS department_name, " +
                "s.time_slot, s.schedule_date " +
                "FROM registration r " +
                "JOIN doctor d ON r.doctor_id = d.id " +
                "JOIN department dep ON r.department_id = dep.id " +
                "JOIN schedule s ON r.schedule_id = s.id " +
                "WHERE r.patient_id = ? " +
                "ORDER BY r.reg_date DESC, r.queue_no ASC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, patientId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("regNo", rs.getString("reg_no"));
                    row.put("date", rs.getDate("reg_date"));
                    row.put("queueNo", rs.getInt("queue_no"));
                    row.put("fee", rs.getBigDecimal("fee"));
                    row.put("statusCode", rs.getInt("status"));
                    row.put("status", regStatusToText(rs.getInt("status")));
                    row.put("cancelTime", rs.getTimestamp("cancel_time"));
                    row.put("callTime", rs.getTimestamp("call_time"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("doctorTitle", rs.getString("doctor_title"));
                    row.put("departmentName", rs.getString("department_name"));
                    row.put("timeSlot", rs.getString("time_slot"));
                    row.put("scheduleDate", rs.getDate("schedule_date"));
                    row.put("clinicName", ""); // 無 clinic_id 關聯，先留空避免錯誤資料
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private List<Map<String, Object>> getNotifications() {
        String sql =
                "SELECT id, title, content, publish_time " +
                "FROM notice " +
                "WHERE status = 1 " +
                "ORDER BY publish_time DESC, create_time DESC " +
                "LIMIT 10";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("title", rs.getString("title"));
                row.put("message", rs.getString("content"));
                row.put("time", rs.getTimestamp("publish_time"));
                row.put("type", "info");
                row.put("read", false);
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private List<Map<String, Object>> getMedicalRecords(Long patientId) {
        String sql =
                "SELECT c.id, c.diagnosis, c.medical_advice, c.prescription, c.consultation_time, " +
                "d.real_name AS doctor_name, dep.dept_name AS department_name " +
                "FROM consultation c " +
                "JOIN doctor d ON c.doctor_id = d.id " +
                "JOIN registration r ON c.registration_id = r.id " +
                "JOIN department dep ON r.department_id = dep.id " +
                "WHERE c.patient_id = ? " +
                "ORDER BY c.consultation_time DESC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, patientId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("diagnosis", rs.getString("diagnosis"));
                    row.put("medicalAdvice", rs.getString("medical_advice"));
                    row.put("prescription", rs.getString("prescription"));
                    row.put("consultationTime", rs.getTimestamp("consultation_time"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("departmentName", rs.getString("department_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private List<Map<String, Object>> getClinics() {
        String sql =
                "SELECT id, clinic_name, location, description " +
                "FROM clinic " +
                "WHERE status = 1 " +
                "ORDER BY sort_num ASC, id ASC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("name", rs.getString("clinic_name"));
                row.put("location", rs.getString("location"));
                row.put("description", rs.getString("description"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private Map<Long, List<Map<String, Object>>> getClinicSlots() {
        String sql =
                "SELECT clinic_id, period, slot_time, capacity " +
                "FROM clinic_time_slot " +
                "WHERE status = 1 " +
                "ORDER BY clinic_id ASC, period ASC, slot_time ASC";

        Map<Long, List<Map<String, Object>>> map = new HashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Long clinicId = rs.getLong("clinic_id");
                Map<String, Object> slot = new HashMap<>();
                slot.put("period", rs.getString("period"));
                slot.put("slotTime", rs.getString("slot_time"));
                slot.put("capacity", rs.getInt("capacity"));

                map.computeIfAbsent(clinicId, k -> new ArrayList<>()).add(slot);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    private Map<Long, Integer> getClinicQueueCount() {
        String sql = "SELECT clinic_id, COUNT(*) AS cnt FROM queue WHERE status = 'waiting' GROUP BY clinic_id";
        Map<Long, Integer> map = new HashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                map.put(rs.getLong("clinic_id"), rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    private List<Map<String, Object>> getQueue(Long patientId) {
        String sql =
                "SELECT q.id, q.queue_no, q.status, q.called_time, q.created_time, " +
                "c.clinic_name, d.real_name AS doctor_name " +
                "FROM queue q " +
                "JOIN clinic c ON q.clinic_id = c.id " +
                "LEFT JOIN doctor d ON q.doctor_id = d.id " +
                "WHERE q.patient_id = ? " +
                "ORDER BY q.created_time DESC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, patientId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("queueNo", rs.getString("queue_no"));
                    row.put("statusCode", rs.getString("status"));
                    row.put("status", rs.getString("status"));
                    row.put("calledTime", rs.getTimestamp("called_time"));
                    row.put("createdTime", rs.getTimestamp("created_time"));
                    row.put("clinicName", rs.getString("clinic_name"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private List<Map<String, Object>> getFavorites(Long patientId) {
        String sql =
                "SELECT pfc.id, pfc.clinic_id, c.clinic_name, c.description " +
                "FROM patient_favorite_clinic pfc " +
                "JOIN clinic c ON pfc.clinic_id = c.id " +
                "WHERE pfc.patient_id = ? " +
                "ORDER BY pfc.created_at DESC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, patientId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("clinicId", rs.getLong("clinic_id"));
                    row.put("clinicName", rs.getString("clinic_name"));
                    row.put("description", rs.getString("description"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private String regStatusToText(int status) {
        switch (status) {
            case 1: return "Booked";
            case 2: return "Cancelled";
            case 3: return "Called";
            case 4: return "Consulting";
            case 5: return "Completed";
            case 6: return "Transferred";
            default: return "Unknown";
        }
    }
}