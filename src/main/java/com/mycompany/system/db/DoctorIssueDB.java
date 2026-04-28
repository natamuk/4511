package com.mycompany.system.db;

import com.mycompany.system.bean.DoctorIssueBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DoctorIssueDB {

    public static DoctorIssueBean getById(Long id) {
        String sql = "SELECT * FROM doctor_issue WHERE id = ?";
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

    public static List<DoctorIssueBean> getAll() {
        List<DoctorIssueBean> list = new ArrayList<>();
        String sql = "SELECT * FROM doctor_issue ORDER BY created_at DESC";
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

    public static boolean insert(DoctorIssueBean issue) {
        String sql = "INSERT INTO doctor_issue "
                   + "(doctor_id, issue_type, clinic_name, detail, status, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, issue.getDoctorId());
            ps.setString(2, issue.getIssueType());
            ps.setString(3, issue.getClinicName());
            ps.setString(4, issue.getDetail());
            ps.setString(5, issue.getStatus() != null ? issue.getStatus() : "Open");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        issue.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(DoctorIssueBean issue) {
        String sql = "UPDATE doctor_issue SET issue_type=?, clinic_name=?, detail=?, "
                   + "status=?, updated_at=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, issue.getIssueType());
            ps.setString(2, issue.getClinicName());
            ps.setString(3, issue.getDetail());
            ps.setString(4, issue.getStatus());
            ps.setLong(5, issue.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM doctor_issue WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<DoctorIssueBean> search(String keyword) {
        List<DoctorIssueBean> list = new ArrayList<>();
        String sql = "SELECT * FROM doctor_issue WHERE issue_type LIKE ? OR clinic_name LIKE ? "
                   + "OR detail LIKE ? OR status LIKE ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);
            
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

    private static DoctorIssueBean mapRow(ResultSet rs) throws SQLException {
        DoctorIssueBean i = new DoctorIssueBean();
        i.setId(rs.getLong("id"));
        i.setDoctorId(rs.getLong("doctor_id"));
        i.setIssueType(rs.getString("issue_type"));
        i.setClinicName(rs.getString("clinic_name"));
        i.setDetail(rs.getString("detail"));
        i.setStatus(rs.getString("status"));
        
        Timestamp ct = rs.getTimestamp("created_at");
        if (ct != null) i.setCreatedAt(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("updated_at");
        if (ut != null) i.setUpdatedAt(ut.toLocalDateTime());
        
        return i;
    }
}