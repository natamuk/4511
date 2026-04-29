package com.mycompany.system.controller;

import com.mycompany.system.dao.PatientDashboardDao;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

// 唯一映射路径，避免冲突
@WebServlet("/patient/book")
public class PatientBookServlet extends HttpServlet {
    
    // 处理页面跳转（GET请求）
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

    // 处理预约提交（POST请求），直接复用核心预约逻辑
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        new PatientBookingLogic().handleBooking(request, response);
    }
}