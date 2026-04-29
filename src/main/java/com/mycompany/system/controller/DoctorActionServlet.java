/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        Long id = parseLong(request.getParameter("id"));
        Long statusParam = parseLong(request.getParameter("status"));
        String sourceType = request.getParameter("sourceType");

        HttpSession session = request.getSession(false);
        LoginUser user = (session == null) ? null : (LoginUser) session.getAttribute("loginUser");
        if (user == null || !"doctor".equals(session.getAttribute("role"))) {
            respond(request, response, false, "Unauthorized", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        if (action == null) {
            respond(request, response, false, "Missing action", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (!"callnext".equalsIgnoreCase(action) && id == null) {
            respond(request, response, false, "Missing id", HttpServletResponse.SC_BAD_REQUEST);
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
                        DoctorAppointmentService.reject(conn, id, user.getId());
                        success = true;
                        break;
                    case "update":
                        if (statusParam == null) {
                            throw new IllegalArgumentException("Missing status");
                        }
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
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = e.getMessage();
            success = false;
        }

        respond(request, response, success, message, HttpServletResponse.SC_OK);
    }

    private void respond(HttpServletRequest request, HttpServletResponse response, boolean success, String message, int successStatus) throws IOException {
        String ajaxHeader = request.getHeader("X-Requested-With");
        String accept = request.getHeader("Accept");
        boolean wantsJson = (ajaxHeader != null && "XMLHttpRequest".equalsIgnoreCase(ajaxHeader))
                || (accept != null && accept.contains("application/json"))
                || "true".equalsIgnoreCase(request.getParameter("ajax"));

        if (wantsJson) {
            response.setContentType("application/json;charset=UTF-8");
            response.setStatus(success ? successStatus : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> r = new HashMap<>();
            r.put("success", success);
            if (!success) {
                r.put("message", message == null ? "Operation failed" : message);
            }
            response.getWriter().write(gson.toJson(r));
        } else {
            HttpSession session = request.getSession(true);
            if (success) {
                session.setAttribute("flash_success", "Operation succeeded");
            } else {
                session.setAttribute("flash_error", message == null ? "Operation failed" : message);
            }
            String referer = request.getHeader("Referer");
            if (referer == null || referer.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/doctor/dashboard");
            } else {
                response.sendRedirect(referer);
            }
        }
    }

    private Long parseLong(String v) {
        try {
            return v == null ? null : Long.parseLong(v);
        } catch (Exception e) {
            return null;
        }
    }
}
