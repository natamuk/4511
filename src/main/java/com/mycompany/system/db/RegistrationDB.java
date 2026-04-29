package com.mycompany.system.db;

import com.mycompany.system.bean.RegistrationBean;
import com.mycompany.system.util.DBUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RegistrationDB {

    public static RegistrationBean getById(Long id) {
        String sql = "SELECT * FROM registration WHERE id = ?";
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

    public static List<RegistrationBean> getAll() {
        List<RegistrationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM registration ORDER BY reg_date DESC, queue_no ASC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean insert(RegistrationBean reg) {
        String sql = "INSERT INTO registration "
                + "(reg_no, patient_id, doctor_id, department_id, schedule_id, reg_date, queue_no, fee, status, create_time, update_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, reg.getRegNo());
            ps.setLong(2, reg.getPatientId());
            ps.setLong(3, reg.getDoctorId());
            ps.setLong(4, reg.getDepartmentId());
            ps.setLong(5, reg.getScheduleId());
            ps.setDate(6, reg.getRegDate() != null ? Date.valueOf(reg.getRegDate()) : null);
            ps.setInt(7, reg.getQueueNo() != null ? reg.getQueueNo() : 0);
            ps.setBigDecimal(8, reg.getFee() != null ? reg.getFee() : BigDecimal.ZERO);
            ps.setInt(9, reg.getStatus() != null ? reg.getStatus() : 1);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        reg.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(RegistrationBean reg) {
        String sql = "UPDATE registration SET status=?, cancel_time=?, call_time=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, reg.getStatus() != null ? reg.getStatus() : 1);
            ps.setTimestamp(2, reg.getCancelTime() != null ? Timestamp.valueOf(reg.getCancelTime()) : null);
            ps.setTimestamp(3, reg.getCallTime() != null ? Timestamp.valueOf(reg.getCallTime()) : null);
            ps.setLong(4, reg.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM registration WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<RegistrationBean> search(String keyword) {
        List<RegistrationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM registration WHERE reg_no LIKE ? ORDER BY reg_date DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

    private static RegistrationBean mapRow(ResultSet rs) throws SQLException {
        RegistrationBean r = new RegistrationBean();
        r.setId(rs.getLong("id"));
        r.setRegNo(rs.getString("reg_no"));
        r.setPatientId(rs.getLong("patient_id"));
        r.setDoctorId(rs.getLong("doctor_id"));
        r.setDepartmentId(rs.getLong("department_id"));
        r.setScheduleId(rs.getLong("schedule_id"));

        Date regDate = rs.getDate("reg_date");
        if (regDate != null) {
            r.setRegDate(regDate.toLocalDate());
        }

        r.setQueueNo(rs.getInt("queue_no"));
        r.setFee(rs.getBigDecimal("fee"));
        r.setStatus(rs.getInt("status"));

        Timestamp cancelTs = rs.getTimestamp("cancel_time");
        if (cancelTs != null) {
            r.setCancelTime(cancelTs.toLocalDateTime());
        }

        Timestamp callTs = rs.getTimestamp("call_time");
        if (callTs != null) {
            r.setCallTime(callTs.toLocalDateTime());
        }

        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) {
            r.setCreateTime(ct.toLocalDateTime());
        }

        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) {
            r.setUpdateTime(ut.toLocalDateTime());
        }

        return r;
    }

    public static boolean cancelBooking(Long registrationId, Long scheduleId) {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            // Update registration status to cancelled
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE registration SET status = 2, cancel_time = NOW(), update_time = NOW() WHERE id = ?")) {
                ps.setLong(1, registrationId);
                ps.executeUpdate();
            }

            // Decrease booked count in schedule
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE schedule SET booked_count = GREATEST(booked_count - 1, 0) WHERE id = ?")) {
                ps.setLong(1, scheduleId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
