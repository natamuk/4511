
package com.mycompany.system.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class NotificationUtil {

    public static void sendToPatient(Connection conn, Long patientId, String title, String message, String type) throws SQLException {
        if (patientId == null) {
            System.err.println("Warning: patientId is null, skip notification.");
            return;
        }
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