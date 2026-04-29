/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.RegistrationBean;
import com.mycompany.system.bean.UserNotificationBean;
import com.mycompany.system.db.RegistrationDB;
import com.mycompany.system.db.UserNotificationDB;
import com.mycompany.system.model.LoginUser;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/patient/cancel-booking")
public class PatientCancelBookingServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 统一处理 POST 请求（同时处理 AJAX 和普通表单）
        handleRequest(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 保留 GET 方式兼容旧代码（但建议前端全部改用 POST）
        handleRequest(request, response);
    }

    private void handleRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"))
                || "true".equals(request.getParameter("ajax"));

        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            if (isAjax) {
                writeJson(response, false, "Please login first");
            } else {
                request.setAttribute("error", "Please login first");
                forwardToMyAppointments(request, response);
            }
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();
        Long registrationId = parseLong(request.getParameter("registrationId"));

        if (registrationId == null) {
            if (isAjax) {
                writeJson(response, false, "Missing registration ID");
            } else {
                request.setAttribute("error", "Missing registration ID");
                forwardToMyAppointments(request, response);
            }
            return;
        }

        try {
            RegistrationBean reg = RegistrationDB.getById(registrationId);
            if (reg == null || !patientId.equals(reg.getPatientId())) {
                if (isAjax) {
                    writeJson(response, false, "Booking not found or not yours");
                } else {
                    request.setAttribute("error", "Booking not found or not yours");
                    forwardToMyAppointments(request, response);
                }
                return;
            }

            if (reg.getStatus() != 1) {
                if (isAjax) {
                    writeJson(response, false, "Only booked appointments can be cancelled");
                } else {
                    request.setAttribute("error", "Only booked appointments can be cancelled");
                    forwardToMyAppointments(request, response);
                }
                return;
            }

            boolean success = RegistrationDB.cancelBooking(registrationId, reg.getScheduleId());

            if (success) {
                UserNotificationBean note = new UserNotificationBean();
                note.setUserId(patientId);
                note.setUserType(3);
                note.setTitle("Appointment Cancelled");
                note.setMessage("Your appointment has been cancelled successfully.");
                note.setType("warning");
                UserNotificationDB.insert(note);

                if (isAjax) {
                    writeJson(response, true, "Booking cancelled successfully");
                } else {
                    request.setAttribute("success", "Booking cancelled successfully");
                    forwardToMyAppointments(request, response);
                }
            } else {
                if (isAjax) {
                    writeJson(response, false, "Failed to cancel booking");
                } else {
                    request.setAttribute("error", "Failed to cancel booking");
                    forwardToMyAppointments(request, response);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (isAjax) {
                writeJson(response, false, "Server error occurred");
            } else {
                request.setAttribute("error", "Server error occurred");
                forwardToMyAppointments(request, response);
            }
        }
    }

    private void forwardToMyAppointments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/patient/myappointments").forward(request, response);
    }

    private void writeJson(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", message);
        response.getWriter().write(gson.toJson(result));
    }

    private Long parseLong(String value) {
        try {
            return Long.parseLong(value);
        } catch (Exception e) {
            return null;
        }
    }
}