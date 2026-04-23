<%-- 
    Document   : appointments-contents
    Created on : 2026年4月23日, 23:46:55
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="glass rounded-3xl p-8">
    <h3 class="text-2xl font-semibold mb-6 border-b pb-4">Appointment Overview</h3>
    <div class="overflow-x-auto">
        <table class="w-full text-sm text-left min-w-[1000px]">
            <thead class="bg-gray-50 text-gray-600 border-b">
                <tr><th class="py-4 px-4 rounded-tl-xl">Date & Time</th><th class="py-4 px-4">Ticket No.</th><th class="py-4 px-4">Patient Name</th><th class="py-4 px-4">Doctor</th><th class="py-4 px-4">Department</th><th class="py-4 px-4 rounded-tr-xl">Status</th></tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                <c:if test="${empty appointments}">
                    <tr><td colspan="6" class="text-center py-10 text-gray-500">No appointment records</td></tr>
                </c:if>
                <c:forEach var="a" items="${appointments}">
                    <tr class="hover:bg-gray-50 transition">
                        <td class="py-4 px-4 font-medium">${a.date} ${a.time}</td>
                        <td class="px-4 font-mono text-indigo-600">${a.regNo}</td>
                        <td class="px-4 font-bold text-gray-800">${a.patient}</td>
                        <td class="px-4">${a.doctor}</td>
                        <td class="px-4">${a.department}</td>
                        <td class="px-4"><span class="badge ${a.status=='Completed'?'badge-success':(a.status=='Cancelled'||a.status=='no_show'?'badge-danger':'badge-info')}">${a.status}</span></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>