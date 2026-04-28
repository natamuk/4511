/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.dao;

import com.mycompany.system.util.DBUtil;

import java.sql.*;
import java.util.*;

public class AdminDashboardDao {

    public Map<String, Object> getAdminProfile(Long adminId) {
        String sql = "SELECT id, username, real_name, phone, email, avatar, status FROM admin WHERE id = ?";
        Map<String, Object> profile = new HashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, adminId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    profile.put("id", rs.getLong("id"));
                    profile.put("username", rs.getString("username"));
                    profile.put("realName", rs.getString("real_name"));
                    profile.put("phone", rs.getString("phone"));
                    profile.put("email", rs.getString("email"));
                    profile.put("avatar", rs.getString("avatar"));
                    profile.put("status", rs.getString("status"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return profile;
    }

    public List<Map<String, Object>> getAppointments() {
        String sql =
                "SELECT r.id, r.reg_no, r.reg_date, r.queue_no, r.fee, r.status, " +
                "p.real_name AS patient_name, p.phone AS patient_phone, " +
                "d.real_name AS doctor_name, dep.dept_name AS department_name, " +
                "s.schedule_date, s.time_slot " +
                "FROM registration r " +
                "JOIN patient p ON r.patient_id = p.id " +
                "JOIN doctor d ON r.doctor_id = d.id " +
                "JOIN department dep ON r.department_id = dep.id " +
                "JOIN schedule s ON r.schedule_id = s.id " +
                "ORDER BY r.reg_date DESC, r.queue_no ASC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("regNo", rs.getString("reg_no"));
                row.put("patient", rs.getString("patient_name"));
                row.put("phone", rs.getString("patient_phone"));
                row.put("doctor", rs.getString("doctor_name"));
                row.put("department", rs.getString("department_name"));
                row.put("date", rs.getDate("reg_date"));
                row.put("queueNo", rs.getInt("queue_no"));
                row.put("fee", rs.getBigDecimal("fee"));
                row.put("status", statusToText(rs.getInt("status")));
                row.put("scheduleDate", rs.getDate("schedule_date"));
                row.put("timeSlot", rs.getInt("time_slot"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getQueueList() {
        String sql =
                "SELECT q.id, q.queue_no, q.status, q.created_time, " +
                "p.real_name AS patient_name, p.phone AS patient_phone, " +
                "c.clinic_name AS clinic_name, d.real_name AS doctor_name " +
                "FROM queue q " +
                "JOIN patient p ON q.patient_id = p.id " +
                "JOIN clinic c ON q.clinic_id = c.id " +
                "LEFT JOIN doctor d ON q.doctor_id = d.id " +
                "ORDER BY q.created_time DESC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("ticketNo", rs.getString("queue_no"));
                row.put("patient", rs.getString("patient_name"));
                row.put("phone", rs.getString("patient_phone"));
                row.put("doctor", rs.getString("doctor_name"));
                row.put("clinic", rs.getString("clinic_name"));
                row.put("service", rs.getString("clinic_name"));
                row.put("status", queueStatusToText(rs.getString("status")));
                row.put("updatedAt", rs.getTimestamp("created_time"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getNotifications(Long adminId) {
        String sql =
                "SELECT id, title, message, type, is_read, create_time " +
                "FROM user_notification " +
                "WHERE user_type = 1 AND user_id = ? " +
                "ORDER BY create_time DESC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, adminId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("title", rs.getString("title"));
                    row.put("message", rs.getString("message"));
                    row.put("type", rs.getString("type"));
                    row.put("read", rs.getInt("is_read") == 1);
                    row.put("time", rs.getTimestamp("create_time"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean markAllNotificationsRead(Long adminId) {
        String sql = "UPDATE user_notification SET is_read = 1 WHERE user_type = 1 AND user_id = ? AND is_read = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, adminId);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> getIssues() {
        List<Map<String, Object>> list = new ArrayList<>();

        // 1) 先從 doctor_issue 讀
        String sql1 =
                "SELECT di.id, di.doctor_id, di.issue_type, di.clinic_name, di.detail, di.status, di.created_at, d.real_name AS doctor_name " +
                "FROM doctor_issue di " +
                "JOIN doctor d ON di.doctor_id = d.id " +
                "ORDER BY di.created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql1);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("type", rs.getString("issue_type"));
                row.put("title", rs.getString("issue_type"));
                row.put("detail", rs.getString("detail"));
                row.put("doctor", rs.getString("doctor_name"));
                row.put("clinic", rs.getString("clinic_name"));
                row.put("status", rs.getString("status"));
                row.put("createdAt", rs.getTimestamp("created_at"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2) 補一份從 registration 推導的異常資料：頻繁取消
        String sql2 =
                "SELECT p.id AS patient_id, p.real_name AS patient_name, " +
                "SUM(CASE WHEN r.status = 2 THEN 1 ELSE 0 END) AS cancelled_count, " +
                "MAX(r.update_time) AS last_update " +
                "FROM registration r " +
                "JOIN patient p ON r.patient_id = p.id " +
                "GROUP BY p.id, p.real_name " +
                "HAVING cancelled_count >= 2 " +
                "ORDER BY cancelled_count DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql2);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", "cancel-" + rs.getLong("patient_id"));
                row.put("type", "Frequent Cancellation");
                row.put("title", "Frequent Cancellation");
                row.put("detail", rs.getString("patient_name") + " has cancelled appointments multiple times.");
                row.put("doctor", "");
                row.put("clinic", "");
                row.put("status", "Open");
                row.put("createdAt", rs.getTimestamp("last_update"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 3) 補一份從 registration 推導的異常資料：頻繁預約但未完成（簡單統計）
        String sql3 =
                "SELECT p.id AS patient_id, p.real_name AS patient_name, " +
                "COUNT(*) AS total_count, MAX(r.update_time) AS last_update " +
                "FROM registration r " +
                "JOIN patient p ON r.patient_id = p.id " +
                "GROUP BY p.id, p.real_name " +
                "HAVING total_count >= 5 " +
                "ORDER BY total_count DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql3);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", "no-show-" + rs.getLong("patient_id"));
                row.put("type", "High Activity");
                row.put("title", "High Activity");
                row.put("detail", rs.getString("patient_name") + " has many registrations, please review.");
                row.put("doctor", "");
                row.put("clinic", "");
                row.put("status", "Open");
                row.put("createdAt", rs.getTimestamp("last_update"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getLogs() {
        String sql =
                "SELECT id, user_type, user_id, operation, detail, ip_address, create_time " +
                "FROM operation_log ORDER BY create_time DESC LIMIT 100";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("role", userTypeToText(rs.getInt("user_type")));
                row.put("action", rs.getString("operation"));
                row.put("detail", rs.getString("detail"));
                row.put("createdAt", rs.getTimestamp("create_time"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getDoctors() {
        String sql = "SELECT id, username, real_name, phone, email, title, status, department_id FROM doctor ORDER BY id ASC";
        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("username", rs.getString("username"));
                row.put("name", rs.getString("real_name"));
                row.put("phone", rs.getString("phone"));
                row.put("email", rs.getString("email"));
                row.put("title", rs.getString("title"));
                row.put("status", rs.getInt("status") == 1 ? "active" : "inactive");
                row.put("departmentId", rs.getLong("department_id"));
                row.put("role", "doctor");
                row.put("clinic", "Doctor");
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getPatients() {
        String sql = "SELECT id, username, real_name, phone, email, balance, status, address FROM patient ORDER BY id ASC";
        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("username", rs.getString("username"));
                row.put("name", rs.getString("real_name"));
                row.put("phone", rs.getString("phone"));
                row.put("email", rs.getString("email"));
                row.put("balance", rs.getBigDecimal("balance"));
                row.put("status", rs.getInt("status") == 1 ? "active" : "inactive");
                row.put("address", rs.getString("address"));
                row.put("role", "patient");
                row.put("clinic", "Patient");
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean disableDoctor(Long id) {
        String sql = "UPDATE doctor SET status = 0 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean disablePatient(Long id) {
        String sql = "UPDATE patient SET status = 0 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> getClinics() {
        String sql =
                "SELECT id, clinic_name, location, description, status, sort_num, create_time " +
                "FROM clinic ORDER BY sort_num ASC";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("name", rs.getString("clinic_name"));
                row.put("location", rs.getString("location"));
                row.put("address", rs.getString("description"));
                row.put("phone", "");
                row.put("open_time", "");
                row.put("close_time", "");
                row.put("queueEnabled", rs.getInt("status") == 1);
                row.put("bookingEnabled", rs.getInt("status") == 1);
                row.put("active", rs.getInt("status") == 1);
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Map<String, Object>> getQuota() {
        String sql =
                "SELECT s.id, c.clinic_name, d.real_name AS doctor_name, " +
                "s.schedule_date, s.time_slot, s.max_count, s.booked_count, s.status " +
                "FROM schedule s " +
                "JOIN clinic c ON s.clinic_id = c.id " +
                "JOIN doctor d ON s.doctor_id = d.id " +
                "ORDER BY s.schedule_date DESC, c.clinic_name, d.real_name";

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("clinic", rs.getString("clinic_name"));
                row.put("service", rs.getString("doctor_name"));
                row.put("date", rs.getDate("schedule_date"));
                row.put("time", rs.getInt("time_slot"));
                row.put("capacity", rs.getInt("max_count"));
                row.put("booked", rs.getInt("booked_count"));
                row.put("queueCapacity", rs.getInt("max_count"));
                row.put("queueCount", rs.getInt("booked_count"));
                row.put("active", rs.getInt("status") == 1);
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Map<String, String> getSettings() {
        Map<String, String> settings = new HashMap<>();

        String sql = "SELECT setting_key, setting_value FROM system_setting";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                settings.put(rs.getString("setting_key"), rs.getString("setting_value"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // fallback defaults
        settings.putIfAbsent("max_active_bookings_per_patient", "3");
        settings.putIfAbsent("cancel_deadline_hours", "24");
        settings.putIfAbsent("same_day_queue_enabled", "1");
        settings.putIfAbsent("booking_approval_required", "0");

        return settings;
    }

    public boolean saveSettings(Map<String, String> settings) {
        String sql = "INSERT INTO system_setting (setting_key, setting_value, description) VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), description = VALUES(description)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (Map.Entry<String, String> entry : settings.entrySet()) {
                ps.setString(1, entry.getKey());
                ps.setString(2, entry.getValue());
                ps.setString(3, entry.getKey());
                ps.addBatch();
            }
            ps.executeBatch();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean createPatient(String username, String password, String realName, String phone, String email) {
        String sql = "INSERT INTO patient (username, password, real_name, phone, email, status) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, realName);
            ps.setString(4, phone);
            ps.setString(5, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean createDoctor(String username, String password, String realName, String phone, String email, String title, Long departmentId) {
        String sql = "INSERT INTO doctor (username, password, real_name, phone, email, title, department_id, status, register_fee) VALUES (?, ?, ?, ?, ?, ?, ?, 1, 0.00)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, realName);
            ps.setString(4, phone);
            ps.setString(5, email);
            ps.setString(6, title);
            ps.setLong(7, departmentId == null ? 1L : departmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean createAdmin(String username, String password, String realName, String phone, String email) {
        String sql = "INSERT INTO admin (username, password, real_name, phone, email, status) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, realName);
            ps.setString(4, phone);
            ps.setString(5, email);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== 新增加的方法（用于 AdminQueueServlet） ====================

    /**
     * 检查是否启用现场挂号（同天排队）功能
     * 读取系统设置 same_day_queue_enabled，默认为 "1" 表示启用
     */
    public boolean isWalkinQueueEnabled() {
        Map<String, String> settings = getSettings();
        String value = settings.getOrDefault("same_day_queue_enabled", "1");
        return "1".equals(value) || "true".equalsIgnoreCase(value);
    }

    /**
     * 获取可用于现场挂号的诊所列表
     * 返回所有 status = 1 的诊所（可根据业务需要增加其他条件）
     */
    public List<Map<String, Object>> getAvailableWalkinClinics() {
        String sql = "SELECT id, clinic_name, location, description, status FROM clinic WHERE status = 1 ORDER BY sort_num ASC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("name", rs.getString("clinic_name"));
                row.put("location", rs.getString("location"));
                row.put("description", rs.getString("description"));
                row.put("status", rs.getInt("status"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== 保持原有的辅助方法 ====================

    private String statusToText(int status) {
        switch (status) {
            case 1: return "pending";
            case 2: return "cancelled";
            case 3: return "called";
            case 4: return "consulting";
            case 5: return "completed";
            case 6: return "transferred";
            default: return "pending";
        }
    }

    private String queueStatusToText(String status) {
        if (status == null) return "waiting";
        switch (status.toLowerCase()) {
            case "waiting": return "waiting";
            case "called": return "called";
            case "skipped": return "skipped";
            case "completed": return "completed";
            default: return status;
        }
    }

    private String userTypeToText(int type) {
        switch (type) {
            case 1: return "admin";
            case 2: return "doctor";
            case 3: return "patient";
            default: return "unknown";
        }
    }

    // ==================== 诊所管理、配额更新、用户更新、预约改期等 ====================

    public boolean createClinic(String name, String address, String phone) {
        String sql = "INSERT INTO clinic (clinic_name, location, description, status, create_time) VALUES (?, ?, ?, 1, NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, address);
            ps.setString(3, phone);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateClinic(Long id, String name, String address, String phone) {
        String sql = "UPDATE clinic SET clinic_name = ?, location = ?, description = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, address);
            ps.setString(3, phone);
            ps.setLong(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean disableClinic(Long id) {
        String sql = "UPDATE clinic SET status = 0 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateQuota(Long id, int capacity, String service) {
        String sql = "UPDATE schedule SET max_count = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, capacity);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateDoctor(Long id, String realName, String phone, String email, String title, Long departmentId) {
        String sql = "UPDATE doctor SET real_name = ?, phone = ?, email = ?, title = ?, department_id = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, realName);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setString(4, title);
            if (departmentId != null) {
                ps.setLong(5, departmentId);
            } else {
                ps.setNull(5, Types.BIGINT);
            }
            ps.setLong(6, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePatient(Long id, String realName, String phone, String email) {
        String sql = "UPDATE patient SET real_name = ?, phone = ?, email = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, realName);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setLong(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateAppointmentStatus(Long id, String status) {
        int statusCode = 1; // default pending/confirmed
        if (status == null) statusCode = 1;
        else {
            String s = status.trim().toLowerCase();
            if ("confirmed".equals(s)) statusCode = 1;
            else if ("completed".equals(s)) statusCode = 5;
            else if ("cancelled".equals(s)) statusCode = 2;
            else if ("no_show".equals(s) || "no-show".equals(s)) statusCode = 6;
            else statusCode = 1;
        }

        String sql = "UPDATE registration SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, statusCode);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean reassignDoctor(Long appointmentId, Long newDoctorId) {
        String sql = "UPDATE registration SET doctor_id = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, newDoctorId);
            ps.setLong(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}