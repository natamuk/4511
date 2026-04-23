<%-- 
    Document   : my-appointments-contents
    Created on : 2026年4月22日, 22:06:00
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<%
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    if (appointments == null)
        appointments = new ArrayList<>();
%>

<div class="max-w-5xl mx-auto space-y-6">
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6">
            <h3 class="text-2xl font-semibold">My Appointments</h3>
            <button onclick="loadPage('book')" class="px-4 py-2 bg-blue-600 text-white rounded-xl shadow-sm hover:bg-blue-700 transition">New Booking</button>
        </div>

        <div class="space-y-4">
            <% for (Map<String, Object> item : appointments) {
                    String status = (String) item.get("status");
                    String statusClass = "";

                    if ("Booked".equals(status)) {
                        statusClass = "bg-blue-50 text-blue-700 border-blue-200";
                    } else if ("Completed".equals(status)) {
                        statusClass = "bg-green-50 text-green-700 border-green-200";
                    } else {
                        statusClass = "bg-red-50 text-red-700 border-red-200";
                    }
            %>

            <div class="p-6 border rounded-3xl bg-white flex flex-col md:flex-row md:items-center md:justify-between gap-6 shadow-sm hover:shadow-md transition">
                <div class="flex-1">
                    <div class="flex items-center gap-3 mb-2">
                        <h4 class="font-bold text-xl text-gray-800"><%= item.get("clinicName")%></h4>
                        <span class="px-3 py-1 rounded-full text-xs font-bold border <%= statusClass%>"><%= status%></span>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-gray-600 mt-3">
                        <p><i class="fa-regular fa-calendar text-gray-400 w-5"></i> <b>Date:</b> <%= item.get("date")%></p>
                        <p><i class="fa-regular fa-clock text-gray-400 w-5"></i> <b>Time:</b> <%= item.get("timeSlot")%></p>
                        <p><i class="fa-solid fa-user-doctor text-gray-400 w-5"></i> <b>Doctor:</b> <%= item.get("doctorName")%></p>
                        <p><i class="fa-solid fa-ticket text-gray-400 w-5"></i> <b>Queue No:</b> <%= item.get("queueNo")%></p>
                    </div>
                </div>

                <div class="flex flex-col sm:flex-row gap-3 md:w-auto w-full pt-4 md:pt-0 border-t md:border-t-0 border-gray-100">
                    <button class="flex-1 px-4 py-2.5 rounded-xl bg-blue-50 hover:bg-blue-100 text-blue-700 font-medium transition">
                        <i class="fa-solid fa-qrcode"></i> QR
                    </button>

                    <% if ("Booked".equals(status)) { %>
                    <button class="flex-1 px-4 py-2.5 rounded-xl bg-amber-50 hover:bg-amber-100 text-amber-700 font-medium transition">
                        <i class="fa-regular fa-pen-to-square"></i> Reschedule
                    </button>
                    <button class="flex-1 px-4 py-2.5 rounded-xl bg-red-50 hover:bg-red-100 text-red-600 font-medium transition">
                        <i class="fa-solid fa-xmark"></i> Cancel
                    </button>
                    <% } %>
                </div>
            </div>
            <% } %>

            <% if (appointments.isEmpty()) { %>
            <div class="text-center py-16 text-gray-500">
                <i class="fa-regular fa-calendar-xmark text-5xl mb-4"></i>
                <p class="text-lg">No records found</p>
            </div>
            <% }%>
        </div>
    </div>
</div>