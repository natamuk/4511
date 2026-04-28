package com.mycompany.system.db;

import com.mycompany.system.bean.DepartmentBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDB {

    public static DepartmentBean getById(Long id) {
        String sql = "SELECT * FROM department WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<DepartmentBean> getAll() {
        List<DepartmentBean> list = new ArrayList<>();
        String sql = "SELECT * FROM department ORDER BY sort_num ASC, id ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean insert(DepartmentBean dept) {
        String sql = "INSERT INTO department "
                   + "(dept_name, dept_code, description, status, sort_num, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, dept.getDeptName());
            ps.setString(2, dept.getDeptCode());
            ps.setString(3, dept.getDescription());
            ps.setInt(4, dept.getStatus() != null ? dept.getStatus() : 1);
            ps.setInt(5, dept.getSortNum() != null ? dept.getSortNum() : 0);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        dept.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(DepartmentBean dept) {
        String sql = "UPDATE department SET dept_name=?, dept_code=?, description=?, "
                   + "status=?, sort_num=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, dept.getDeptName());
            ps.setString(2, dept.getDeptCode());
            ps.setString(3, dept.getDescription());
            ps.setInt(4, dept.getStatus() != null ? dept.getStatus() : 1);
            ps.setInt(5, dept.getSortNum() != null ? dept.getSortNum() : 0);
            ps.setLong(6, dept.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM department WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<DepartmentBean> search(String keyword) {
        List<DepartmentBean> list = new ArrayList<>();
        String sql = "SELECT * FROM department WHERE dept_name LIKE ? OR dept_code LIKE ? "
                   + "OR description LIKE ? ORDER BY sort_num ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private static DepartmentBean mapRow(ResultSet rs) throws SQLException {
        DepartmentBean d = new DepartmentBean();
        d.setId(rs.getLong("id"));
        d.setDeptName(rs.getString("dept_name"));
        d.setDeptCode(rs.getString("dept_code"));
        d.setDescription(rs.getString("description"));
        d.setStatus(rs.getInt("status"));
        d.setSortNum(rs.getInt("sort_num"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) d.setCreateTime(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) d.setUpdateTime(ut.toLocalDateTime());
        
        return d;
    }
}