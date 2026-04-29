/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.dao;

import com.mycompany.system.util.DBUtil;

import java.sql.*;
import java.util.*;

public class StaffDashboardDao {

public Map<String, Object> getStaffProfile(Long staffId) {
    String sql =
        "SELECT d.id, d.username, d.real_name, d.phone, d.email, d.avatar, d.status, d.title, " +
        "dep.dept_name AS departmentName, " +
        "c.clinic_name AS clinicName " +          
        "FROM doctor d " +
        "JOIN department dep ON d.department_id = dep.id " +
        "LEFT JOIN clinic c ON d.primary_clinic_id = c.id " +   
        "WHERE d.id = ?";

    Map<String, Object> profile = new HashMap<>();

    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setLong(1, staffId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                profile.put("id", rs.getLong("id"));
                profile.put("username", rs.getString("username"));
                profile.put("realName", rs.getString("real_name"));
                profile.put("phone", rs.getString("phone"));
                profile.put("email", rs.getString("email"));
                profile.put("avatar", rs.getString("avatar"));
                profile.put("status", rs.getInt("status"));
                profile.put("title", rs.getString("title"));
                profile.put("departmentName", rs.getString("departmentName"));
                profile.put("clinicName", rs.getString("clinicName"));   
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return profile;
}

    public List<Map<String, Object>> getTodayAppointments(Long staffId) {
        String sql =
                "SELECT r.id, r.reg_no, p.real_name AS patient_name, p.phone AS patient_phone, " +
                "dep.dept_name AS dept_name, r.reg_date, r.queue_no, r.status, r.call_time " +
                "FROM registration r " +
                "JOIN patient p ON r.patient_id = p.id " +
                "JOIN department dep ON r.department_id = dep.id " +
                "WHERE r.doctor_id = ? AND r.reg_date = CURDATE() " +
                "ORDER BY r.queue_no ASC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("appointmentNo", rs.getString("reg_no"));
                    row.put("patient", rs.getString("patient_name"));
                    row.put("phone", rs.getString("patient_phone"));
                    row.put("clinic", rs.getString("dept_name"));
                    row.put("service", rs.getString("dept_name"));
                    row.put("date", rs.getDate("reg_date"));
                    row.put("time", null);
                    row.put("status", rs.getInt("status"));
                    row.put("note", "");
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getQueueList(Long staffId) {
        String sql =
                "SELECT q.id, q.queue_no, p.real_name AS patient_name, p.phone AS patient_phone, " +
                "c.clinic_name, q.created_time, q.status " +
                "FROM queue q " +
                "JOIN patient p ON q.patient_id = p.id " +
                "JOIN clinic c ON q.clinic_id = c.id " +
                "WHERE q.doctor_id = ? OR q.doctor_id IS NULL " +
                "ORDER BY q.created_time ASC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("ticketNo", rs.getString("queue_no"));
                    row.put("patient", rs.getString("patient_name"));
                    row.put("phone", rs.getString("patient_phone"));
                    row.put("clinic", rs.getString("clinic_name"));
                    row.put("service", rs.getString("clinic_name"));
                    row.put("date", rs.getTimestamp("created_time"));
                    row.put("status", rs.getString("status"));
                    row.put("queueOrder", 0);
                    row.put("wait", 0);
                    row.put("updatedAt", rs.getTimestamp("created_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getNotifications(Long staffId) {
        String sql =
                "SELECT id, title, message, type, is_read, create_time " +
                "FROM user_notification " +
                "WHERE user_id = ? OR user_type IN (2, 1) " +
                "ORDER BY create_time DESC LIMIT 20";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("title", rs.getString("title"));
                    row.put("message", rs.getString("message"));
                    row.put("type", rs.getString("type"));
                    row.put("read", rs.getBoolean("is_read"));
                    row.put("time", rs.getTimestamp("create_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getIssues(Long staffId) {
        String sql =
                "SELECT id, operation, detail, create_time " +
                "FROM operation_log WHERE user_type = 2 AND user_id = ? ORDER BY create_time DESC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("type", rs.getString("operation"));
                    row.put("detail", rs.getString("detail"));
                    row.put("status", "Logged");
                    row.put("createdAt", rs.getTimestamp("create_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}