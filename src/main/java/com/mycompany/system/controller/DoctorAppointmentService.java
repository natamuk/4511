package com.mycompany.system.controller;

import com.mycompany.system.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class DoctorAppointmentService {

    public static void approve(Connection conn, Long registrationId, Long doctorId) throws Exception {
        String sql = "UPDATE registration SET status = 3, call_time = NOW(), update_time = NOW() WHERE id = ? AND doctor_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, registrationId);
            ps.setLong(2, doctorId);
            if (ps.executeUpdate() == 0) throw new Exception("Appointment not found");
        }
        Long patientId = getPatientId(conn, registrationId);
        NotificationUtil.sendToPatient(conn, patientId, "Appointment Approved", "Your appointment has been approved.", "success");
    }

    public static void reject(Connection conn, Long registrationId, Long doctorId, String reason) throws Exception {
        // 1. 更新预约状态为已取消 (status = 2)
        String sql = "UPDATE registration SET status = 2, cancel_time = NOW(), update_time = NOW() WHERE id = ? AND doctor_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, registrationId);
            ps.setLong(2, doctorId);
            if (ps.executeUpdate() == 0) throw new Exception("Appointment not found");
        }
        
        // 2. 保存取消原因到 registration.cancel_reason
        if (reason != null && !reason.trim().isEmpty()) {
            String reasonSql = "UPDATE registration SET cancel_reason = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(reasonSql)) {
                ps.setString(1, reason);
                ps.setLong(2, registrationId);
                ps.executeUpdate();
            }
        }
        
        // 3. 【新增】将取消原因插入到 doctor_issue 表，以便在 Issues 页面显示
        // 获取诊所名称（用于 issue 记录）
        String clinicName = "";
        String clinicSql = "SELECT c.clinic_name FROM clinic c JOIN registration r ON r.clinic_id = c.id WHERE r.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(clinicSql)) {
            ps.setLong(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    clinicName = rs.getString("clinic_name");
                }
            }
        }
        
        String issueSql = "INSERT INTO doctor_issue (doctor_id, issue_type, clinic_name, detail, status, created_at) VALUES (?, 'Cancellation', ?, ?, 'Open', NOW())";
        try (PreparedStatement ps = conn.prepareStatement(issueSql)) {
            ps.setLong(1, doctorId);
            ps.setString(2, clinicName);
            String detail = "Appointment #" + registrationId + " cancelled. Reason: " + (reason == null ? "No reason provided" : reason);
            ps.setString(3, detail);
            ps.executeUpdate();
        }
        
        // 4. 发送通知给患者
        Long patientId = getPatientId(conn, registrationId);
        String message = "Your appointment has been cancelled. Reason: " + (reason == null ? "No reason provided" : reason);
        NotificationUtil.sendToPatient(conn, patientId, "Appointment Cancelled", message, "warning");
    }

    public static void updateStatus(Connection conn, Long registrationId, Long doctorId, int status) throws Exception {
        String sql = "UPDATE registration SET status = ?, update_time = NOW() WHERE id = ? AND doctor_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setLong(2, registrationId);
            ps.setLong(3, doctorId);
            if (ps.executeUpdate() == 0) throw new Exception("Registration not found");
        }
    }

    public static void skip(Connection conn, Long registrationId, Long doctorId) throws Exception {
        String sql = "UPDATE registration SET status = 6, update_time = NOW() WHERE id = ? AND doctor_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, registrationId);
            ps.setLong(2, doctorId);
            if (ps.executeUpdate() == 0) throw new Exception("Registration not found");
        }
        Long patientId = getPatientId(conn, registrationId);
        NotificationUtil.sendToPatient(conn, patientId, "Turn Skipped", "You missed your turn and have been skipped.", "warning");
    }

    private static Long getPatientId(Connection conn, Long registrationId) throws Exception {
        String sql = "SELECT patient_id FROM registration WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong("patient_id");
                return null;
            }
        }
    }
}