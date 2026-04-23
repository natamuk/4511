<%-- 
    Document   : reports-contents
    Created on : 2026年4月23日, 23:47:10
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="max-w-7xl mx-auto space-y-8">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="glass p-6 rounded-3xl text-center shadow-sm"><div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Cancellation Rate</div><div class="text-5xl font-bold text-red-500 mt-3">8%</div></div>
        <div class="glass p-6 rounded-3xl text-center shadow-sm"><div class="text-sm font-medium text-gray-500 uppercase tracking-wider">No-show Rate</div><div class="text-5xl font-bold text-amber-500 mt-3">6%</div></div>
        <div class="glass p-6 rounded-3xl text-center shadow-sm"><div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Avg Wait Time</div><div class="text-5xl font-bold text-indigo-600 mt-3">18 <span class="text-xl">min</span></div></div>
    </div>
    <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
        <div class="glass p-8 rounded-3xl">
            <h3 class="text-xl font-bold mb-6 text-gray-800">Service Capacity Data</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-sm text-left">
                    <thead class="border-b bg-gray-50">
                        <tr><th class="py-3 px-4 font-semibold text-gray-600 rounded-tl-lg">Service</th><th class="py-3 px-4 font-semibold text-gray-600 text-center">Used</th><th class="py-3 px-4 font-semibold text-gray-600 text-center">Capacity</th><th class="py-3 px-4 font-semibold text-gray-600 text-center rounded-tr-lg">Rate</th></tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <c:forEach var="x" items="${quota}">
                            <c:set var="r" value="${x.capacity > 0 ? (x.booked / x.capacity * 100) : 0}" />
                            <tr class="hover:bg-gray-50">
                                <td class="py-3 px-4 font-medium text-gray-800">${x.service}</td>
                                <td class="px-4 text-center font-bold text-indigo-600">${x.booked}</td>
                                <td class="px-4 text-center text-gray-500">${x.capacity}</td>
                                <td class="px-4 text-center"><span class="px-2 py-1 rounded text-xs font-bold ${r >= 80 ? 'bg-red-100 text-red-700' : 'bg-emerald-100 text-emerald-700'}">${r}%</span></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="glass p-8 rounded-3xl border border-red-100 shadow-sm bg-red-50/30">
            <h3 class="text-xl font-bold mb-4 text-red-700"><i class="fa-solid fa-triangle-exclamation mr-2"></i> Incident Records</h3>
            <div class="p-6 border-2 border-dashed border-red-200 rounded-2xl text-center bg-white">
                <i class="fa-regular fa-folder-open text-4xl text-red-300 mb-3"></i>
                <div class="text-gray-500 font-medium">No recent incidents reported.</div>
            </div>
        </div>
    </div>
</div>