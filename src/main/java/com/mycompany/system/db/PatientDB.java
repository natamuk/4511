/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.db;

import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PatientDB {

    public static PatientBean getById(Long id) {
        String sql = "SELECT id, username, password, real_name, phone, email, id_card, birthday, address, avatar, balance, status, create_time, update_time FROM patient WHERE id = ?";
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

    public static PatientBean login(String username, String password) {
        String sql = "SELECT * FROM patient WHERE username = ? AND password = ? AND status = 1";
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

    public static List<PatientBean> getAll() {
        List<PatientBean> list = new ArrayList<>();
        String sql = "SELECT * FROM patient ORDER BY id DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean insert(PatientBean patient) {
        String sql = "INSERT INTO patient (username, password, real_name, gender, phone, email, id_card, birthday, address, avatar, balance, status, create_time, update_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, patient.getUsername());
            ps.setString(2, patient.getPassword());
            ps.setString(3, patient.getRealName());
            ps.setInt(4, patient.getGender());
            ps.setString(5, patient.getPhone());
            ps.setString(6, patient.getEmail());
            ps.setString(7, patient.getIdCard());
            ps.setObject(8, patient.getBirthday());
            ps.setString(9, patient.getAddress());
            ps.setString(10, patient.getAvatar());
            ps.setBigDecimal(11, patient.getBalance());
            ps.setInt(12, patient.getStatus());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        patient.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(PatientBean patient) {
        String sql = "UPDATE patient SET real_name=?, phone=?, email=?, address=?, avatar=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patient.getRealName());
            ps.setString(2, patient.getPhone());
            ps.setString(3, patient.getEmail());
            ps.setString(4, patient.getAddress());
            ps.setString(5, patient.getAvatar());
            ps.setLong(6, patient.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean updatePassword(Long id, String newPassword) {
        String sql = "UPDATE patient SET password=?, update_time=NOW() WHERE id=?";
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
        String sql = "UPDATE patient SET status=0, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<PatientBean> search(String keyword, int limit) {
        List<PatientBean> list = new ArrayList<>();
        String sql = "SELECT * FROM patient WHERE real_name LIKE ? OR phone LIKE ? OR id_card LIKE ? LIMIT ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setInt(4, limit);
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

    private static PatientBean mapRow(ResultSet rs) throws SQLException {
        PatientBean p = new PatientBean();
        p.setId(rs.getLong("id"));
        p.setUsername(rs.getString("username"));
        p.setPassword(rs.getString("password"));
        p.setRealName(rs.getString("real_name"));
        p.setPhone(rs.getString("phone"));
        p.setEmail(rs.getString("email"));
        p.setIdCard(rs.getString("id_card"));
        Date birthday = rs.getDate("birthday");
        if (birthday != null) {
            p.setBirthday(birthday.toLocalDate());
        }
        p.setAddress(rs.getString("address"));
        p.setAvatar(rs.getString("avatar"));
        p.setBalance(rs.getBigDecimal("balance"));
        p.setStatus(rs.getInt("status"));
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) {
            p.setCreateTime(ct.toLocalDateTime());
        }
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) {
            p.setUpdateTime(ut.toLocalDateTime());
        }
        return p;
    }
    
    
    public static boolean deleteById(Long id) {
        boolean deleted = false;
        String sql = "DELETE FROM patient WHERE id = ?";

        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            int rows = ps.executeUpdate();
            deleted = (rows > 0);

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return deleted;
    }
    
}
