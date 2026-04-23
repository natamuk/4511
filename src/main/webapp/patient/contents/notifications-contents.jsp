<%-- 
    Document   : notifications-contents
    Created on : 2026年4月22日, 22:15:53
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<%
    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");
    if (notifications == null)
        notifications = new ArrayList<>();
%>

<div class="max-w-4xl mx-auto glass rounded-3xl p-8">
    <h3 class="text-2xl font-semibold mb-6">Notifications</h3>
    <div class="space-y-4">
        <% for (Map<String, Object> n : notifications) {%>
        <div class="p-4 border rounded-2xl bg-white flex items-start gap-4 shadow-sm">
            <div class="w-10 h-10 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center">
                <i class="fa-solid fa-bell"></i>
            </div>
            <div class="flex-1">
                <p class="font-semibold text-gray-800"><%= n.get("title")%></p>
                <p class="text-gray-600 mt-1"><%= n.get("message")%></p>
            </div>
        </div>
        <% } %>

        <% if (notifications.isEmpty()) { %>
        <div class="text-center py-12 text-gray-500">
            <i class="fa-regular fa-bell-slash text-4xl mb-3"></i>
            <p>No notifications</p>
        </div>
        <% }%>
    </div>
</div>