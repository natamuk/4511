<%-- 
    Document   : queue-contents
    Created on : 2026年4月23日, 02:22:39
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class='glass rounded-3xl p-6'>
    <div class='flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6'>
        <h3 class='text-2xl font-semibold'>Live Queue</h3>
        <div class='flex items-center gap-3 w-full md:w-auto'>
            <span class='px-4 py-2 rounded-xl bg-blue-50 text-blue-700 text-sm font-medium hidden md:inline-block' id="eta-text">ETA: 0 mins</span>
            <button onclick='Swal.fire("Queue","Call function disabled","info")' class='flex-1 md:flex-none px-6 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-medium transition shadow-sm'>Call Next</button>
        </div>
    </div>
    <div class='space-y-3' id="queue-list">
        <div class="text-center py-12 text-gray-500"><i class="fa-solid fa-users-slash text-4xl mb-3"></i><p>Queue is empty.</p></div>
    </div>
</div>