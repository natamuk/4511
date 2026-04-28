package com.mycompany.system.db;

import com.mycompany.system.bean.ClinicBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClinicDB {

    public static ClinicBean getById(Long id) {
        String sql = "SELECT * FROM clinic WHERE id = ?";
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

    public static List<ClinicBean> getAll() {
        List<ClinicBean> list = new ArrayList<>();
        String sql = "SELECT * FROM clinic ORDER BY sort_num ASC, id ASC";
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

    public static boolean insert(ClinicBean clinic) {
        String sql = "INSERT INTO clinic (clinic_name, location, description, status, sort_num, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, clinic.getClinicName());
            ps.setString(2, clinic.getLocation());
            ps.setString(3, clinic.getDescription());
            ps.setInt(4, clinic.getStatus() != null ? clinic.getStatus() : 1);
            ps.setInt(5, clinic.getSortNum() != null ? clinic.getSortNum() : 0);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        clinic.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(ClinicBean clinic) {
        String sql = "UPDATE clinic SET clinic_name=?, location=?, description=?, status=?, sort_num=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, clinic.getClinicName());
            ps.setString(2, clinic.getLocation());
            ps.setString(3, clinic.getDescription());
            ps.setInt(4, clinic.getStatus() != null ? clinic.getStatus() : 1);
            ps.setInt(5, clinic.getSortNum() != null ? clinic.getSortNum() : 0);
            ps.setLong(6, clinic.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM clinic WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<ClinicBean> search(String keyword) {
        List<ClinicBean> list = new ArrayList<>();
        String sql = "SELECT * FROM clinic WHERE clinic_name LIKE ? OR location LIKE ? OR description LIKE ? ORDER BY sort_num ASC";
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

    private static ClinicBean mapRow(ResultSet rs) throws SQLException {
        ClinicBean c = new ClinicBean();
        c.setId(rs.getLong("id"));
        c.setClinicName(rs.getString("clinic_name"));
        c.setLocation(rs.getString("location"));
        c.setDescription(rs.getString("description"));
        c.setStatus(rs.getInt("status"));
        c.setSortNum(rs.getInt("sort_num"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) c.setCreateTime(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) c.setUpdateTime(ut.toLocalDateTime());
        
        return c;
    }
}