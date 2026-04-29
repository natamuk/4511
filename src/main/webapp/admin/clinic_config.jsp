<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ page import="com.mycompany.system.db.ClinicDB" %>
<%@ page import="com.mycompany.system.db.DepartmentDB" %>
<%@ page import="com.mycompany.system.db.ClinicTimeSlotDB" %>
<%@ page import="com.mycompany.system.bean.ClinicBean" %>
<%@ page import="com.mycompany.system.bean.DepartmentBean" %>
<%@ page import="com.mycompany.system.bean.ClinicTimeSlotBean" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="/WEB-INF/tlds/current-date" prefix="today" %>
<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    List<ClinicBean> clinics = ClinicDB.getAll();
    List<DepartmentBean> departments = DepartmentDB.getAll();
    List<ClinicTimeSlotBean> timeSlots = ClinicTimeSlotDB.getAll();
    request.setAttribute("clinics", clinics);
    request.setAttribute("departments", departments);
    request.setAttribute("timeSlots", timeSlots);
%>
<!DOCTYPE html>
<html lang="zh">
    <head>
        <meta charset="UTF-8">
        <title>Clinic & Service Config - CCHC Admin</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
            *{
                box-sizing:border-box
            }
            body{
                font-family:'Noto Sans TC',sans-serif;
                background:linear-gradient(135deg,#f0f9ff 0%,#e0e7ff 100%)
            }
            .glass{
                background:rgba(255,255,255,0.95);
                border:1px solid rgba(255,255,255,0.6);
                box-shadow:0 4px 6px -1px rgba(0,0,0,0.05);
                backdrop-filter:blur(4px)
            }
            .nav-item{
                transition:all .2s;
                display:flex;
                align-items:center;
                gap:0.75rem;
                padding:0.75rem 1.25rem;
                border-radius:1rem
            }
            .nav-item:hover{
                transform:translateX(8px);
                background:rgba(99,102,241,0.1)
            }
            .nav-item.active{
                background:rgba(99,102,241,0.14);
                color:#4f46e5;
                font-weight:700
            }
        </style>
    </head>
    <body class="min-h-screen">
        <div class="flex h-screen overflow-hidden">
            <aside class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
                <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white"><div class="flex items-center gap-3"><i class="fa-solid fa-user-shield text-4xl"></i><div><h1 class="text-2xl font-bold">CCHC</h1><p class="text-sm opacity-90">Admin Console</p></div></div></div>
                <div class="p-6 flex-1 flex flex-col overflow-y-auto">
                    <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8"><img src="https://picsum.photos/200/200?random=99" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover"><div><p class="font-semibold"><%= loginUser.getRealName()%></p><p class="text-indigo-600 text-sm">Full Access</p></div></div>
                    <nav class="space-y-1">
                        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item "><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                        <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item"><i class="fa-solid fa-users w-5"></i><span>User Management</span></a>
                        <a href="${pageContext.request.contextPath}/admin/quota.jsp" class="nav-item"><i class="fa-solid fa-server w-5"></i><span>Services & Quota</span></a>
                        <a href="${pageContext.request.contextPath}/admin/clinic_config.jsp" class="nav-item"><i class="fa-solid fa-building"></i><span>Clinic & Services</span></a>
                        <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"><i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span></a>
                        <a href="${pageContext.request.contextPath}/admin/abnormal_records.jsp" class="nav-item"><i class="fa-solid fa-exclamation-triangle"></i><span>Abnormal Records</span></a>
                        <a href="${pageContext.request.contextPath}/admin/logs.jsp" class="nav-item"><i class="fa-solid fa-clipboard-list w-5"></i><span>Audit Logs</span></a>
                        <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                        <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item"><i class="fa-solid fa-sliders w-5"></i><span>Settings</span></a>
                        <a href="${pageContext.request.contextPath}/admin/csv.jsp" class="nav-item"><i class="fa-solid fa-file-csv w-5"></i><span>CSV Import/Export</span></a>
                        <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                    </nav>
                    <div class="mt-auto pt-6 border-t border-white/40"><a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a></div>
                </div>
            </aside>

            <div class="flex-1 flex flex-col min-w-0">
                <header class="glass border-b px-8 py-4 flex justify-between items-center">
                    <h2 class="text-2xl font-semibold">Clinic & Service Configuration</h2>
                    <today:today/>
                </header>
                <div class="flex-1 overflow-auto p-4 md:p-8">
                    <!-- Clinics Section -->
                    <div class="glass p-6 rounded-3xl mb-8">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="text-xl font-bold">Clinic List</h3>
                            <button onclick="openClinicModal()" class="px-4 py-2 bg-indigo-600 text-white rounded-xl">+ Add Clinic</button>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left">
                                <thead class="bg-gray-50"><tr><th class="p-3">Name</th><th class="p-3">Location</th><th class="p-3">Status</th><th class="p-3">Actions</th></tr></thead>
                                <tbody>
                                    <c:forEach var="c" items="${clinics}">
                                        <tr class="border-b"><td class="p-3">${c.clinicName}</td><td class="p-3">${c.location}</td><td class="p-3">${c.status == 1 ? 'Active' : 'Disabled'}</td>
                                            <td class="p-3"><button onclick="editClinic(${c.id}, '${c.clinicName}', '${c.location}', ${c.status})" class="text-indigo-600 mr-2">Edit</button>
                                                <button onclick="deleteClinic(${c.id})" class="text-red-600">Delete</button></td></tr>
                                            </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Departments (Services) Section -->
                    <div class="glass p-6 rounded-3xl mb-8">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="text-xl font-bold">Medical Services (Departments)</h3>
                            <button onclick="openDeptModal()" class="px-4 py-2 bg-indigo-600 text-white rounded-xl">+ Add Service</button>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left">
                                <thead class="bg-gray-50"><tr><th class="p-3">Name</th><th class="p-3">Code</th><th class="p-3">Description</th><th class="p-3">Actions</th></tr></thead>
                                <tbody>
                                    <c:forEach var="d" items="${departments}">
                                        <tr class="border-b"><td class="p-3">${d.deptName}</td><td class="p-3">${d.deptCode}</td><td class="p-3">${d.description}</td>
                                            <td class="p-3"><button onclick="editDept(${d.id}, '${d.deptName}', '${d.deptCode}', '${d.description}')" class="text-indigo-600 mr-2">Edit</button>
                                                <button onclick="deleteDept(${d.id})" class="text-red-600">Delete</button></td></tr>
                                            </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Time Slot Capacity Section -->
                    <div class="glass p-6 rounded-3xl">
                        <h3 class="text-xl font-bold mb-4">Time Slot Capacity Settings</h3>
                        <form id="slotForm" action="${pageContext.request.contextPath}/admin/clinic/saveSlot" method="post" class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
                            <select name="clinicId" required class="px-3 py-2 border rounded"><option value="">Select Clinic</option><c:forEach var="c" items="${clinics}"><option value="${c.id}">${c.clinicName}</option></c:forEach></select>
                                <select name="period" required class="px-3 py-2 border rounded"><option value="morning">Morning</option><option value="afternoon">Afternoon</option><option value="evening">Evening</option></select>
                                <input type="text" name="slotTime" placeholder="Time (e.g., 09:00)" required class="px-3 py-2 border rounded">
                                <input type="number" name="capacity" placeholder="Capacity" required class="px-3 py-2 border rounded">
                                <button type="submit" class="md:col-span-4 px-6 py-2 bg-green-600 text-white rounded-xl">Add / Update Slot</button>
                            </form>
                            <hr class="my-6">
                            <h4 class="font-bold mb-2">Existing Slots</h4>
                            <div class="overflow-x-auto">
                                <table class="w-full text-left">
                                    <thead class="bg-gray-50"><tr><th class="p-3">Clinic</th><th class="p-3">Period</th><th class="p-3">Time</th><th class="p-3">Capacity</th><th class="p-3">Actions</th></tr></thead>
                                    <tbody>
                                    <c:forEach var="ts" items="${timeSlots}">
                                        <tr class="border-b"><td class="p-3">${ts.clinicId}</td><td class="p-3">${ts.period}</td><td class="p-3">${ts.slotTime}</td><td class="p-3">${ts.capacity}</td>
                                            <td class="p-3"><button onclick="deleteSlot(${ts.id})" class="text-red-600">Delete</button></td></tr>
                                        </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            function openClinicModal() {
                Swal.fire({
                    title: 'Add Clinic',
                    html: '<input id="name" class="swal2-input" placeholder="Clinic Name"><input id="location" class="swal2-input" placeholder="Location">',
                    preConfirm: () => {
                        let name = Swal.getPopup().querySelector('#name').value;
                        let location = Swal.getPopup().querySelector('#location').value;
                        if (!name) {
                            Swal.showValidationMessage('Name required');
                            return false;
                        }
                        return fetch('${pageContext.request.contextPath}/admin/clinic/add', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: 'name=' + encodeURIComponent(name) + '&location=' + encodeURIComponent(location)
                        }).then(res => res.json()).then(data => {
                            if (data.success)
                                location.reload();
                            else
                                Swal.showValidationMessage(data.message);
                        });
                    }
                });
            }
            function editClinic(id, name, location, status) {
                Swal.fire({
                    title: 'Edit Clinic',
                    html: '<input id="name" class="swal2-input" value="' + name + '"><input id="location" class="swal2-input" value="' + location + '"><select id="status" class="swal2-select"><option value="1">Active</option><option value="0">Disabled</option></select>',
                    didOpen: () => {
                        document.getElementById('status').value = status;
                    },
                    preConfirm: () => {
                        let newName = document.getElementById('name').value;
                        let newLoc = document.getElementById('location').value;
                        let newStatus = document.getElementById('status').value;
                        return fetch('${pageContext.request.contextPath}/admin/clinic/update', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: 'id=' + id + '&name=' + encodeURIComponent(newName) + '&location=' + encodeURIComponent(newLoc) + '&status=' + newStatus
                        }).then(res => res.json()).then(data => {
                            if (data.success)
                                location.reload();
                            else
                                Swal.showValidationMessage(data.message);
                        });
                    }
                });
            }
            function deleteClinic(id) {
                Swal.fire({title: 'Confirm delete?', icon: 'warning', showCancelButton: true, preConfirm: () => {
                        fetch('${pageContext.request.contextPath}/admin/clinic/delete', {method: 'POST', body: 'id=' + id, headers: {'Content-Type': 'application/x-www-form-urlencoded'}})
                                .then(res => res.json()).then(data => {
                            if (data.success)
                                location.reload();
                            else
                                Swal.fire('Error', data.message, 'error');
                        });
                    }});
            }
            function openDeptModal() {
                Swal.fire({
                    title: 'Add Medical Service',
                    html: '<input id="deptName" class="swal2-input" placeholder="Department Name">' +
                            '<input id="deptCode" class="swal2-input" placeholder="Department Code">' +
                            '<textarea id="deptDesc" class="swal2-textarea" placeholder="Description"></textarea>',
                    preConfirm: () => {
                        let name = document.getElementById('deptName').value;
                        let code = document.getElementById('deptCode').value;
                        let desc = document.getElementById('deptDesc').value;
                        if (!name) {
                            Swal.showValidationMessage('Name required');
                            return false;
                        }
                        return fetch('${pageContext.request.contextPath}/admin/department/add', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: 'name=' + encodeURIComponent(name) + '&code=' + encodeURIComponent(code) + '&desc=' + encodeURIComponent(desc)
                        }).then(res => res.json()).then(data => {
                            if (data.success)
                                location.reload();
                            else
                                Swal.showValidationMessage(data.message);
                        });
                    }
                });
            }

            function editDept(id, name, code, desc) {
                Swal.fire({
                    title: 'Edit Service',
                    html: '<input id="deptName" class="swal2-input" value="' + escapeHtml(name) + '">' +
                            '<input id="deptCode" class="swal2-input" value="' + escapeHtml(code) + '">' +
                            '<textarea id="deptDesc" class="swal2-textarea">' + escapeHtml(desc) + '</textarea>',
                    preConfirm: () => {
                        let newName = document.getElementById('deptName').value;
                        let newCode = document.getElementById('deptCode').value;
                        let newDesc = document.getElementById('deptDesc').value;
                        return fetch('${pageContext.request.contextPath}/admin/department/update', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: 'id=' + id + '&name=' + encodeURIComponent(newName) + '&code=' + encodeURIComponent(newCode) + '&desc=' + encodeURIComponent(newDesc)
                        }).then(res => res.json()).then(data => {
                            if (data.success)
                                location.reload();
                            else
                                Swal.showValidationMessage(data.message);
                        });
                    }
                });
            }

            function deleteDept(id) {
                Swal.fire({title: 'Confirm delete?', icon: 'warning', showCancelButton: true, preConfirm: () => {
                        fetch('${pageContext.request.contextPath}/admin/department/delete', {method: 'POST', body: 'id=' + id, headers: {'Content-Type': 'application/x-www-form-urlencoded'}})
                                .then(res => res.json()).then(data => {
                            if (data.success)
                                location.reload();
                            else
                                Swal.fire('Error', data.message, 'error');
                        });
                    }});
            }

            function escapeHtml(str) {
                if (!str)
                    return '';
                return str.replace(/[&<>]/g, function (m) {
                    if (m === '&')
                        return '&amp;';
                    if (m === '<')
                        return '&lt;';
                    if (m === '>')
                        return '&gt;';
                    return m;
                });
            }
        </script>
    </body>
</html>