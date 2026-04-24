/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class DoctorQueueService {

    public static void updateStatus(Connection conn, Long queueId, String statusText) throws Exception {
        String sql = "UPDATE queue SET status = ?, updated_time = NOW() WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, statusText);
            ps.setLong(2, queueId);
            if (ps.executeUpdate() == 0) throw new Exception("Queue record not found");
        }
    }

    public static void skip(Connection conn, Long queueId) throws Exception {
        updateStatus(conn, queueId, "skipped");
        Long patientId = getPatientId(conn, queueId);
        NotificationUtil.sendToPatient(conn, patientId, "Turn Skipped", "You missed your turn and have been skipped.", "warning");
    }

    private static Long getPatientId(Connection conn, Long queueId) throws Exception {
        String sql = "SELECT patient_id FROM queue WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, queueId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong("patient_id");
                return null;
            }
        }
    }
}