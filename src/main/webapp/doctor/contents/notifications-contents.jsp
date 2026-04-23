<%-- 
    Document   : notifications-contents
    Created on : 2026年4月23日, 02:22:57
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class='glass rounded-3xl p-6 max-w-4xl'>
    <div class='flex justify-between items-center mb-6'>
        <h3 class='text-2xl font-semibold'>Recent Alerts</h3>
        <button class='text-sm text-blue-600 hover:underline font-medium' onclick='Swal.fire("Marked", "All marked as read", "success")'>Mark all as read</button>
    </div>
    <div class='space-y-3' id="notification-list">
        <div class="py-10 text-center text-gray-500">No notifications.</div>
    </div>
</div>