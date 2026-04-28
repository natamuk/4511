package com.mycompany.system.db;

import com.mycompany.system.bean.ScheduleBean;
import com.mycompany.system.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScheduleDB {

    public static ScheduleBean getById(Long id) {
        String sql = "SELECT * FROM schedule WHERE id = ?";
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

    public static List<ScheduleBean> getAll() {
        List<ScheduleBean> list = new ArrayList<>();
        String sql = "SELECT * FROM schedule ORDER BY schedule_date DESC, time_slot ASC";
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

    public static boolean insert(ScheduleBean schedule) {
        String sql = "INSERT INTO schedule "
                   + "(doctor_id, department_id, clinic_id, schedule_date, week_day, time_slot, "
                   + "max_count, booked_count, status, create_time, update_time) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, schedule.getDoctorId());
            ps.setLong(2, schedule.getDepartmentId());
            ps.setObject(3, schedule.getClinicId());
            ps.setDate(4, schedule.getScheduleDate() != null ? Date.valueOf(schedule.getScheduleDate()) : null);
            ps.setInt(5, schedule.getWeekDay());
            ps.setInt(6, schedule.getTimeSlot());
            ps.setInt(7, schedule.getMaxCount() != null ? schedule.getMaxCount() : 20);
            ps.setInt(8, schedule.getBookedCount() != null ? schedule.getBookedCount() : 0);
            ps.setInt(9, schedule.getStatus() != null ? schedule.getStatus() : 1);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        schedule.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean update(ScheduleBean schedule) {
        String sql = "UPDATE schedule SET booked_count=?, status=?, update_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, schedule.getBookedCount() != null ? schedule.getBookedCount() : 0);
            ps.setInt(2, schedule.getStatus() != null ? schedule.getStatus() : 1);
            ps.setLong(3, schedule.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteById(Long id) {
        String sql = "DELETE FROM schedule WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<ScheduleBean> search(String keyword) {
        List<ScheduleBean> list = new ArrayList<>();
        String sql = "SELECT * FROM schedule WHERE id LIKE ? ORDER BY schedule_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String like = "%" + keyword + "%";
            ps.setString(1, like);
            
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

    private static ScheduleBean mapRow(ResultSet rs) throws SQLException {
        ScheduleBean s = new ScheduleBean();
        s.setId(rs.getLong("id"));
        s.setDoctorId(rs.getLong("doctor_id"));
        s.setDepartmentId(rs.getLong("department_id"));
        s.setClinicId(rs.getObject("clinic_id", Long.class));
        
        Date date = rs.getDate("schedule_date");
        if (date != null) s.setScheduleDate(date.toLocalDate());
        
        s.setWeekDay(rs.getInt("week_day"));
        s.setTimeSlot(rs.getInt("time_slot"));
        s.setMaxCount(rs.getInt("max_count"));
        s.setBookedCount(rs.getInt("booked_count"));
        s.setStatus(rs.getInt("status"));
        
        Timestamp ct = rs.getTimestamp("create_time");
        if (ct != null) s.setCreateTime(ct.toLocalDateTime());
        
        Timestamp ut = rs.getTimestamp("update_time");
        if (ut != null) s.setUpdateTime(ut.toLocalDateTime());
        
        return s;
    }
}