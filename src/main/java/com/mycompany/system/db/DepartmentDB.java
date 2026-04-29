package com.mycompany.system.db;

import com.mycompany.system.bean.DepartmentBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDB {
    public static List<DepartmentBean> getAll() {
        List<DepartmentBean> list = new ArrayList<>();
        String sql = "SELECT id, dept_name, dept_code, description, status FROM department WHERE status = 1 ORDER BY sort_num, id";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DepartmentBean dept = new DepartmentBean();
                dept.setId(rs.getLong("id"));
                dept.setDeptName(rs.getString("dept_name"));
                dept.setDeptCode(rs.getString("dept_code"));
                dept.setDescription(rs.getString("description"));
                dept.setStatus(rs.getInt("status"));
                list.add(dept);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public static boolean add(DepartmentBean dept) {
        String sql = "INSERT INTO department (dept_name, dept_code, description, status) VALUES (?, ?, ?, 1)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dept.getDeptName());
            ps.setString(2, dept.getDeptCode());
            ps.setString(3, dept.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public static boolean update(DepartmentBean dept) {
        String sql = "UPDATE department SET dept_name=?, dept_code=?, description=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dept.getDeptName());
            ps.setString(2, dept.getDeptCode());
            ps.setString(3, dept.getDescription());
            ps.setLong(4, dept.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public static boolean delete(long id) {
        String sql = "DELETE FROM department WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}