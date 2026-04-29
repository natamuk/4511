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
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/patient/cancel-booking")
public class PatientCancelBookingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            request.setAttribute("error", "Please login first");
            request.getRequestDispatcher("/patient/myappointments").forward(request, response);
            return;
        }

        LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
        Long patientId = loginUser.getId();
        Long registrationId = parseLong(request.getParameter("registrationId"));

        if (registrationId == null) {
            request.setAttribute("error", "Missing registration ID");
            request.getRequestDispatcher("/patient/myappointments").forward(request, response);
            return;
        }

        try {
            RegistrationBean reg = RegistrationDB.getById(registrationId);

            if (reg == null || !patientId.equals(reg.getPatientId())) {
                request.setAttribute("error", "Booking not found or not yours");
                request.getRequestDispatcher("/patient/myappointments").forward(request, response);
                return;
            }

            if (reg.getStatus() != 1) {
                request.setAttribute("error", "Only booked appointments can be cancelled");
                request.getRequestDispatcher("/patient/myappointments").forward(request, response);
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

                request.setAttribute("success", "Booking cancelled successfully");
            } else {
                request.setAttribute("error", "Failed to cancel booking");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error occurred");
        }

        request.getRequestDispatcher("/patient/myappointments").forward(request, response);
    }

    private Long parseLong(String value) {
        try {
            return Long.parseLong(value);
        } catch (Exception e) {
            return null;
        }
    }
}