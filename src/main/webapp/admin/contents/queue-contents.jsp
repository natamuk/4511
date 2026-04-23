<%-- 
    Document   : queue-contents
    Created on : 2026年4月23日, 23:47:00
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="glass rounded-3xl p-8">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6 border-b pb-4">
        <div>
            <h3 class="text-2xl font-semibold text-gray-800">Live Same-day Queue</h3>
            <p class="text-sm text-gray-500 mt-1 font-medium">Currently ${queueList.size()} patients active in queue</p>
        </div>
    </div>
    <div class="space-y-4">
        <c:if test="${empty queueList}">
            <div class="text-center py-16">
                <i class="fa-solid fa-users-slash text-6xl text-gray-300 mb-4"></i>
                <p class="text-gray-500 text-lg">No patients in queue</p>
            </div>
        </c:if>
        <c:forEach var="item" items="${queueList}">
            <div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm hover:shadow-md transition">
                <div class="flex-1">
                    <div class="flex items-center gap-3 mb-1">
                        <span class="font-mono font-bold text-xl text-indigo-600 bg-indigo-50 px-2 py-1 rounded">${item.ticketNo}</span>
                        <p class="font-bold text-lg text-gray-800">${item.patient}</p>
                    </div>
                    <p class="text-sm text-gray-600 font-medium">${item.clinic} • <span class="text-gray-500">${item.service}</span></p>
                </div>
                <div><span class="badge badge-info shadow-sm">${item.status}</span></div>
            </div>
        </c:forEach>
    </div>
</div>