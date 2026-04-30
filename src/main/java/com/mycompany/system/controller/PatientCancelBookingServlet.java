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
import com.mycompany.system.dao.PatientDashboardDao;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/patient/cancel-booking")
public class PatientCancelBookingServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleRequest(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
                redirectToMyAppointmentsWithMessage(request, response, "error", "Please login first");
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
                redirectToMyAppointmentsWithMessage(request, response, "error", "Missing registration ID");
            }
            return;
        }

        try {
            RegistrationBean reg = RegistrationDB.getById(registrationId);
            if (reg == null || !patientId.equals(reg.getPatientId())) {
                if (isAjax) {
                    writeJson(response, false, "Booking not found or not yours");
                } else {
                    redirectToMyAppointmentsWithMessage(request, response, "error", "Booking not found or not yours");
                }
                return;
            }

            if (reg.getStatus() != 1) {
                if (isAjax) {
                    writeJson(response, false, "Only booked appointments can be cancelled");
                } else {
                    redirectToMyAppointmentsWithMessage(request, response, "error", "Only booked appointments can be cancelled");
                }
                return;
            }

            PatientDashboardDao dao = new PatientDashboardDao();
            int deadlineHours = dao.getCancelDeadlineHours();
            Timestamp appointmentDateTime = getAppointmentDateTime(reg.getRegDate(), reg.getSlotTime());
            Timestamp now = new Timestamp(System.currentTimeMillis());
            long hoursDiff = (appointmentDateTime.getTime() - now.getTime()) / (3600_000L);
            if (hoursDiff < deadlineHours) {
                String errorMsg = "You can only cancel at least " + deadlineHours + " hours before the appointment time.";
                if (isAjax) {
                    writeJson(response, false, errorMsg);
                } else {
                    redirectToMyAppointmentsWithMessage(request, response, "error", errorMsg);
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
                    redirectToMyAppointmentsWithMessage(request, response, "success", "Booking cancelled successfully");
                }
            } else {
                if (isAjax) {
                    writeJson(response, false, "Failed to cancel booking");
                } else {
                    redirectToMyAppointmentsWithMessage(request, response, "error", "Failed to cancel booking");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (isAjax) {
                writeJson(response, false, "Server error occurred");
            } else {
                redirectToMyAppointmentsWithMessage(request, response, "error", "Server error occurred");
            }
        }
    }

    private Timestamp getAppointmentDateTime(java.sql.Date regDate, String slotTime) {
        if (regDate == null || slotTime == null || slotTime.trim().isEmpty()) {
            return new Timestamp(System.currentTimeMillis());
        }
        String time = slotTime.trim();
        if (time.length() == 5 && time.indexOf(':') == 2) {
            time = time + ":00";
        }
        String dateTimeStr = regDate.toString() + " " + time;
        return Timestamp.valueOf(dateTimeStr);
    }

    private void redirectToMyAppointmentsWithMessage(HttpServletRequest request, HttpServletResponse response, String type, String message)
            throws IOException {
        HttpSession session = request.getSession();
        if ("success".equals(type)) {
            session.setAttribute("successMsg", message);
        } else {
            session.setAttribute("errorMsg", message);
        }
        response.sendRedirect(request.getContextPath() + "/patient/myappointments");
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