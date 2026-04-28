/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.db;

import com.mycompany.system.bean.AdminBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AdminDB {

    public static AdminBean getById(Long id) {
        String sql = "SELECT id, username, password, real_name, phone, email, status, create_time, update_time FROM admin WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public static AdminBean login(String username, String password) {
        String sql = "SELECT * FROM admin WHERE username = ? AND password = ? AND status = 1";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
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

    public static List<AdminBean> getAll() {
        List<AdminBean> list = new ArrayList<>();
        String sql = "SELECT * FROM admin ORDER BY id DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean insert(AdminBean admin) {
        String sql = "INSERT INTO admin (username, password, real_name, phone, email, status, create_time, update_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, admin.getUsername());
            ps.setString(2, admin.getPassword());
            ps.setString(3, admin.getRealName());
            ps.setString(4, admin.getPhone());
            ps.setString(5, admin.getEmail());
            ps.setInt(6, admin.getStatus());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        admin.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(AdminBean admin) {
        String sql = "UPDATE admin SET real_name=?, phone=?, email=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, admin.getRealName());
            ps.setString(2, admin.getPhone());
            ps.setString(3, admin.getEmail());
            ps.setLong(4, admin.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean updatePassword(Long id, String newPassword) {
        String sql = "UPDATE admin SET password=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean disable(Long id) {
        String sql = "UPDATE admin SET status=0, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private static AdminBean mapRow(ResultSet rs) throws SQLException {
        AdminBean a = new AdminBean();
        a.setId(rs.getLong("id"));
        a.setUsername(rs.getString("username"));
        a.setPassword(rs.getString("password"));
        a.setRealName(rs.getString("real_name"));
        a.setPhone(rs.getString("phone"));
        a.setEmail(rs.getString("email"));
        a.setStatus(rs.getInt("status"));
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) {
            a.setCreateTime(ct.toLocalDateTime());
        }
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) {
            a.setUpdateTime(ut.toLocalDateTime());
        }
        return a;
    }

    public static List<AdminBean> search(String keyword) {
        List<AdminBean> list = new ArrayList<>();
        String sql = "SELECT * FROM admin WHERE real_name LIKE ? OR username LIKE ? OR phone LIKE ? OR email LIKE ? ORDER BY id DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);

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

    public static boolean deleteById(Long id) {
        boolean deleted = false;
        if (id == 1) {
            System.out.println("⚠️ Cannot delete default admin (ID: " + id + ")");
            return false;
        }
        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps1 = conn.prepareStatement(
                    "DELETE FROM notice WHERE publisher_id = ? AND publisher_type = 1")) {
                ps1.setLong(1, id);
                ps1.executeUpdate();
            }
            try (PreparedStatement ps2 = conn.prepareStatement(
                    "DELETE FROM admin WHERE id = ?")) {
                ps2.setLong(1, id);
                int rows = ps2.executeUpdate();
                deleted = (rows > 0);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return deleted;
    }

}
