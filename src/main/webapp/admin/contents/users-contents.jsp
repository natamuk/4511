<%-- 
    Document   : users-contents
    Created on : 2026年4月23日, 23:46:48
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="space-y-8">
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">Doctor Management</h3>
            <div class="flex items-center gap-3">
                <button onclick="addUser()" class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition">Add User</button>
                <span id="doc-count" class="text-sm font-medium px-3 py-2 bg-indigo-50 text-indigo-700 rounded-xl">Total: ${doctorUsers.length}</span>
            </div>
        </div>
        <div class="mb-6">
            <input type="text" id="docSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterDoctors()">
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left min-w-[900px]">
                <thead class="bg-gray-50 text-gray-600 border-b">
                    <tr><th class="py-4 px-4 rounded-tl-xl">Name</th><th class="py-4 px-4">Username</th><th class="py-4 px-4">Phone</th><th class="py-4 px-4">Email</th><th class="py-4 px-4">Title</th><th class="py-4 px-4">Status</th><th class="py-4 px-4 rounded-tr-xl">Action</th></tr>
                </thead>
                <tbody id="doc-tbody" class="divide-y"></tbody>
            </table>
        </div>
    </div>
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">Patient Management</h3>
            <span id="pat-count" class="text-sm font-medium px-3 py-1 bg-emerald-50 text-emerald-700 rounded-lg">Total: ${patientUsers.length}</span>
        </div>
        <div class="mb-6">
            <input type="text" id="patSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterPatients()">
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left min-w-[900px]">
                <thead class="bg-gray-50 text-gray-600 border-b">
                    <tr><th class="py-4 px-4 rounded-tl-xl">Name</th><th class="py-4 px-4">Username</th><th class="py-4 px-4">Phone</th><th class="py-4 px-4">Email</th><th class="py-4 px-4">Address</th><th class="py-4 px-4">Status</th><th class="py-4 px-4 rounded-tr-xl">Action</th></tr>
                </thead>
                <tbody id="pat-tbody" class="divide-y"></tbody>
            </table>
        </div>
    </div>
</div>