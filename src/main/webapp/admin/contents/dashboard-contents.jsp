<%-- 
    Document   : dashboard-contents
    Created on : 2026年4月23日, 23:46:39
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    long noShowCancelCount = 0;
    List<Map<String,Object>> appointments = (List<Map<String,Object>>) request.getAttribute("appointments");
    List<Map<String,Object>> quota = (List<Map<String,Object>>) request.getAttribute("quota");

    if(appointments != null){
        for(Map<String,Object> item : appointments){
            String status = item.get("status")==null?"":item.get("status").toString();
            if("no_show".equals(status) || "cancelled".equals(status)){
                noShowCancelCount++;
            }
        }
    }

    int avgLoadPercent = 0;
    if(quota != null && !quota.isEmpty()){
        double totalRate = 0;
        for(Map<String,Object> item : quota){
            double booked = item.get("booked")==null?0:Double.parseDouble(item.get("booked").toString());
            double capacity = item.get("capacity")==null?1:Double.parseDouble(item.get("capacity").toString());
            if(capacity < 1) capacity = 1;
            totalRate += (booked / capacity);
        }
        avgLoadPercent = (int)Math.round((totalRate / quota.size()) * 100);
    }
%>

<div class="max-w-7xl mx-auto space-y-8">
    <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
        <div>
            <h1 class="text-4xl font-bold text-gray-800 mb-2">Admin Console</h1>
            <p class="text-gray-500">Monitor clinic operations, appointment trends, and system events</p>
        </div>
        <div class="flex gap-3 flex-wrap items-center">
            <button onclick="addUser()" class="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 transition text-white font-medium shadow-sm">Add User</button>
            <button onclick="loadPage('appointments')" class="px-4 py-2 rounded-xl bg-white border hover:bg-gray-50 transition text-gray-700 font-medium shadow-sm">Appointments</button>
            <button onclick="loadPage('reports')" class="px-4 py-2 rounded-xl bg-white border hover:bg-gray-50 transition text-gray-700 font-medium shadow-sm">View Reports</button>
        </div>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <div class="card glass p-6 rounded-3xl">
            <div class="text-sm text-gray-500 font-medium">Total Appointments</div>
            <div class="text-4xl font-bold text-indigo-600 mt-2">${appointments.size()}</div>
            <div class="text-xs text-gray-400 mt-2">All appointment records</div>
        </div>
        <div class="card glass p-6 rounded-3xl">
            <div class="text-sm text-gray-500 font-medium">Queue Waiting</div>
            <div class="text-4xl font-bold text-emerald-600 mt-2">${queueList.size()}</div>
            <div class="text-xs text-gray-400 mt-2">Same-day queue patients</div>
        </div>
        <div class="card glass p-6 rounded-3xl">
            <div class="text-sm text-gray-500 font-medium">No-show / Cancelled</div>
            <div class="text-4xl font-bold text-amber-600 mt-2"><%= noShowCancelCount %></div>
            <div class="text-xs text-gray-400 mt-2">Risk status total</div>
        </div>
        <div class="card glass p-6 rounded-3xl">
            <div class="text-sm text-gray-500 font-medium">Average Service Load</div>
            <div class="text-4xl font-bold text-violet-600 mt-2" id="avg-load-value"><%= avgLoadPercent %>%</div>
            <div class="text-xs text-gray-400 mt-2">Average utilization rate</div>
        </div>
    </div>
    <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <div class="glass p-6 rounded-3xl">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-xl font-bold">Weekly Booking Trend</h3>
                <span class="text-sm text-gray-500 border border-gray-200 px-3 py-1 rounded-lg bg-gray-50">Last 7 days</span>
            </div>
            <div class="h-64 flex items-center justify-center text-gray-400"><canvas id="bookingChart"></canvas></div>
        </div>
        <div class="glass p-6 rounded-3xl">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-xl font-bold">Service Utilization</h3>
                <span class="text-sm text-gray-500 border border-gray-200 px-3 py-1 rounded-lg bg-gray-50">Overall distribution</span>
            </div>
            <div class="h-64 flex items-center justify-center text-gray-400"><canvas id="serviceChart"></canvas></div>
        </div>
    </div>
</div>