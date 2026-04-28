package com.mycompany.system.db;

import com.mycompany.system.bean.RechargeRecordBean;
import com.mycompany.system.util.DBUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RechargeRecordDB {

    public static RechargeRecordBean getById(Long id) {
        String sql = "SELECT * FROM recharge_record WHERE id = ?";
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

    public static List<RechargeRecordBean> getAll() {
        List<RechargeRecordBean> list = new ArrayList<>();
        String sql = "SELECT * FROM recharge_record ORDER BY create_time DESC";
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

    public static List<RechargeRecordBean> getByPatientId(Long patientId) {
        List<RechargeRecordBean> list = new ArrayList<>();
        String sql = "SELECT * FROM recharge_record WHERE patient_id = ? ORDER BY create_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, patientId);
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

    public static boolean insert(RechargeRecordBean record) {
        String sql = "INSERT INTO recharge_record "
                   + "(patient_id, recharge_no, amount, before_balance, after_balance, "
                   + "pay_method, status, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, record.getPatientId());
            ps.setString(2, record.getRechargeNo());
            ps.setBigDecimal(3, record.getAmount());
            ps.setBigDecimal(4, record.getBeforeBalance());
            ps.setBigDecimal(5, record.getAfterBalance());
            ps.setString(6, record.getPayMethod());
            ps.setInt(7, record.getStatus() != null ? record.getStatus() : 1);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        record.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM recharge_record WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<RechargeRecordBean> search(String keyword) {
        List<RechargeRecordBean> list = new ArrayList<>();
        String sql = "SELECT * FROM recharge_record WHERE recharge_no LIKE ? OR pay_method LIKE ? "
                   + "ORDER BY create_time DESC";
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

    private static RechargeRecordBean mapRow(ResultSet rs) throws SQLException {
        RechargeRecordBean r = new RechargeRecordBean();
        r.setId(rs.getLong("id"));
        r.setPatientId(rs.getLong("patient_id"));
        r.setRechargeNo(rs.getString("recharge_no"));
        r.setAmount(rs.getBigDecimal("amount"));
        r.setBeforeBalance(rs.getBigDecimal("before_balance"));
        r.setAfterBalance(rs.getBigDecimal("after_balance"));
        r.setPayMethod(rs.getString("pay_method"));
        r.setStatus(rs.getInt("status"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) r.setCreateTime(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) r.setUpdateTime(ut.toLocalDateTime());
        
        return r;
    }
}