<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.system.model.LoginUser"%>
<%@page import="java.util.*"%>
<%@page import="com.mycompany.system.db.ClinicDB"%>
<%@page import="com.mycompany.system.db.DepartmentDB"%>
<%@page import="com.mycompany.system.db.ClinicTimeSlotDB"%>
<%@page import="com.mycompany.system.bean.ClinicBean"%>
<%@page import="com.mycompany.system.bean.DepartmentBean"%>
<%@page import="com.mycompany.system.bean.ClinicTimeSlotBean"%>
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
<html>
<head>
    <meta charset="UTF-8">
    <title>Clinic & Service Config - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>/* 复用原有样式 */</style>
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100">
<div class="flex h-screen overflow-hidden">
    <aside class="w-80 glass bg-white shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
        <!-- 侧边栏内容，参考 dashboard.jsp 但去掉 appointments/queue -->
        ...
    </aside>
    <div class="flex-1 flex flex-col min-w-0">
        <header class="glass border-b px-8 py-4 flex justify-between items-center">
            <h2 class="text-2xl font-semibold">Clinic & Service Configuration</h2>
        </header>
        <div class="flex-1 overflow-auto p-4 md:p-8">
            <!-- 诊所列表 -->
            <div class="glass p-6 rounded-3xl mb-8">
                <div class="flex justify-between items-center mb-4">
                    <h3 class="text-xl font-bold">Clinic List</h3>
                    <button onclick="openClinicModal()" class="px-4 py-2 bg-indigo-600 text-white rounded-xl">+ Add Clinic</button>
                </div>
                <table class="w-full text-left">
                    <thead><tr><th>Name</th><th>Location</th><th>Status</th><th>Actions</th></tr></thead>
                    <tbody>
                        <c:forEach var="c" items="${clinics}">
                            <tr><td>${c.clinicName}</td><td>${c.location}</td><td>${c.status == 1 ? 'Active' : 'Disabled'}</td>
                            <td><button onclick="editClinic(${c.id})">Edit</button> <button onclick="deleteClinic(${c.id})">Delete</button></td></tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <!-- 服务项目（科室）列表 -->
            <div class="glass p-6 rounded-3xl mb-8">
                <div class="flex justify-between items-center mb-4">
                    <h3 class="text-xl font-bold">Medical Services (Departments)</h3>
                    <button onclick="openDeptModal()" class="px-4 py-2 bg-indigo-600 text-white rounded-xl">+ Add Service</button>
                </div>
                <table class="w-full text-left">
                    <thead><tr><th>Name</th><th>Code</th><th>Description</th><th>Actions</th></tr></thead>
                    <tbody>
                        <c:forEach var="d" items="${departments}">
                            <tr><td>${d.deptName}</td><td>${d.deptCode}</td><td>${d.description}</td>
                            <td><button onclick="editDept(${d.id})">Edit</button> <button onclick="deleteDept(${d.id})">Delete</button></td></tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <!-- 时段名额配置 -->
            <div class="glass p-6 rounded-3xl">
                <h3 class="text-xl font-bold mb-4">Time Slot Capacity</h3>
                <form id="slotForm" action="${pageContext.request.contextPath}/admin/clinic/saveSlot" method="post">
                    <div class="grid grid-cols-2 gap-4">
                        <select name="clinicId" required><option value="">Select Clinic</option><c:forEach var="c" items="${clinics}"><option value="${c.id}">${c.clinicName}</option></c:forEach></select>
                        <select name="period" required><option value="morning">Morning</option><option value="afternoon">Afternoon</option><option value="evening">Evening</option></select>
                        <input type="text" name="slotTime" placeholder="Time (e.g., 09:00)" required>
                        <input type="number" name="capacity" placeholder="Capacity" required>
                    </div>
                    <button type="submit" class="mt-4 px-6 py-2 bg-green-600 text-white rounded-xl">Add/Update Slot</button>
                </form>
                <hr class="my-6">
                <h4 class="font-bold mb-2">Existing Slots</h4>
                <table class="w-full text-left">
                    <thead><tr><th>Clinic</th><th>Period</th><th>Time</th><th>Capacity</th><th></th></tr></thead>
                    <tbody>
                        <c:forEach var="ts" items="${timeSlots}">
                            <tr><td>${ts.clinicId}</td><td>${ts.period}</td><td>${ts.slotTime}</td><td>${ts.capacity}</td>
                            <td><button onclick="deleteSlot(${ts.id})">Delete</button></td></tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<script>
    function openClinicModal() { Swal.fire({ title: 'Add Clinic', html: '<input id="name" placeholder="Name"><input id="location" placeholder="Location">', preConfirm: () => fetch('/admin/clinic/add', { method: 'POST', body: new URLSearchParams({ name: Swal.getPopup().querySelector('#name').value, location: ... }) }).then(() => location.reload()) }); }
</script>
</body>
</html>