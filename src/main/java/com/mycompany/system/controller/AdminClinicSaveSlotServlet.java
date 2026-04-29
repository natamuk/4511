package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.bean.ClinicTimeSlotBean;
import com.mycompany.system.db.ClinicTimeSlotDB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/clinic/saveSlot")
public class AdminClinicSaveSlotServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 由于前端是普通表单提交（非 fetch），这里直接重定向并带消息
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String clinicIdStr = request.getParameter("clinicId");
        String period = request.getParameter("period");
        String slotTime = request.getParameter("slotTime");
        String capacityStr = request.getParameter("capacity");

        if (clinicIdStr == null || period == null || slotTime == null || capacityStr == null) {
            session.setAttribute("errorMsg", "Missing parameters");
            response.sendRedirect(request.getContextPath() + "/admin/clinic_config.jsp");
            return;
        }

        try {
            Long clinicId = Long.parseLong(clinicIdStr);
            int capacity = Integer.parseInt(capacityStr);

            ClinicTimeSlotBean slot = new ClinicTimeSlotBean();
            slot.setClinicId(clinicId);
            slot.setPeriod(period);
            slot.setSlotTime(slotTime);
            slot.setCapacity(capacity);
            slot.setStatus(1);

            boolean success = ClinicTimeSlotDB.insert(slot);
            if (success) {
                session.setAttribute("successMsg", "Time slot added");
            } else {
                session.setAttribute("errorMsg", "Failed to add time slot");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Invalid number format");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Server error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/clinic_config.jsp");
    }
}