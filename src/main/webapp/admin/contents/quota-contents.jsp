<%-- 
    Document   : quota-contents
    Created on : 2026年4月23日, 23:47:05
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="max-w-5xl mx-auto space-y-8">
    <div class="glass p-8 rounded-3xl">
        <h3 class="text-2xl font-bold mb-6 border-b pb-4 text-gray-800">Service Capacity Overview</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <c:forEach var="item" items="${quota}">
                <c:set var="pct" value="${item.capacity > 0 ? (item.booked / item.capacity * 100) : 0}" />
                <div class="p-5 border rounded-2xl bg-white shadow-sm flex flex-col justify-between">
                    <div class="flex justify-between items-start mb-4">
                        <div class="font-bold text-lg text-gray-800">${item.service}</div>
                        <span class="px-2 py-1 text-xs font-bold rounded ${pct >= 80 ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'}">${pct}% Full</span>
                    </div>
                    <div>
                        <div class="w-full bg-gray-200 rounded-full h-2.5 mb-2">
                            <div class="h-2.5 rounded-full ${pct >= 80 ? 'bg-red-500' : 'bg-emerald-500'}" style="width:${pct}%"></div>
                        </div>
                        <div class="text-sm text-gray-500 font-medium">Booked: <b>${item.booked}</b> / ${item.capacity}</div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    <div class="glass p-8 rounded-3xl">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-bold text-gray-800">Clinic Branches</h3>
            <button onclick="Swal.fire('Info','Add clinic form goes here','info')" class="text-sm text-indigo-600 font-medium hover:underline">+ Add New</button>
        </div>
        <div class="space-y-4">
            <c:forEach var="cn" items="${clinics}">
                <div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center md:justify-between gap-4 shadow-sm hover:shadow-md transition">
                    <div>
                        <p class="font-bold text-lg text-gray-800">${cn.name}</p>
                        <p class="text-sm text-gray-500 mt-1"><i class="fa-solid fa-location-dot mr-1"></i> ${cn.location} ${cn.address}</p>
                    </div>
                    <div class="flex items-center gap-3">
                        <span class="badge ${cn.active ? 'badge-success' : 'badge-danger'}">${cn.active ? 'Active' : 'Inactive'}</span>
                        <button class="p-2 text-gray-400 hover:text-indigo-600 transition"><i class="fa-solid fa-pen-to-square"></i></button>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>