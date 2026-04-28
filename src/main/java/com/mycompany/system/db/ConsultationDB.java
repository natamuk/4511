package com.mycompany.system.db;

import com.mycompany.system.bean.ConsultationBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ConsultationDB {

    public static ConsultationBean getById(Long id) {
        String sql = "SELECT * FROM consultation WHERE id = ?";
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

    public static List<ConsultationBean> getAll() {
        List<ConsultationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM consultation ORDER BY consultation_time DESC";
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

    public static boolean insert(ConsultationBean consultation) {
        String sql = "INSERT INTO consultation "
                   + "(registration_id, patient_id, doctor_id, diagnosis, medical_advice, "
                   + "prescription, consultation_time, status, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, consultation.getRegistrationId());
            ps.setLong(2, consultation.getPatientId());
            ps.setLong(3, consultation.getDoctorId());
            ps.setString(4, consultation.getDiagnosis());
            ps.setString(5, consultation.getMedicalAdvice());
            ps.setString(6, consultation.getPrescription());
            ps.setTimestamp(7, consultation.getConsultationTime() != null 
                            ? Timestamp.valueOf(consultation.getConsultationTime()) : null);
            ps.setInt(8, consultation.getStatus() != null ? consultation.getStatus() : 1);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        consultation.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(ConsultationBean consultation) {
        String sql = "UPDATE consultation SET diagnosis=?, medical_advice=?, prescription=?, "
                   + "consultation_time=?, status=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, consultation.getDiagnosis());
            ps.setString(2, consultation.getMedicalAdvice());
            ps.setString(3, consultation.getPrescription());
            ps.setTimestamp(4, consultation.getConsultationTime() != null 
                            ? Timestamp.valueOf(consultation.getConsultationTime()) : null);
            ps.setInt(5, consultation.getStatus() != null ? consultation.getStatus() : 1);
            ps.setLong(6, consultation.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM consultation WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<ConsultationBean> search(String keyword) {
        List<ConsultationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM consultation WHERE diagnosis LIKE ? OR medical_advice LIKE ? "
                   + "OR prescription LIKE ? ORDER BY consultation_time DESC";
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

    private static ConsultationBean mapRow(ResultSet rs) throws SQLException {
        ConsultationBean c = new ConsultationBean();
        c.setId(rs.getLong("id"));
        c.setRegistrationId(rs.getLong("registration_id"));
        c.setPatientId(rs.getLong("patient_id"));
        c.setDoctorId(rs.getLong("doctor_id"));
        c.setDiagnosis(rs.getString("diagnosis"));
        c.setMedicalAdvice(rs.getString("medical_advice"));
        c.setPrescription(rs.getString("prescription"));
        
        Timestamp ct = rs.getTimestamp("consultation_time");
        if (ct != null) c.setConsultationTime(ct.toLocalDateTime());
        
        c.setStatus(rs.getInt("status"));
        
        Timestamp createTs = rs.getTimestamp("create_time");
        if (createTs != null) c.setCreateTime(createTs.toLocalDateTime());
        
        Timestamp updateTs = rs.getTimestamp("update_time");
        if (updateTs != null) c.setUpdateTime(updateTs.toLocalDateTime());
        
        return c;
    }
}