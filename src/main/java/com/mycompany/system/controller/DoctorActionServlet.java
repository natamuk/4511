package com.mycompany.system.controller;

import com.google.gson.Gson;
import com.mycompany.system.model.LoginUser;
import com.mycompany.system.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/doctor/action")
public class DoctorActionServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        Long id = parseLong(request.getParameter("id"));
        Long statusParam = parseLong(request.getParameter("status"));
        String sourceType = request.getParameter("sourceType");
        String reason = request.getParameter("reason");

        HttpSession session = request.getSession(false);
        LoginUser user = (session == null) ? null : (LoginUser) session.getAttribute("loginUser");
        if (user == null || !"doctor".equals(session.getAttribute("role"))) {
            respondJson(response, false, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        if (action == null) {
            respondJson(response, false, "Missing action", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (!"callnext".equalsIgnoreCase(action) && id == null) {
            respondJson(response, false, "Missing id", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        boolean success = false;
        String message = null;

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                switch (action.toLowerCase()) {
                    case "approve":
                        DoctorAppointmentService.approve(conn, id, user.getId());
                        success = true;
                        break;
                    case "reject":
                        DoctorAppointmentService.reject(conn, id, user.getId(), reason);
                        success = true;
                        break;
                    case "update":
                        if (statusParam == null) throw new IllegalArgumentException("Missing status");
                        if ("QUEUE".equalsIgnoreCase(sourceType)) {
                            String qStatus = statusParam == 3 ? "called" : (statusParam == 4 ? "consulting" : "completed");
                            DoctorQueueService.updateStatus(conn, id, qStatus);
                        } else {
                            DoctorAppointmentService.updateStatus(conn, id, user.getId(), statusParam.intValue());
                        }
                        success = true;
                        break;
                    case "skip":
                        if ("QUEUE".equalsIgnoreCase(sourceType)) {
                            DoctorQueueService.skip(conn, id);
                        } else {
                            DoctorAppointmentService.skip(conn, id, user.getId());
                        }
                        success = true;
                        break;
                    case "callnext":
                        DoctorCallNextService.callNext(conn, user.getId());
                        success = true;
                        break;
                    default:
                        throw new IllegalArgumentException("Unknown action: " + action);
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                message = e.getMessage();
                success = false;
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
            success = false;
        }

        respondJson(response, success, message, success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }

    private void respondJson(HttpServletResponse response, boolean success, String message, int statusCode) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(statusCode);
        Map<String, Object> r = new HashMap<>();
        r.put("success", success);
        if (!success) r.put("message", message == null ? "Operation failed" : message);
        response.getWriter().write(gson.toJson(r));
    }

    private Long parseLong(String v) {
        try { return v == null ? null : Long.parseLong(v); } catch (Exception e) { return null; }
    }
}