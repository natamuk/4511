package com.mycompany.system.db;

import com.mycompany.system.bean.UserNotificationBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserNotificationDB {

    public static UserNotificationBean getById(Long id) {
        String sql = "SELECT * FROM user_notification WHERE id = ?";
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

    public static List<UserNotificationBean> getAll() {
        List<UserNotificationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM user_notification ORDER BY create_time DESC";
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

    public static List<UserNotificationBean> getByUser(Integer userType, Long userId) {
        List<UserNotificationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM user_notification WHERE user_type = ? AND user_id = ? ORDER BY create_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userType);
            ps.setLong(2, userId);
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

    public static boolean insert(UserNotificationBean notification) {
        String sql = "INSERT INTO user_notification "
                   + "(user_id, user_type, title, message, type, is_read, create_time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, notification.getUserId());
            ps.setInt(2, notification.getUserType());
            ps.setString(3, notification.getTitle());
            ps.setString(4, notification.getMessage());
            ps.setString(5, notification.getType() != null ? notification.getType() : "info");
            ps.setBoolean(6, notification.getIsRead() != null ? notification.getIsRead() : false);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        notification.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean markAsRead(Long id) {
        String sql = "UPDATE user_notification SET is_read = 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM user_notification WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<UserNotificationBean> search(String keyword) {
        List<UserNotificationBean> list = new ArrayList<>();
        String sql = "SELECT * FROM user_notification WHERE title LIKE ? OR message LIKE ? ORDER BY create_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            
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

    private static UserNotificationBean mapRow(ResultSet rs) throws SQLException {
        UserNotificationBean n = new UserNotificationBean();
        n.setId(rs.getLong("id"));
        n.setUserId(rs.getLong("user_id"));
        n.setUserType(rs.getInt("user_type"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setIsRead(rs.getBoolean("is_read"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) n.setCreateTime(ct.toLocalDateTime());
        
        return n;
    }
}