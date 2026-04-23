<%-- 
    Document   : notifications-contents
    Created on : 2026年4月23日, 23:47:22
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="glass rounded-3xl p-8 max-w-5xl mx-auto">
    <div class="flex items-center justify-between mb-6 border-b pb-4">
        <h3 class="text-2xl font-bold text-gray-800">Alerts & Notifications</h3>
        <button onclick="markAllRead()" class="px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-medium rounded-xl transition"><i class="fa-solid fa-check-double mr-1"></i> Mark All as Read</button>
    </div>
    <div class="space-y-4">
        <c:if test="${empty notifications}">
            <div class="text-center py-16 text-gray-500"><i class="fa-regular fa-bell-slash text-5xl mb-4"></i><p class="text-lg">Inbox is empty.</p></div>
        </c:if>
        <c:forEach var="n" items="${notifications}">
            <div class="p-5 border rounded-2xl bg-white flex items-start gap-4 shadow-sm hover:shadow-md transition cursor-pointer ${n.read ? 'opacity-70' : ''}" onclick="openNotification(${n.id})">
                <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${n.type == 'success' ? 'bg-emerald-100 text-emerald-700' : n.type == 'warning' ? 'bg-amber-100 text-amber-700' : 'bg-blue-100 text-blue-700'}">
                    <i class="fa-solid ${n.type == 'warning' ? 'fa-triangle-exclamation' : 'fa-bell'}"></i>
                </div>
                <div class="flex-1">
                    <div class="flex items-center justify-between gap-4 mb-1">
                        <p class="font-bold text-lg text-gray-800 flex items-center gap-2">
                            ${n.title}
                            <c:if test="${!n.read}"><span class="w-2.5 h-2.5 rounded-full bg-red-500 inline-block shadow-sm shadow-red-200"></span></c:if>
                        </p>
                        <span class="text-xs font-medium text-gray-400 bg-gray-50 px-2 py-1 rounded">${n.time}</span>
                    </div>
                    <p class="text-gray-600">${n.message}</p>
                </div>
            </div>
        </c:forEach>
    </div>
</div>