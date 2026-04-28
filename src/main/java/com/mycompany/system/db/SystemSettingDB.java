package com.mycompany.system.db;

import com.mycompany.system.bean.SystemSettingBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SystemSettingDB {

    public static SystemSettingBean getByKey(String settingKey) {
        String sql = "SELECT * FROM system_setting WHERE setting_key = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, settingKey);
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

    public static List<SystemSettingBean> getAll() {
        List<SystemSettingBean> list = new ArrayList<>();
        String sql = "SELECT * FROM system_setting";
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

    public static boolean insert(SystemSettingBean setting) {
        String sql = "INSERT INTO system_setting (setting_key, setting_value, description) "
                   + "VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, setting.getSettingKey());
            ps.setString(2, setting.getSettingValue());
            ps.setString(3, setting.getDescription());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean update(SystemSettingBean setting) {
        String sql = "UPDATE system_setting SET setting_value=?, description=? WHERE setting_key=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, setting.getSettingValue());
            ps.setString(2, setting.getDescription());
            ps.setString(3, setting.getSettingKey());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteByKey(String settingKey) {
        String sql = "DELETE FROM system_setting WHERE setting_key = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, settingKey);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Utility method to get value directly by key
    public static String getValue(String settingKey) {
        SystemSettingBean setting = getByKey(settingKey);
        return setting != null ? setting.getSettingValue() : null;
    }

    private static SystemSettingBean mapRow(ResultSet rs) throws SQLException {
        SystemSettingBean s = new SystemSettingBean();
        s.setSettingKey(rs.getString("setting_key"));
        s.setSettingValue(rs.getString("setting_value"));
        s.setDescription(rs.getString("description"));
        return s;
    }
}