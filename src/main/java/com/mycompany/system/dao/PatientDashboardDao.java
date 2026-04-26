/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.dao;

import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.*;

public class PatientDashboardDao {

    public Map<String, Object> getPatientProfile(Long patientId) {
        String sql = "SELECT id, username, real_name, phone, email, address, avatar, balance, status FROM patient WHERE id = ?";
        Map<String, Object> profile = new HashMap<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    profile.put("id", rs.getLong("id"));
                    profile.put("username", rs.getString("username"));
                    profile.put("realName", rs.getString("real_name"));
                    profile.put("phone", rs.getString("phone"));
                    profile.put("email", rs.getString("email"));
                    profile.put("address", rs.getString("address"));
                    profile.put("avatar", rs.getString("avatar"));
                    profile.put("balance", rs.getBigDecimal("balance"));
                    profile.put("status", rs.getInt("status"));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return profile;
    }

    public List<Map<String, Object>> getUpcomingAppointments(Long patientId) {
        String sql = "SELECT r.id, r.reg_no, r.reg_date, r.queue_no, r.fee, r.status, r.cancel_time, r.call_time, "
                + "d.real_name AS doctor_name, d.title AS doctor_title, dep.dept_name AS department_name, "
                + "s.time_slot, s.schedule_date, c.clinic_name "
                + "FROM registration r "
                + "JOIN doctor d ON r.doctor_id = d.id "
                + "JOIN department dep ON r.department_id = dep.id "
                + "JOIN schedule s ON r.schedule_id = s.id "
                + "LEFT JOIN clinic c ON s.clinic_id = c.id "
                + "WHERE r.patient_id = ? "
                + "ORDER BY r.reg_date DESC, r.queue_no ASC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("regNo", rs.getString("reg_no"));
                    row.put("date", rs.getDate("reg_date"));
                    row.put("queueNo", rs.getInt("queue_no"));
                    row.put("fee", rs.getBigDecimal("fee"));
                    row.put("statusCode", rs.getInt("status"));
                    row.put("status", regStatusToText(rs.getInt("status")));
                    row.put("cancelTime", rs.getTimestamp("cancel_time"));
                    row.put("callTime", rs.getTimestamp("call_time"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("doctorTitle", rs.getString("doctor_title"));
                    row.put("departmentName", rs.getString("department_name"));
                    row.put("clinicName", rs.getString("clinic_name"));
                    row.put("timeSlot", rs.getInt("time_slot"));
                    row.put("scheduleDate", rs.getDate("schedule_date"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * 取得合併的最新通知（包含 site-wide notice 與 user_notification for this patient）。
     * 回傳 format: id, title, message, type, time (Timestamp)
     */
    public List<Map<String, Object>> getLatestNotices(Long patientId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String userNotifSql = "SELECT id, title, message, type, create_time FROM user_notification WHERE user_type = 3 AND user_id = ? ORDER BY create_time DESC LIMIT 20";
        String globalSql = "SELECT id, title, content AS message, 'info' AS type, publish_time AS create_time FROM notice WHERE status = 1 ORDER BY publish_time DESC LIMIT 20";

        try (Connection conn = DBUtil.getConnection()) {
            // user notifications (personal)
            try (PreparedStatement ps = conn.prepareStatement(userNotifSql)) {
                ps.setLong(1, patientId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> r = new HashMap<>();
                        r.put("id", rs.getLong("id"));
                        r.put("title", rs.getString("title"));
                        r.put("message", rs.getString("message"));
                        r.put("type", rs.getString("type") != null ? rs.getString("type") : "info");
                        r.put("time", rs.getTimestamp("create_time"));
                        list.add(r);
                    }
                }
            }

            // global notices
            try (PreparedStatement ps = conn.prepareStatement(globalSql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> r = new HashMap<>();
                        r.put("id", rs.getLong("id"));
                        r.put("title", rs.getString("title"));
                        r.put("message", rs.getString("message"));
                        r.put("type", rs.getString("type") != null ? rs.getString("type") : "info");
                        r.put("time", rs.getTimestamp("create_time"));
                        list.add(r);
                    }
                }
            }

            // sort by time desc and limit to 10
            list.sort((a, b) -> {
                Timestamp ta = (Timestamp) a.get("time");
                Timestamp tb = (Timestamp) b.get("time");
                if (ta == null && tb == null) return 0;
                if (ta == null) return 1;
                if (tb == null) return -1;
                return tb.compareTo(ta);
            });

            if (list.size() > 10) {
                return new ArrayList<>(list.subList(0, 10));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getRecentMedicalRecords(Long patientId) {
        String sql = "SELECT c.id, c.diagnosis, c.medical_advice, c.prescription, c.consultation_time, "
                + "d.real_name AS doctor_name, dep.dept_name AS department_name "
                + "FROM consultation c "
                + "JOIN doctor d ON c.doctor_id = d.id "
                + "JOIN registration r ON c.registration_id = r.id "
                + "JOIN department dep ON r.department_id = dep.id "
                + "WHERE c.patient_id = ? "
                + "ORDER BY c.consultation_time DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("recordedAt", rs.getTimestamp("consultation_time"));
                    row.put("diagnosis", rs.getString("diagnosis"));
                    row.put("treatment", rs.getString("prescription"));
                    row.put("advice", rs.getString("medical_advice"));
                    row.put("clinic", rs.getString("department_name"));
                    row.put("staffName", rs.getString("doctor_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String, Object>> getClinics() {
        String sql = "SELECT id, clinic_name, location, description, status FROM clinic WHERE status = 1 ORDER BY sort_num, id";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("name", rs.getString("clinic_name"));
                row.put("location", rs.getString("location"));
                row.put("description", rs.getString("description"));
                row.put("active", rs.getInt("status") == 1);
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Map<Long, List<Map<String, Object>>> getClinicSlots() {
        String sql = "SELECT clinic_id, period, slot_time, capacity FROM clinic_time_slot WHERE status = 1 ORDER BY clinic_id, FIELD(period,'morning','afternoon','evening'), slot_time";
        Map<Long, List<Map<String, Object>>> map = new HashMap<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Long clinicId = rs.getLong("clinic_id");
                Map<String, Object> slot = new HashMap<>();
                slot.put("period", rs.getString("period"));
                slot.put("slotTime", rs.getString("slot_time"));
                slot.put("capacity", rs.getInt("capacity"));
                map.computeIfAbsent(clinicId, k -> new ArrayList<>()).add(slot);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    public List<Map<String, Object>> getQueueTickets(Long patientId) {
        String sql = "SELECT q.id, q.queue_no, q.created_time, q.status, c.clinic_name "
                + "FROM queue q JOIN clinic c ON q.clinic_id = c.id "
                + "WHERE q.patient_id = ? ORDER BY q.created_time DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("queueNo", rs.getString("queue_no"));
                    row.put("createdTime", rs.getTimestamp("created_time"));
                    row.put("status", rs.getString("status"));
                    row.put("clinic", rs.getString("clinic_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String, Object>> getFavorites(Long patientId) {
        String sql = "SELECT f.id, c.id AS clinic_id, c.clinic_name, c.location "
                + "FROM patient_favorite_clinic f JOIN clinic c ON f.clinic_id = c.id "
                + "WHERE f.patient_id = ? ORDER BY f.created_at DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getLong("id"));
                    row.put("clinicId", rs.getLong("clinic_id"));
                    row.put("name", rs.getString("clinic_name"));
                    row.put("location", rs.getString("location"));
                    list.add(row);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private String regStatusToText(int status) {
        switch (status) {
            case 1: return "Booked";
            case 2: return "Cancelled";
            case 3: return "Called";
            case 4: return "Consulting";
            case 5: return "Completed";
            case 6: return "Transferred";
            default: return "Unknown";
        }
    }

    public Map<String, String> getSettings() {
        Map<String, String> settings = new HashMap<>();
        String sql = "SELECT setting_key, setting_value FROM system_setting";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                settings.put(rs.getString("setting_key"), rs.getString("setting_value"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        settings.putIfAbsent("same_day_queue_enabled", "0");
        settings.putIfAbsent("walkin_enabled_clinics", "");
        return settings;
    }

    public boolean isWalkinQueueEnabled() {
        Map<String, String> settings = getSettings();
        return "1".equals(settings.getOrDefault("same_day_queue_enabled", "0"));
    }

    public Set<Long> getWalkinEnabledClinicIds() {
        Map<String, String> settings = getSettings();
        String ids = settings.getOrDefault("walkin_enabled_clinics", "");
        Set<Long> result = new HashSet<>();
        if (ids != null && !ids.isEmpty()) {
            for (String id : ids.split(",")) {
                try {
                    result.add(Long.parseLong(id.trim()));
                } catch (NumberFormatException ignored) {}
            }
        }
        return result;
    }

    public List<Map<String, Object>> getAvailableWalkinClinics() {
        List<Map<String, Object>> result = new ArrayList<>();
        if (!isWalkinQueueEnabled()) return result;

        Set<Long> allowedIds = getWalkinEnabledClinicIds();
        if (allowedIds.isEmpty()) return result;

        List<Map<String, Object>> allClinics = getClinics();
        for (Map<String, Object> clinic : allClinics) {
            Long id = (Long) clinic.get("id");
            if (allowedIds.contains(id)) {
                Map<String, Object> simplified = new HashMap<>();
                simplified.put("id", id);
                simplified.put("name", clinic.get("name"));
                simplified.put("location", clinic.get("location"));
                result.add(simplified);
            }
        }
        return result;
    }
}