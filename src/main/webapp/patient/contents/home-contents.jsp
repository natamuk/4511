<%-- 
    Document   : home-contents
    Created on : 2026年4月22日, 21:09:12
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*,java.text.SimpleDateFormat,java.util.stream.Collectors" %>
<%
    String realName = (String) session.getAttribute("realName");
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    List<Map<String, Object>> queue = (List<Map<String, Object>>) request.getAttribute("queue");
    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");
    if (realName == null) {
        realName = "User";
    }
    if (appointments == null) {
        appointments = new ArrayList<>();
    }
    if (queue == null) {
        queue = new ArrayList<>();
    }
    if (notifications == null)
        notifications = new ArrayList<>();
%>
<div class="max-w-6xl mx-auto space-y-10">
    <div class="text-left">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-800 mb-2">Welcome back, <%= realName%></h1>
        <p class="text-gray-500 text-lg">Today is <%= new SimpleDateFormat("MMMM dd, yyyy").format(new Date())%></p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
            <div class="absolute top-0 right-0 w-24 h-24 bg-blue-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
            <div class="relative">
                <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-calendar-check text-blue-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Next Appointment</h3></div>
                <p class="text-2xl font-bold text-gray-800 mt-2 mb-2">
                    <%= !appointments.isEmpty() ? appointments.get(0).get("date") + " " + (appointments.get(0).get("timeSlot") != null ? appointments.get(0).get("timeSlot") : "") : "No appointments yet"%>
                </p>
                <p onclick="loadPage('my')" class="text-blue-600 font-medium cursor-pointer hover:underline">Manage Appointments</p>
            </div>
        </div>

        <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
            <div class="absolute top-0 right-0 w-24 h-24 bg-emerald-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
            <div class="relative">
                <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-users-line text-emerald-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Current Queue</h3></div>
                <p class="text-4xl font-bold text-emerald-600 mt-2 mb-2">
                    <%= !queue.isEmpty() ? queue.get(0).get("queueNo") : "N/A"%>
                </p>
                <p onclick="loadPage('queue')" class="text-gray-500 cursor-pointer hover:underline">View Live Queue</p>
            </div>
        </div>

        <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
            <div class="absolute top-0 right-0 w-24 h-24 bg-purple-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
            <div class="relative">
                <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-bell text-purple-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Latest Notification</h3></div>
                <div class="space-y-3 mt-2 text-base">
                    <p class="text-emerald-600 font-medium">✓ System is operating normally</p>
                    <p class="text-gray-600"><%= !notifications.isEmpty() ? notifications.get(0).get("title") : "No notifications yet"%></p>
                </div>
            </div>
        </div>
    </div>

    <div>
        <h2 class="text-2xl font-bold mb-6 text-gray-800">Quick Services</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
            <div onclick="loadPage('book')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-calendar-plus text-blue-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Book Appointment</p></div>
            <div onclick="loadPage('queue')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-ticket text-emerald-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Join Queue</p></div>
            <div onclick="loadPage('my')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-list-check text-purple-600 text-3xl mb-3"></i><p class="font-semibold mt-2">My Appointments</p></div>
            <div onclick="loadPage('profile')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-user-shield text-amber-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Security</p></div>
        </div>
    </div>

    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-4">
            <h2 class="text-2xl font-bold text-gray-800">Notifications</h2>
            <button onclick="loadPage('notifications')" class="text-sm text-blue-600 font-medium hover:underline">View All</button>
        </div>
        <div class="space-y-4">
            <%= !notifications.isEmpty() ? notifications.stream().limit(3).map(n -> "<div class=\"p-4 border rounded-2xl bg-white flex items-start gap-4 shadow-sm\"><div class=\"w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 " + ("success".equals(n.get("type")) ? "bg-green-100 text-green-700" : "warning".equals(n.get("type")) ? "bg-yellow-100 text-yellow-700" : "bg-blue-100 text-blue-700") + "\"><i class=\"fa-solid fa-bell\"></i></div><div class=\"flex-1\"><div class=\"flex items-center justify-between gap-4\"><p class=\"font-semibold text-gray-800\">" + n.get("title") + "</p><span class=\"text-xs text-gray-400 whitespace-nowrap\">" + (n.get("time") != null ? n.get("time") : "") + "</span></div><p class=\"text-gray-600 mt-1\">" + n.get("message") + "</p></div></div>").collect(Collectors.joining("")) : "<div class=\"text-center py-8 text-gray-500\"><i class=\"fa-regular fa-bell-slash text-4xl mb-3\"></i><p>No notifications yet</p></div>"%>
        </div>
    </div>
</div>