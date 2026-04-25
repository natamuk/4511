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
        } catch (Exception e) {
            e.printStackTrace();
        }
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
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getLatestNotices(Long patientId) {
        String sql = "SELECT id, title, content, publish_time FROM notice WHERE status = 1 ORDER BY publish_time DESC, create_time DESC LIMIT 5";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getLong("id"));
                row.put("title", rs.getString("title"));
                row.put("message", rs.getString("content"));
                row.put("type", "info");
                row.put("read", false);
                row.put("time", rs.getTimestamp("publish_time"));
                list.add(row);
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
        } catch (Exception e) {
            e.printStackTrace();
        }
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
        } catch (Exception e) {
            e.printStackTrace();
        }
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
        } catch (Exception e) {
            e.printStackTrace();
        }
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
                    row.put("ticketNo", rs.getString("queue_no"));
                    row.put("date", rs.getTimestamp("created_time"));
                    row.put("status", rs.getString("status"));
                    row.put("clinic", rs.getString("clinic_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
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
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private String regStatusToText(int status) {
        switch (status) {
            case 1:
                return "Booked";
            case 2:
                return "Cancelled";
            case 3:
                return "Called";
            case 4:
                return "Consulting";
            case 5:
                return "Completed";
            case 6:
                return "Transferred";
            default:
                return "Unknown";
        }
    }
}
