/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class DoctorCallNextService {

    public static String callNext(Connection conn, Long doctorId) throws Exception {
        Long regId = null;
        String regSql = "SELECT id FROM registration WHERE doctor_id = ? AND status = 1 AND reg_date = CURDATE() ORDER BY queue_no ASC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(regSql)) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    regId = rs.getLong("id");
                }
            }
        }

        if (regId != null) {
            DoctorAppointmentService.updateStatus(conn, regId, doctorId, 3);
            Long patientId = getPatientIdByRegistration(conn, regId);
            NotificationUtil.sendToPatient(conn, patientId, "Please enter", "It is your turn for consultation.", "info");
            return "REG";
        }

        Long queueId = null;
        String queueSql = "SELECT id, patient_id FROM queue WHERE (doctor_id = ? OR doctor_id IS NULL) AND status = 'waiting' AND DATE(created_time) = CURDATE() ORDER BY created_time ASC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(queueSql)) {
            ps.setLong(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    queueId = rs.getLong("id");
                    Long patientId = rs.getLong("patient_id");
                    NotificationUtil.sendToPatient(conn, patientId, "Please enter", "It is your turn for consultation.", "info");
                }
            }
        }

        if (queueId != null) {
            DoctorQueueService.updateStatus(conn, queueId, "called");
            return "QUEUE";
        }

        throw new Exception("No waiting patients.");
    }

    private static Long getPatientIdByRegistration(Connection conn, Long registrationId) throws Exception {
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