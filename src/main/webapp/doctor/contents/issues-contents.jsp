<%-- 
    Document   : issues-contents
    Created on : 2026年4月23日, 02:22:53
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class='glass rounded-3xl p-6'>
    <div class='flex justify-between items-center mb-6'>
        <h3 class='text-2xl font-semibold'>Reported Issues</h3>
        <button onclick='Swal.fire("Info","Report function disabled in demo","info")' class='px-4 py-2 bg-red-50 text-red-600 font-medium rounded-xl hover:bg-red-100 transition border border-red-200'>Report New</button>
    </div>
    <div class='space-y-3' id="issues-list">
        <p class="text-center py-10 text-gray-500">No issues reported.</p>
    </div>
</div>