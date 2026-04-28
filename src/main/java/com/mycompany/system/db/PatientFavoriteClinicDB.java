package com.mycompany.system.db;

import com.mycompany.system.bean.PatientFavoriteClinicBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PatientFavoriteClinicDB {

    public static PatientFavoriteClinicBean getById(Long id) {
        String sql = "SELECT * FROM patient_favorite_clinic WHERE id = ?";
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

    public static List<PatientFavoriteClinicBean> getAll() {
        List<PatientFavoriteClinicBean> list = new ArrayList<>();
        String sql = "SELECT * FROM patient_favorite_clinic ORDER BY created_at DESC";
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

    public static List<PatientFavoriteClinicBean> getByPatientId(Long patientId) {
        List<PatientFavoriteClinicBean> list = new ArrayList<>();
        String sql = "SELECT * FROM patient_favorite_clinic WHERE patient_id = ? ORDER BY created_at DESC";
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

    public static boolean insert(PatientFavoriteClinicBean favorite) {
        String sql = "INSERT INTO patient_favorite_clinic (patient_id, clinic_name, created_at) "
                   + "VALUES (?, ?, NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, favorite.getPatientId());
            ps.setString(2, favorite.getClinicName());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        favorite.setId(rs.getLong(1));
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
        String sql = "DELETE FROM patient_favorite_clinic WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteByPatientAndClinic(Long patientId, String clinicName) {
        String sql = "DELETE FROM patient_favorite_clinic WHERE patient_id = ? AND clinic_name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, patientId);
            ps.setString(2, clinicName);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<PatientFavoriteClinicBean> search(String keyword) {
        List<PatientFavoriteClinicBean> list = new ArrayList<>();
        String sql = "SELECT * FROM patient_favorite_clinic WHERE clinic_name LIKE ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            
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

    private static PatientFavoriteClinicBean mapRow(ResultSet rs) throws SQLException {
        PatientFavoriteClinicBean f = new PatientFavoriteClinicBean();
        f.setId(rs.getLong("id"));
        f.setPatientId(rs.getLong("patient_id"));
        f.setClinicName(rs.getString("clinic_name"));
        
        Timestamp ct = rs.getTimestamp("created_at");
        if (ct != null) f.setCreatedAt(ct.toLocalDateTime());
        
        return f;
    }
}