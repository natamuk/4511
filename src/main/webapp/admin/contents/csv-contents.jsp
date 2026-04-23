<%-- 
    Document   : csv-contents
    Created on : 2026年4月23日, 23:47:31
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="max-w-4xl mx-auto glass p-10 rounded-3xl text-center">
    <h3 class="text-3xl font-bold mb-2 text-gray-800">Data Import & Export</h3>
    <p class="text-gray-500 mb-10">Manage batch data operations using CSV format.</p>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <button onclick="Swal.fire('Info','Export functionality can be connected to a backend API.','info')" class="p-10 bg-white border rounded-3xl hover:border-emerald-500 hover:shadow-xl transition group">
            <div class="w-20 h-20 mx-auto bg-emerald-50 rounded-full flex items-center justify-center mb-6 group-hover:scale-110 transition">
                <i class="fa-solid fa-file-export text-emerald-600 text-3xl"></i>
            </div>
            <p class="text-xl font-bold text-gray-800 mb-2">Export Data</p>
            <p class="text-sm text-gray-500">Download appointment records and user data.</p>
        </button>
        <button onclick="Swal.fire('Info','Import functionality can be connected to a backend API.','info')" class="p-10 bg-white border rounded-3xl hover:border-indigo-500 hover:shadow-xl transition group">
            <div class="w-20 h-20 mx-auto bg-indigo-50 rounded-full flex items-center justify-center mb-6 group-hover:scale-110 transition">
                <i class="fa-solid fa-file-import text-indigo-600 text-3xl"></i>
            </div>
            <p class="text-xl font-bold text-gray-800 mb-2">Import CSV</p>
            <p class="text-sm text-gray-500">Batch create time slots, services, or new staff accounts.</p>
        </button>
    </div>
</div>