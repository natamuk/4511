package com.mycompany.system.dao;

import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.*;

public class ReportDAO {
    public List<Map<String,Object>> getClinicUsage() {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT c.clinic_name, COUNT(r.id) AS used_slots, COALESCE(SUM(cts.capacity),0) AS total_capacity, " +
                     "ROUND(IFNULL(COUNT(r.id)*100.0 / NULLIF(SUM(cts.capacity),0),0),2) AS rate " +
                     "FROM clinic c LEFT JOIN clinic_time_slot cts ON c.id=cts.clinic_id " +
                     "LEFT JOIN registration r ON c.id=r.clinic_id AND r.status NOT IN (2) " +
                     "GROUP BY c.id";
        try (Connection conn = DBUtil.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("clinic_name", rs.getString("clinic_name"));
                row.put("used_slots", rs.getInt("used_slots"));
                row.put("total_capacity", rs.getInt("total_capacity"));
                row.put("rate", rs.getDouble("rate"));
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String,Object>> getDepartmentStats() {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT d.dept_name, COUNT(r.id) AS booking_count FROM department d LEFT JOIN registration r ON d.id=r.department_id GROUP BY d.id";
        try (Connection conn = DBUtil.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("dept_name", rs.getString("dept_name"));
                row.put("booking_count", rs.getInt("booking_count"));
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String,Object>> getMonthlyTrend() {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(reg_date, '%Y-%m') AS month, COUNT(*) AS total FROM registration GROUP BY month ORDER BY month";
        try (Connection conn = DBUtil.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("month", rs.getString("month"));
                row.put("total", rs.getInt("total"));
                list.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int getNoShowCount() {
        String sql = "SELECT COUNT(*) FROM registration WHERE status=2";
        try (Connection conn = DBUtil.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getCancellationCount() {
        String sql = "SELECT COUNT(*) FROM registration WHERE status=2";
        try (Connection conn = DBUtil.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
}