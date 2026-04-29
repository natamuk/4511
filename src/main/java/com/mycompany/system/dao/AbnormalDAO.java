package com.mycompany.system.dao;

import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.*;

public class AbnormalDAO {

    // Repeat no-show patients (>= threshold times)
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

    // Frequent cancellations (within last 'days' days, >= minCount times)
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

    // Doctors with high no-show count (>= minNoShow)
    public List<Map<String,Object>> getDoctorsWithHighNoShow(int minNoShow) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT d.id AS doctor_id, d.real_name AS doctor_name, dep.dept_name, COUNT(r.id) AS no_show_count " +
                     "FROM doctor d JOIN department dep ON d.department_id=dep.id " +
                     "LEFT JOIN registration r ON d.id=r.doctor_id AND r.status=2 " +
                     "GROUP BY d.id HAVING COUNT(r.id) >= ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, minNoShow);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("doctor_id", rs.getLong("doctor_id"));
                    row.put("doctor_name", rs.getString("doctor_name"));
                    row.put("dept_name", rs.getString("dept_name"));
                    row.put("no_show_count", rs.getInt("no_show_count"));
                    list.add(row);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Send warning notification to doctors with high no-show count (>=5)
    // Duplicate check within 7 days
    public void sendNotificationsForHighNoShowDoctors() {
        List<Map<String, Object>> highDoctors = getDoctorsWithHighNoShow(5);
        if (highDoctors == null || highDoctors.isEmpty()) {
            return;
        }

        String insertSql = "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) " +
                           "VALUES (?, 2, ?, ?, 'warning', 0, NOW())";
        String checkSql = "SELECT COUNT(*) FROM user_notification WHERE user_id = ? AND user_type = 2 " +
                          "AND title = ? AND create_time > DATE_SUB(NOW(), INTERVAL 7 DAY)";

        try (Connection conn = DBUtil.getConnection()) {
            for (Map<String, Object> doc : highDoctors) {
                Long doctorId = (Long) doc.get("doctor_id");
                if (doctorId == null) continue;

                Integer noShowCount = (Integer) doc.get("no_show_count");

                // Check if already notified within last 7 days
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setLong(1, doctorId);
                    psCheck.setString(2, "High no-show warning");
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            continue;
                        }
                    }
                }

                String title = "High no-show warning";
                String message = String.format("You have %d patient no-show records. Please pay attention.", noShowCount);
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setLong(1, doctorId);
                    psInsert.setString(2, title);
                    psInsert.setString(3, message);
                    psInsert.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}