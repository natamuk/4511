package com.mycompany.system.dao;

import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.*;

public class AbnormalDAO {
    public List<Map<String,Object>> getRepeatNoShow(int threshold) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT p.real_name AS patient_name, p.phone, COUNT(r.id) AS no_show_count " +
                     "FROM patient p JOIN registration r ON p.id=r.patient_id WHERE r.status=2 " +
                     "GROUP BY p.id HAVING COUNT(r.id) >= ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("patient_name", rs.getString("patient_name"));
                    row.put("phone", rs.getString("phone"));
                    row.put("no_show_count", rs.getInt("no_show_count"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String,Object>> getFrequentCancel(int minCount, int days) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT p.real_name AS patient_name, COUNT(r.id) AS cancel_count, MAX(r.cancel_time) AS last_cancel_date " +
                     "FROM patient p JOIN registration r ON p.id=r.patient_id WHERE r.status=2 AND r.cancel_time > DATE_SUB(NOW(), INTERVAL ? DAY) " +
                     "GROUP BY p.id HAVING COUNT(r.id) >= ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            ps.setInt(2, minCount);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("patient_name", rs.getString("patient_name"));
                    row.put("cancel_count", rs.getInt("cancel_count"));
                    row.put("last_cancel_date", rs.getTimestamp("last_cancel_date"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String,Object>> getDoctorsWithHighNoShow(int minNoShow) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT d.real_name AS doctor_name, dep.dept_name, COUNT(r.id) AS no_show_count " +
                     "FROM doctor d JOIN department dep ON d.department_id=dep.id LEFT JOIN registration r ON d.id=r.doctor_id AND r.status=2 " +
                     "GROUP BY d.id HAVING COUNT(r.id) >= ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, minNoShow);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("doctor_name", rs.getString("doctor_name"));
                    row.put("dept_name", rs.getString("dept_name"));
                    row.put("no_show_count", rs.getInt("no_show_count"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}