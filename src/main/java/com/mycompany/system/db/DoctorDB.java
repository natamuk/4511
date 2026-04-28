/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.db;

import com.mycompany.system.bean.DoctorBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class DoctorDB {

    public static DoctorBean getById(Long id) {
        String sql = "SELECT id, username, password, real_name, phone, email, title, department_id, avatar, status, create_time, update_time FROM doctor WHERE id = ?";
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

    public static DoctorBean login(String username, String password) {
        String sql = "SELECT * FROM doctor WHERE username = ? AND password = ? AND status = 1";
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

    public static List<DoctorBean> getAll() {
        List<DoctorBean> list = new ArrayList<>();
        String sql = "SELECT * FROM doctor ORDER BY id DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

     public static boolean insert(DoctorBean doctor) {
        String sql = "INSERT INTO doctor "
                + "(username, password, real_name, gender, phone, email, title, "
                + "department_id, avatar, status, create_time, update_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        
        try (Connection conn = DBUtil.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, doctor.getUsername());
            ps.setString(2, doctor.getPassword());
            ps.setString(3, doctor.getRealName());
            ps.setObject(4, doctor.getGender());    
            ps.setString(5, doctor.getPhone());
            ps.setString(6, doctor.getEmail());
            ps.setString(7, doctor.getTitle());
            ps.setObject(8, doctor.getDepartmentId());
            ps.setString(9, doctor.getAvatar());
            ps.setInt(10, doctor.getStatus() != null ? doctor.getStatus() : 1);
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        doctor.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(DoctorBean doctor) {
        String sql = "UPDATE doctor SET real_name=?, phone=?, email=?, title=?, department_id=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctor.getRealName());
            ps.setString(2, doctor.getPhone());
            ps.setString(3, doctor.getEmail());
            ps.setString(4, doctor.getTitle());
            ps.setObject(5, doctor.getDepartmentId());
            ps.setLong(6, doctor.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean updatePassword(Long id, String newPassword) {
        String sql = "UPDATE doctor SET password=?, update_time=NOW() WHERE id=?";
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
        String sql = "UPDATE doctor SET status=0, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private static DoctorBean mapRow(ResultSet rs) throws SQLException {
        DoctorBean d = new DoctorBean();
        d.setId(rs.getLong("id"));
        d.setUsername(rs.getString("username"));
        d.setPassword(rs.getString("password"));
        d.setRealName(rs.getString("real_name"));
        d.setPhone(rs.getString("phone"));
        d.setEmail(rs.getString("email"));
        d.setTitle(rs.getString("title"));
        d.setDepartmentId(rs.getLong("department_id"));
        d.setAvatar(rs.getString("avatar"));
        d.setStatus(rs.getInt("status"));
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) {
            d.setCreateTime(ct.toLocalDateTime());
        }
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) {
            d.setUpdateTime(ut.toLocalDateTime());
        }
        return d;
    }

    public static boolean deleteById(Long id) {
        boolean deleted = false;
        try (Connection conn = DBUtil.getConnection()) {
  
            try (PreparedStatement ps1 = conn.prepareStatement("DELETE FROM schedule WHERE doctor_id = ?")) {
                ps1.setLong(1, id);
                ps1.executeUpdate();
            }

            try (PreparedStatement ps2 = conn.prepareStatement("DELETE FROM doctor WHERE id = ?")) {
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
