package com.mycompany.system.controller;

import com.mycompany.system.dao.PatientDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/patient/book")
public class PatientBookServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null ||
                !"patient".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        PatientDashboardDao dao = new PatientDashboardDao();
        request.setAttribute("clinics", dao.getClinics());
        request.setAttribute("clinicSlots", dao.getClinicSlots());
        request.getRequestDispatcher("/patient/book.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        new PatientBookingLogic().handleBooking(request, response);
    }
}