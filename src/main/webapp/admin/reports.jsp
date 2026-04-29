<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ page import="com.mycompany.system.dao.ReportDAO" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="/WEB-INF/tlds/current-date" prefix="today" %>
<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    ReportDAO reportDAO = new ReportDAO();
    List<Map<String, Object>> clinicUsage = reportDAO.getClinicUsage();
    List<Map<String, Object>> deptStats = reportDAO.getDepartmentStats();
    List<Map<String, Object>> monthlyTrend = reportDAO.getMonthlyTrend();
    int noShowCount = reportDAO.getNoShowCount();
    int cancellationCount = reportDAO.getCancellationCount();
    request.setAttribute("clinicUsage", clinicUsage);
    request.setAttribute("deptStats", deptStats);
    request.setAttribute("monthlyTrend", monthlyTrend);
    request.setAttribute("noShowCount", noShowCount);
    request.setAttribute("cancellationCount", cancellationCount);
%>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8"><title>Reports - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item "><i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span></a>
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
        <header class="glass border-b px-8 py-4 flex justify-between items-center"><h2 class="text-2xl font-semibold">Analytics Reports</h2><today:today/></header>
        <div class="flex-1 overflow-auto p-4 md:p-8">
            <div class="space-y-8">
                <div class="glass p-6 rounded-3xl">
                    <h3 class="text-xl font-bold mb-4">Clinic Utilization</h3>
                    <table class="w-full text-left"><thead class="bg-gray-50"><tr><th class="p-3">Clinic</th><th class="p-3">Used Slots</th><th class="p-3">Total Capacity</th><th class="p-3">Utilization Rate</th></tr></thead>
                    <tbody><c:forEach var="cu" items="${clinicUsage}"><tr><td class="p-3">${cu.clinic_name}</td><td class="p-3">${cu.used_slots}</td><td class="p-3">${cu.total_capacity}</td><td class="p-3">${cu.rate}%</c:forEach></tbody></table>
                </div>
                <div class="glass p-6 rounded-3xl">
                    <h3 class="text-xl font-bold mb-4">Service Department Statistics</h3>
                    <canvas id="deptChart" class="h-64"></canvas>
                </div>
                <div class="glass p-6 rounded-3xl">
                    <h3 class="text-xl font-bold mb-4">Monthly Booking Trend</h3>
                    <canvas id="monthlyChart" class="h-64"></canvas>
                </div>
                <div class="glass p-6 rounded-3xl">
                    <h3 class="text-xl font-bold mb-4">No-show & Cancellation Summary</h3>
                    <div class="grid grid-cols-2 gap-4 text-center"><div class="bg-red-50 p-4 rounded"><div class="text-3xl font-bold text-red-600">${noShowCount}</div><div>No-show</div></div>
                    <div class="bg-yellow-50 p-4 rounded"><div class="text-3xl font-bold text-yellow-700">${cancellationCount}</div><div>Cancellations</div></div></div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    const deptLabels = [], deptData = [];
    <c:forEach var="d" items="${deptStats}">deptLabels.push("${d.dept_name}"); deptData.push(${d.booking_count});</c:forEach>
    const monthlyLabels = [], monthlyData = [];
    <c:forEach var="m" items="${monthlyTrend}">monthlyLabels.push("${m.month}"); monthlyData.push(${m.total});</c:forEach>
    new Chart(document.getElementById('deptChart'), { type: 'bar', data: { labels: deptLabels, datasets: [{ label: 'Bookings', data: deptData, backgroundColor: '#4f46e5' }] } });
    new Chart(document.getElementById('monthlyChart'), { type: 'line', data: { labels: monthlyLabels, datasets: [{ label: 'Appointments', data: monthlyData, borderColor: '#f59e0b' }] } });
</script>
</body>
</html>