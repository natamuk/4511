package com.mycompany.system.db;

import com.mycompany.system.bean.QueueBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QueueDB {

    public static QueueBean getById(Long id) {
        String sql = "SELECT * FROM queue WHERE id = ?";
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

    public static List<QueueBean> getAll() {
        List<QueueBean> list = new ArrayList<>();
        String sql = "SELECT * FROM queue ORDER BY created_time DESC";
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

    public static List<QueueBean> getByClinicId(Long clinicId) {
        List<QueueBean> list = new ArrayList<>();
        String sql = "SELECT * FROM queue WHERE clinic_id = ? ORDER BY created_time ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, clinicId);
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

    public static boolean insert(QueueBean queue) {
        String sql = "INSERT INTO queue "
                   + "(patient_id, doctor_id, clinic_id, queue_no, status, called_time, created_time, updated_time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, queue.getPatientId());
            ps.setObject(2, queue.getDoctorId());
            ps.setLong(3, queue.getClinicId());
            ps.setString(4, queue.getQueueNo());
            ps.setString(5, queue.getStatus() != null ? queue.getStatus() : "waiting");
            ps.setTimestamp(6, queue.getCalledTime() != null ? Timestamp.valueOf(queue.getCalledTime()) : null);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        queue.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(QueueBean queue) {
        String sql = "UPDATE queue SET doctor_id=?, status=?, called_time=?, updated_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setObject(1, queue.getDoctorId());
            ps.setString(2, queue.getStatus());
            ps.setTimestamp(3, queue.getCalledTime() != null ? Timestamp.valueOf(queue.getCalledTime()) : null);
            ps.setLong(4, queue.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM queue WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<QueueBean> search(String keyword) {
        List<QueueBean> list = new ArrayList<>();
        String sql = "SELECT * FROM queue WHERE queue_no LIKE ? OR status LIKE ? ORDER BY created_time DESC";
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

    private static QueueBean mapRow(ResultSet rs) throws SQLException {
        QueueBean q = new QueueBean();
        q.setId(rs.getLong("id"));
        q.setPatientId(rs.getLong("patient_id"));
        q.setDoctorId(rs.getObject("doctor_id", Long.class));
        q.setClinicId(rs.getLong("clinic_id"));
        q.setQueueNo(rs.getString("queue_no"));
        q.setStatus(rs.getString("status"));
        
        Timestamp calledTs = rs.getTimestamp("called_time");
        if (calledTs != null) q.setCalledTime(calledTs.toLocalDateTime());
        
        Timestamp createdTs = rs.getTimestamp("created_time");
        if (createdTs != null) q.setCreatedTime(createdTs.toLocalDateTime());
        
        Timestamp updatedTs = rs.getTimestamp("updated_time");
        if (updatedTs != null) q.setUpdatedTime(updatedTs.toLocalDateTime());
        
        return q;
    }
}