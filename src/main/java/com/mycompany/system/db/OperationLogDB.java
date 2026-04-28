package com.mycompany.system.db;

import com.mycompany.system.bean.OperationLogBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OperationLogDB {

    public static OperationLogBean getById(Long id) {
        String sql = "SELECT * FROM operation_log WHERE id = ?";
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

    public static List<OperationLogBean> getAll() {
        List<OperationLogBean> list = new ArrayList<>();
        String sql = "SELECT * FROM operation_log ORDER BY create_time DESC";
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

    public static boolean insert(OperationLogBean log) {
        String sql = "INSERT INTO operation_log "
                   + "(user_type, user_id, operation, detail, ip_address, create_time) "
                   + "VALUES (?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, log.getUserType());
            ps.setLong(2, log.getUserId());
            ps.setString(3, log.getOperation());
            ps.setString(4, log.getDetail());
            ps.setString(5, log.getIpAddress());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        log.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Usually we don't update or delete logs, but included for completeness
    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM operation_log WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<OperationLogBean> search(String keyword) {
        List<OperationLogBean> list = new ArrayList<>();
        String sql = "SELECT * FROM operation_log WHERE operation LIKE ? OR detail LIKE ? "
                   + "OR ip_address LIKE ? ORDER BY create_time DESC";
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

    private static OperationLogBean mapRow(ResultSet rs) throws SQLException {
        OperationLogBean log = new OperationLogBean();
        log.setId(rs.getLong("id"));
        log.setUserType(rs.getInt("user_type"));
        log.setUserId(rs.getLong("user_id"));
        log.setOperation(rs.getString("operation"));
        log.setDetail(rs.getString("detail"));
        log.setIpAddress(rs.getString("ip_address"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) log.setCreateTime(ct.toLocalDateTime());
        
        return log;
    }
}