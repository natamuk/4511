/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class NotificationUtil {

    public static void sendToPatient(Connection conn, Long patientId, String title, String message, String type) throws Exception {
        if (patientId == null) return;
        String sql = "INSERT INTO user_notification (user_id, user_type, title, message, type, is_read, create_time) VALUES (?, 3, ?, ?, ?, 0, NOW())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, patientId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.setString(4, type);
            ps.executeUpdate();
        }
    }
}