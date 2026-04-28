package com.mycompany.system.db;

import com.mycompany.system.bean.ClinicTimeSlotBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClinicTimeSlotDB {

    public static ClinicTimeSlotBean getById(Long id) {
        String sql = "SELECT * FROM clinic_time_slot WHERE id = ?";
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

    public static List<ClinicTimeSlotBean> getAll() {
        List<ClinicTimeSlotBean> list = new ArrayList<>();
        String sql = "SELECT * FROM clinic_time_slot ORDER BY clinic_id, period, slot_time";
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

    public static boolean insert(ClinicTimeSlotBean slot) {
        String sql = "INSERT INTO clinic_time_slot "
                   + "(clinic_id, period, slot_time, capacity, status, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, slot.getClinicId());
            ps.setString(2, slot.getPeriod());
            ps.setString(3, slot.getSlotTime());
            ps.setInt(4, slot.getCapacity() != null ? slot.getCapacity() : 5);
            ps.setInt(5, slot.getStatus() != null ? slot.getStatus() : 1);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        slot.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(ClinicTimeSlotBean slot) {
        String sql = "UPDATE clinic_time_slot SET clinic_id=?, period=?, slot_time=?, "
                   + "capacity=?, status=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, slot.getClinicId());
            ps.setString(2, slot.getPeriod());
            ps.setString(3, slot.getSlotTime());
            ps.setInt(4, slot.getCapacity() != null ? slot.getCapacity() : 5);
            ps.setInt(5, slot.getStatus() != null ? slot.getStatus() : 1);
            ps.setLong(6, slot.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM clinic_time_slot WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<ClinicTimeSlotBean> search(String keyword) {
        List<ClinicTimeSlotBean> list = new ArrayList<>();
        String sql = "SELECT * FROM clinic_time_slot WHERE period LIKE ? OR slot_time LIKE ? ORDER BY clinic_id, period";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            
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

    private static ClinicTimeSlotBean mapRow(ResultSet rs) throws SQLException {
        ClinicTimeSlotBean s = new ClinicTimeSlotBean();
        s.setId(rs.getLong("id"));
        s.setClinicId(rs.getLong("clinic_id"));
        s.setPeriod(rs.getString("period"));
        s.setSlotTime(rs.getString("slot_time"));
        s.setCapacity(rs.getInt("capacity"));
        s.setStatus(rs.getInt("status"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) s.setCreateTime(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) s.setUpdateTime(ut.toLocalDateTime());
        
        return s;
    }
}