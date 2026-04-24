/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.controller;

import com.mycompany.system.bean.PatientBean;
import com.mycompany.system.db.PatientDB;
import com.mycompany.system.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/patient/update-profile")
public class PatientProfileUpdateServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null || !"patient".equals(session.getAttribute("role"))) {
            writeJson(response, 401, false, "Unauthorized");
            return;
        }

        Long patientId = ((LoginUser) session.getAttribute("loginUser")).getId();
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String avatar = request.getParameter("avatar");
        String oldPwd = request.getParameter("oldPwd");
        String newPwd = request.getParameter("newPwd");

        try {
            if (newPwd != null && !newPwd.trim().isEmpty()) {
                PatientBean patient = PatientDB.getById(patientId);
                if (patient == null || !patient.getPassword().equals(oldPwd)) {
                    writeJson(response, 400, false, "Incorrect current password");
                    return;
                }
                if (!PatientDB.updatePassword(patientId, newPwd)) {
                    writeJson(response, 500, false, "Failed to update password");
                    return;
                }
            }

            PatientBean updateBean = new PatientBean();
            updateBean.setId(patientId);
            updateBean.setRealName(name);
            updateBean.setPhone(phone);
            updateBean.setEmail(email);
            updateBean.setAddress(address);
            updateBean.setAvatar(avatar);
            if (PatientDB.update(updateBean)) {
                writeJson(response, 200, true, "Profile updated successfully");
            } else {
                writeJson(response, 500, false, "Failed to update profile");
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, 500, false, "Server error");
        }
    }

    private void writeJson(HttpServletResponse response, int status, boolean success, String message) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}