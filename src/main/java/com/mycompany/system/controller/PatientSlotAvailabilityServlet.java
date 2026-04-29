package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.dao.PatientDashboardDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/patient/slot-availability")
public class PatientSlotAvailabilityServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        String clinicIdParam = request.getParameter("clinicId");
        String dateParam = request.getParameter("date");
        if (clinicIdParam == null || dateParam == null || clinicIdParam.trim().isEmpty() || dateParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Missing clinicId or date\"}");
            return;
        }

        try {
            Long clinicId = Long.parseLong(clinicIdParam);
            PatientDashboardDao dao = new PatientDashboardDao();
            List<Map<String, Object>> slots = dao.getSlotAvailability(clinicId, dateParam);
            response.getWriter().write(gson.toJson(slots));
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid clinicId\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
}