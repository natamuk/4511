<%-- 
    Document   : logs-contents
    Created on : 2026年4月23日, 23:47:17
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="glass p-8 rounded-3xl max-w-6xl mx-auto">
    <div class="flex justify-between items-center mb-6 border-b pb-4">
        <h3 class="text-2xl font-bold text-gray-800">System Activity Log</h3>
        <button class="text-sm font-medium text-indigo-600 hover:text-indigo-800 transition"><i class="fa-solid fa-download mr-1"></i> Export Log</button>
    </div>
    <div class="space-y-4">
        <c:if test="${empty logs}">
            <div class="text-center py-12 text-gray-500"><i class="fa-solid fa-clipboard-list text-4xl mb-3"></i><p>No activity logs found.</p></div>
        </c:if>
        <c:forEach var="i" items="${logs}">
            <div class="p-4 border rounded-2xl bg-white shadow-sm flex items-start gap-4">
                <div class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 text-gray-500">
                    <i class="fa-solid fa-desktop"></i>
                </div>
                <div>
                    <p class="font-medium text-gray-800">${i.action}</p>
                    <p class="text-sm text-gray-500 mt-1 font-mono">${i.createdAt}</p>
                </div>
            </div>
        </c:forEach>
    </div>
</div>