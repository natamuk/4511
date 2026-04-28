package com.mycompany.system.db;

import com.mycompany.system.bean.NoticeBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NoticeDB {

    public static NoticeBean getById(Long id) {
        String sql = "SELECT * FROM notice WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<NoticeBean> getAll() {
        List<NoticeBean> list = new ArrayList<>();
        String sql = "SELECT * FROM notice ORDER BY publish_time DESC, id DESC";
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

    public static boolean insert(NoticeBean notice) {
        String sql = "INSERT INTO notice (title, content, publisher_id, publisher_type, status, publish_time, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, notice.getTitle());
            ps.setString(2, notice.getContent());
            ps.setLong(3, notice.getPublisherId());
            ps.setInt(4, notice.getPublisherType());
            ps.setInt(5, notice.getStatus() != null ? notice.getStatus() : 1);
            ps.setTimestamp(6, notice.getPublishTime() != null ? Timestamp.valueOf(notice.getPublishTime()) : null);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) notice.setId(rs.getLong(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(NoticeBean notice) {
        String sql = "UPDATE notice SET title=?, content=?, status=?, publish_time=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, notice.getTitle());
            ps.setString(2, notice.getContent());
            ps.setInt(3, notice.getStatus() != null ? notice.getStatus() : 1);
            ps.setTimestamp(4, notice.getPublishTime() != null ? Timestamp.valueOf(notice.getPublishTime()) : null);
            ps.setLong(5, notice.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM notice WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<NoticeBean> search(String keyword) {
        List<NoticeBean> list = new ArrayList<>();
        String sql = "SELECT * FROM notice WHERE title LIKE ? OR content LIKE ? ORDER BY publish_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private static NoticeBean mapRow(ResultSet rs) throws SQLException {
        NoticeBean n = new NoticeBean();
        n.setId(rs.getLong("id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setPublisherId(rs.getLong("publisher_id"));
        n.setPublisherType(rs.getInt("publisher_type"));
        n.setStatus(rs.getInt("status"));
        
        Timestamp pt = rs.getTimestamp("publish_time");
        if (pt != null) n.setPublishTime(pt.toLocalDateTime());
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) n.setCreateTime(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) n.setUpdateTime(ut.toLocalDateTime());
        
        return n;
    }
}