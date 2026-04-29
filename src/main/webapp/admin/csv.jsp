<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@taglib uri="/WEB-INF/tlds/current-date" prefix="today" %>
<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8"><title>CSV Import/Export - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        *{box-sizing:border-box}body{font-family:'Noto Sans TC',sans-serif;background:linear-gradient(135deg,#f0f9ff 0%,#e0e7ff 100%)}
        .glass{background:rgba(255,255,255,0.95);border:1px solid rgba(255,255,255,0.6);box-shadow:0 4px 6px -1px rgba(0,0,0,0.05);backdrop-filter:blur(4px)}
        .nav-item{transition:all .2s;display:flex;align-items:center;gap:0.75rem;padding:0.75rem 1.25rem;border-radius:1rem}
        .nav-item:hover{transform:translateX(8px);background:rgba(99,102,241,0.1)}
        .nav-item.active{background:rgba(99,102,241,0.14);color:#4f46e5;font-weight:700}
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden">
    <aside class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
        <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white"><div class="flex items-center gap-3"><i class="fa-solid fa-user-shield text-4xl"></i><div><h1 class="text-2xl font-bold">CCHC</h1><p class="text-sm opacity-90">Admin Console</p></div></div></div>
        <div class="p-6 flex-1 flex flex-col overflow-y-auto">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8"><img src="https://picsum.photos/200/200?random=99" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover"><div><p class="font-semibold"><%= loginUser.getRealName() %></p><p class="text-indigo-600 text-sm">Full Access</p></div></div>
            <nav class="space-y-1">
                <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item"><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item"><i class="fa-solid fa-users w-5"></i><span>User Management</span></a>
                <a href="${pageContext.request.contextPath}/admin/quota.jsp" class="nav-item"><i class="fa-solid fa-server w-5"></i><span>Services & Quota</span></a>
                <a href="${pageContext.request.contextPath}/admin/clinic_config.jsp" class="nav-item"><i class="fa-solid fa-building"></i><span>Clinic & Services</span></a>
                <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"><i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span></a>
                <a href="${pageContext.request.contextPath}/admin/abnormal_records.jsp" class="nav-item"><i class="fa-solid fa-exclamation-triangle"></i><span>Abnormal Records</span></a>
                <a href="${pageContext.request.contextPath}/admin/logs.jsp" class="nav-item"><i class="fa-solid fa-clipboard-list w-5"></i><span>Audit Logs</span></a>
                <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item"><i class="fa-solid fa-sliders w-5"></i><span>Settings</span></a>
                <a href="${pageContext.request.contextPath}/admin/csv.jsp" class="nav-item active"><i class="fa-solid fa-file-csv w-5"></i><span>CSV Import/Export</span></a>
                <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
            </nav>
            <div class="mt-auto pt-6 border-t border-white/40"><a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a></div>
        </div>
    </aside>
    <div class="flex-1 flex flex-col min-w-0">
        <header class="glass border-b px-8 py-4 flex justify-between items-center"><h2 class="text-2xl font-semibold">CSV Import & Export</h2><today:today/></header>
        <div class="flex-1 overflow-auto p-4 md:p-8">
            <div class="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-8">
                <div class="glass p-8 rounded-3xl">
                    <h3 class="text-xl font-bold mb-4"><i class="fa-solid fa-file-import text-indigo-600"></i> Import CSV</h3>
                    <form action="${pageContext.request.contextPath}/admin/import/csv" method="post" enctype="multipart/form-data" class="space-y-4">
                        <select name="entityType" required class="w-full p-2 border rounded">
                            <option value="department">Services (Departments)</option>
                            <option value="timeslot">Time Slots</option>
                            <option value="doctor">Doctors</option>
                            <option value="patient">Patients</option>
                        </select>
                        <input type="file" name="csvFile" accept=".csv" required class="w-full p-2 border rounded">
                        <button type="submit" class="w-full py-2 bg-indigo-600 text-white rounded-xl">Upload & Import</button>
                    </form>
                    <div class="mt-4 text-xs text-gray-500">CSV format: first row headers, comma separated. Refer to documentation.</div>
                </div>
                <div class="glass p-8 rounded-3xl">
                    <h3 class="text-xl font-bold mb-4"><i class="fa-solid fa-file-export text-emerald-600"></i> Export Data</h3>
                    <div class="space-y-3">
                        <a href="${pageContext.request.contextPath}/admin/export/csv?type=appointments" class="block w-full text-center py-2 bg-gray-100 hover:bg-gray-200 rounded">Appointments</a>
                        <a href="${pageContext.request.contextPath}/admin/export/csv?type=users" class="block w-full text-center py-2 bg-gray-100 hover:bg-gray-200 rounded">All Users</a>
                        <a href="${pageContext.request.contextPath}/admin/export/csv?type=clinics" class="block w-full text-center py-2 bg-gray-100 hover:bg-gray-200 rounded">Clinics & Services</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>