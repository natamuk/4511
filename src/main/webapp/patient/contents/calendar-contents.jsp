<%-- 
    Document   : calendar-contents
    Created on : 2026年4月22日, 22:05:52
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<%
    List<Map<String,Object>> appointments = (List<Map<String,Object>>) request.getAttribute("appointments");
    if (appointments == null) appointments = new ArrayList<>();

    Calendar today = Calendar.getInstance();
    int currentYear = today.get(Calendar.YEAR);
    int currentMonth = today.get(Calendar.MONTH) + 1;

    String[] monthNames = {
        "January", "February", "March", 
        "April", "May", "June", 
        "July", "August", "September", 
        "October", "November", "December"
    };
    String monthName = monthNames[currentMonth - 1];

    int maxDay = today.getActualMaximum(Calendar.DAY_OF_MONTH);
%>

<div class="glass p-8 rounded-3xl max-w-5xl mx-auto">
    <h3 class="text-2xl font-bold mb-6">Appointment Calendar</h3>

    <div class="mb-4 text-center">
        <h4 class="text-xl font-semibold text-gray-700"><%= monthName %> <%= currentYear %></h4>
    </div>

    <div class="grid grid-cols-7 gap-2 text-center mb-4 font-semibold text-gray-600">
        <div>Sun</div>
        <div>Mon</div>
        <div>Tue</div>
        <div>Wed</div>
        <div>Thu</div>
        <div>Fri</div>
        <div>Sat</div>
    </div>

    <div class="grid grid-cols-7 gap-2">
        <% 
        for(int i=1; i<=maxDay; i++){ 
        %>
        <div class="calendar-day p-4 border rounded-xl flex items-center justify-center font-medium text-lg bg-white hover:bg-blue-50 transition">
            <%= i %>
        </div>
        <% } %>
    </div>
</div>