package com.mycompany.system.servlet.admin;

import com.mycompany.system.bean.ClinicBean;
import com.mycompany.system.db.ClinicDB;
import com.mycompany.system.util.DBUtil;
import com.google.gson.Gson;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet(urlPatterns = {"/admin/settingsData", "/admin/settings/save"})
public class SettingsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (req.getServletPath().equals("/admin/settingsData")) {
            resp.setContentType("application/json");
            Map<String, Object> result = new HashMap<>();
            Map<String, String> settings = new HashMap<>();
            try (Connection conn = DBUtil.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery("SELECT setting_key, setting_value FROM system_setting")) {
                while (rs.next()) {
                    settings.put(rs.getString("setting_key"), rs.getString("setting_value"));
                }
            } catch (SQLException e) { e.printStackTrace(); }
            List<ClinicBean> clinics = ClinicDB.getAll();
            result.put("settings", settings);
            result.put("clinics", clinics);
            resp.getWriter().write(new Gson().toJson(result));
        }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (req.getServletPath().equals("/admin/settings/save")) {
            String maxActive = req.getParameter("max_active_bookings_per_patient");
            String cancelHours = req.getParameter("cancel_deadline_hours");
            String queueEnabled = req.getParameter("same_day_queue_enabled");
            String approvalRequired = req.getParameter("booking_approval_required");
            String walkinClinics = req.getParameter("walkin_enabled_clinics");
            try (Connection conn = DBUtil.getConnection()) {
                String sql = "INSERT INTO system_setting (setting_key, setting_value) VALUES (?,?) ON DUPLICATE KEY UPDATE setting_value=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, "max_active_bookings_per_patient");
                    ps.setString(2, maxActive);
                    ps.setString(3, maxActive);
                    ps.executeUpdate();
                    ps.setString(1, "cancel_deadline_hours");
                    ps.setString(2, cancelHours);
                    ps.setString(3, cancelHours);
                    ps.executeUpdate();
                    ps.setString(1, "same_day_queue_enabled");
                    ps.setString(2, queueEnabled);
                    ps.setString(3, queueEnabled);
                    ps.executeUpdate();
                    ps.setString(1, "booking_approval_required");
                    ps.setString(2, approvalRequired);
                    ps.setString(3, approvalRequired);
                    ps.executeUpdate();
                    ps.setString(1, "walkin_enabled_clinics");
                    ps.setString(2, walkinClinics);
                    ps.setString(3, walkinClinics);
                    ps.executeUpdate();
                }
            } catch (SQLException e) { e.printStackTrace(); }
            resp.setContentType("application/json");
            resp.getWriter().write("{\"success\":true,\"message\":\"Settings saved\"}");
        }
    }
}