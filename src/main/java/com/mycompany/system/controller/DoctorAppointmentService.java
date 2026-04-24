/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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

    public static void reject(Connection conn, Long registrationId, Long doctorId) throws Exception {
        String sql = "UPDATE registration SET status = 2, cancel_time = NOW(), update_time = NOW() WHERE id = ? AND doctor_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, registrationId);
            ps.setLong(2, doctorId);
            if (ps.executeUpdate() == 0) throw new Exception("Appointment not found");
        }
        Long patientId = getPatientId(conn, registrationId);
        NotificationUtil.sendToPatient(conn, patientId, "Appointment Rejected", "Your appointment has been rejected.", "warning");
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