package com.mycompany.system.db;

import com.mycompany.system.bean.HospitalizationBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HospitalizationDB {

    public static HospitalizationBean getById(Long id) {
        String sql = "SELECT * FROM hospitalization WHERE id = ?";
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

    public static List<HospitalizationBean> getAll() {
        List<HospitalizationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM hospitalization ORDER BY admission_date DESC, id DESC";
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

    public static boolean insert(HospitalizationBean h) {
        String sql = "INSERT INTO hospitalization "
                   + "(patient_id, doctor_id, registration_id, admission_no, ward_name, room_no, bed_no, "
                   + "diagnosis, admission_reason, admission_date, discharge_date, status, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, h.getPatientId());
            ps.setLong(2, h.getDoctorId());
            ps.setObject(3, h.getRegistrationId());
            ps.setString(4, h.getAdmissionNo());
            ps.setString(5, h.getWardName());
            ps.setString(6, h.getRoomNo());
            ps.setString(7, h.getBedNo());
            ps.setString(8, h.getDiagnosis());
            ps.setString(9, h.getAdmissionReason());
            ps.setDate(10, h.getAdmissionDate() != null ? Date.valueOf(h.getAdmissionDate()) : null);
            ps.setDate(11, h.getDischargeDate() != null ? Date.valueOf(h.getDischargeDate()) : null);
            ps.setInt(12, h.getStatus() != null ? h.getStatus() : 1);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        h.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(HospitalizationBean h) {
        String sql = "UPDATE hospitalization SET diagnosis=?, admission_reason=?, discharge_date=?, "
                   + "status=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, h.getDiagnosis());
            ps.setString(2, h.getAdmissionReason());
            ps.setDate(3, h.getDischargeDate() != null ? Date.valueOf(h.getDischargeDate()) : null);
            ps.setInt(4, h.getStatus() != null ? h.getStatus() : 1);
            ps.setLong(5, h.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM hospitalization WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<HospitalizationBean> search(String keyword) {
        List<HospitalizationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM hospitalization WHERE diagnosis LIKE ? OR admission_reason LIKE ? "
                   + "OR admission_no LIKE ? ORDER BY admission_date DESC";
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

    private static HospitalizationBean mapRow(ResultSet rs) throws SQLException {
        HospitalizationBean h = new HospitalizationBean();
        h.setId(rs.getLong("id"));
        h.setPatientId(rs.getLong("patient_id"));
        h.setDoctorId(rs.getLong("doctor_id"));
        h.setRegistrationId(rs.getObject("registration_id", Long.class));
        h.setAdmissionNo(rs.getString("admission_no"));
        h.setWardName(rs.getString("ward_name"));
        h.setRoomNo(rs.getString("room_no"));
        h.setBedNo(rs.getString("bed_no"));
        h.setDiagnosis(rs.getString("diagnosis"));
        h.setAdmissionReason(rs.getString("admission_reason"));
        
        Date admissionDate = rs.getDate("admission_date");
        if (admissionDate != null) h.setAdmissionDate(admissionDate.toLocalDate());
        
        Date dischargeDate = rs.getDate("discharge_date");
        if (dischargeDate != null) h.setDischargeDate(dischargeDate.toLocalDate());
        
        h.setStatus(rs.getInt("status"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) h.setCreateTime(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) h.setUpdateTime(ut.toLocalDateTime());
        
        return h;
    }
}