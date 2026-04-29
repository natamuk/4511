package com.mycompany.system.db;

import com.mycompany.system.bean.RegistrationBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RegistrationDB {

    // 根据 ID 查询预约
    public static RegistrationBean getById(Long id) {
        String sql = "SELECT id, reg_no, patient_id, clinic_id, doctor_id, department_id, schedule_id, " +
                     "reg_date, slot_time, queue_no, fee, status, cancel_time, cancel_reason, call_time, " +
                     "create_time, update_time FROM registration WHERE id = ?";
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

    // 根据患者 ID 查询所有预约
    public static List<RegistrationBean> listByPatientId(Long patientId) {
        List<RegistrationBean> list = new ArrayList<>();
        String sql = "SELECT id, reg_no, patient_id, clinic_id, doctor_id, department_id, schedule_id, " +
                     "reg_date, slot_time, queue_no, fee, status, cancel_time, cancel_reason, call_time, " +
                     "create_time, update_time FROM registration WHERE patient_id = ? ORDER BY reg_date DESC, slot_time ASC";
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

    // 取消预约（更新状态为 2，记录取消时间）
    public static boolean cancelBooking(Long registrationId, Long scheduleId) {
        String sql = "UPDATE registration SET status = 2, cancel_time = NOW(), update_time = NOW() WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, registrationId);
            int rows = ps.executeUpdate();
            if (rows > 0 && scheduleId != null) {
                // 减少 schedule 的预约计数
                String updateSchedule = "UPDATE schedule SET booked_count = booked_count - 1 WHERE id = ? AND booked_count > 0";
                try (PreparedStatement ps2 = conn.prepareStatement(updateSchedule)) {
                    ps2.setLong(1, scheduleId);
                    ps2.executeUpdate();
                }
            }
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 更新预约（一般用于改时间，这里保留简单更新）
    public static boolean updateRegistration(RegistrationBean reg) {
        String sql = "UPDATE registration SET reg_date = ?, slot_time = ?, update_time = NOW() WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, reg.getRegDate());
            ps.setString(2, reg.getSlotTime());
            ps.setLong(3, reg.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 新增预约
    public static boolean insertRegistration(RegistrationBean reg) {
        String sql = "INSERT INTO registration (reg_no, patient_id, clinic_id, doctor_id, department_id, schedule_id, " +
                     "reg_date, slot_time, queue_no, fee, status, create_time, update_time) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, reg.getRegNo());
            ps.setLong(2, reg.getPatientId());
            ps.setLong(3, reg.getClinicId());
            ps.setLong(4, reg.getDoctorId());
            ps.setLong(5, reg.getDepartmentId());
            ps.setLong(6, reg.getScheduleId());
            ps.setDate(7, reg.getRegDate());
            ps.setString(8, reg.getSlotTime());
            ps.setInt(9, reg.getQueueNo());
            ps.setBigDecimal(10, reg.getFee());
            ps.setInt(11, reg.getStatus());
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

    // 结果集映射
    private static RegistrationBean mapRow(ResultSet rs) throws SQLException {
        RegistrationBean reg = new RegistrationBean();
        reg.setId(rs.getLong("id"));
        reg.setRegNo(rs.getString("reg_no"));
        reg.setPatientId(rs.getLong("patient_id"));
        reg.setClinicId(rs.getLong("clinic_id"));
        reg.setDoctorId(rs.getLong("doctor_id"));
        reg.setDepartmentId(rs.getLong("department_id"));
        reg.setScheduleId(rs.getLong("schedule_id"));
        reg.setRegDate(rs.getDate("reg_date"));
        reg.setSlotTime(rs.getString("slot_time"));
        reg.setQueueNo(rs.getInt("queue_no"));
        reg.setFee(rs.getBigDecimal("fee"));
        reg.setStatus(rs.getInt("status"));
        reg.setCancelTime(rs.getTimestamp("cancel_time"));
        reg.setCancelReason(rs.getString("cancel_reason"));
        reg.setCallTime(rs.getTimestamp("call_time"));
        reg.setCreateTime(rs.getTimestamp("create_time"));
        reg.setUpdateTime(rs.getTimestamp("update_time"));
        return reg;
    }
}