<%-- dashboard.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ page import="com.mycompany.system.dao.AdminDashboardDao" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="/WEB-INF/tlds/current-date" prefix="today" %>
<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    AdminDashboardDao dao = new AdminDashboardDao();
    List<Map<String, Object>> appointments = dao.getAppointments();
    List<Map<String, Object>> queueList = dao.getQueueList();
    List<Map<String, Object>> quota = dao.getQuota();
    request.setAttribute("appointments", appointments);
    request.setAttribute("queueList", queueList);
    request.setAttribute("quota", quota);

    long noShowCancelCount = 0;
    if (appointments != null) {
        for (Map<String, Object> item : appointments) {
            String status = item.get("status") == null ? "" : item.get("status").toString();
            if ("no_show".equals(status) || "cancelled".equals(status)) {
                noShowCancelCount++;
            }
        }
    }
    request.setAttribute("noShowCancelCount", noShowCancelCount);

    int avgLoadPercent = 0;
    if (quota != null && !quota.isEmpty()) {
        double totalRate = 0;
        for (Map<String, Object> item : quota) {
            double booked = item.get("booked") == null ? 0 : Double.parseDouble(item.get("booked").toString());
            double capacity = item.get("capacity") == null ? 1 : Double.parseDouble(item.get("capacity").toString());
            if (capacity < 1) capacity = 1;
            totalRate += (booked / capacity);
        }
        avgLoadPercent = (int) Math.round((totalRate / quota.size()) * 100);
    }
    request.setAttribute("avgLoadPercent", avgLoadPercent);
%>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
        body { font-family: 'Noto Sans TC', sans-serif; background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%); }
        .glass { background: rgba(255,255,255,0.95); border:1px solid rgba(255,255,255,0.6); box-shadow:0 4px 6px -1px rgba(0,0,0,0.05); backdrop-filter: blur(4px); }
        .nav-item { transition: all .2s; display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1.25rem; border-radius: 1rem; }
        .nav-item:hover { transform: translateX(8px); background: rgba(99,102,241,0.1); }
        .nav-item.active { background: rgba(99,102,241,0.14); color: #4f46e5; font-weight: 700; }
        .badge { display: inline-flex; align-items: center; gap: 0.35rem; padding: 0.35rem 0.7rem; border-radius: 999px; font-size: 0.75rem; font-weight: 700; }
        .badge-success { background: #dcfce7; color: #166534; }
        .badge-danger { background: #fee2e2; color: #b91c1c; }
        .badge-info { background: #dbeafe; color: #1d4ed8; }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden">
    <aside class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
        <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white">
            <div class="flex items-center gap-3">
                <i class="fa-solid fa-user-shield text-4xl"></i>
                <div>
                    <h1 class="text-2xl font-bold">CCHC</h1>
                    <p class="text-sm opacity-90">Admin Console</p>
                </div>
            </div>
        </div>
        <div class="p-6 flex-1 flex flex-col overflow-y-auto">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img src="https://picsum.photos/200/200?random=99" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover">
                <div>
                    <p class="font-semibold"><%= loginUser.getRealName() %></p>
                    <p class="text-indigo-600 text-sm">Full Access</p>
                </div>
            </div>
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
            <div class="mt-auto pt-6 border-t border-white/40">
                <a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition">
                    <i class="fa-solid fa-right-from-bracket"></i> <span>Logout</span>
                </a>
            </div>
        </div>
    </aside>

    <div class="flex-1 flex flex-col min-w-0">
        <header class="glass border-b px-8 py-4 flex justify-between items-center">
            <h2 class="text-2xl font-semibold">Dashboard</h2>
            <div class="flex items-center gap-3">
                <today:today />
            </div>
        </header>
        <div class="flex-1 overflow-auto p-4 md:p-8">
            <!-- 原 dashboard-contents.jsp 内容开始 -->
            <div class="max-w-7xl mx-auto space-y-8">
                <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                    <div><h1 class="text-4xl font-bold text-gray-800 mb-2">Admin Console</h1><p class="text-gray-500">Monitor clinic operations, appointment trends, and system events</p></div>
                    <div class="flex gap-3 flex-wrap items-center">
                        <a href="${pageContext.request.contextPath}/admin/users.jsp" class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition">Add User</a>
                        <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="px-4 py-2 rounded-xl bg-white border hover:bg-gray-50 transition text-gray-700 font-medium shadow-sm">View Reports</a>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
                    <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Total Appointments</div><div class="text-4xl font-bold text-indigo-600 mt-2">${appointments.size()}</div><div class="text-xs text-gray-400 mt-2">All appointment records</div></div>
                    <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Queue Waiting</div><div class="text-4xl font-bold text-emerald-600 mt-2">${queueList.size()}</div><div class="text-xs text-gray-400 mt-2">Same-day queue patients</div></div>
                    <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">No-show / Cancelled</div><div class="text-4xl font-bold text-amber-600 mt-2">${noShowCancelCount}</div><div class="text-xs text-gray-400 mt-2">Risk status total</div></div>
                    <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Average Service Load</div><div class="text-4xl font-bold text-violet-600 mt-2" id="avg-load-value">${avgLoadPercent}%</div><div class="text-xs text-gray-400 mt-2">Average utilization rate</div></div>
                </div>
                <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
                    <div class="glass p-6 rounded-3xl"><div class="flex items-center justify-between mb-4"><h3 class="text-xl font-bold">Weekly Booking Trend</h3><span class="text-sm text-gray-500 border border-gray-200 px-3 py-1 rounded-lg bg-gray-50">Last 7 days</span></div><div class="h-64 flex items-center justify-center text-gray-400"><canvas id="bookingChart"></canvas></div></div>
                    <div class="glass p-6 rounded-3xl"><div class="flex items-center justify-between mb-4"><h3 class="text-xl font-bold">Service Utilization</h3><span class="text-sm text-gray-500 border border-gray-200 px-3 py-1 rounded-lg bg-gray-50">Overall distribution</span></div><div class="h-64 flex items-center justify-center text-gray-400"><canvas id="serviceChart"></canvas></div></div>
                </div>
            </div>
            <script>
                (function() {
                    const ctx1 = document.getElementById('bookingChart')?.getContext('2d');
                    const ctx2 = document.getElementById('serviceChart')?.getContext('2d');
                    if (ctx1) { new Chart(ctx1, { type: 'line', data: { labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'], datasets: [{ label: 'Bookings', data: [12,19,15,17,24,22,18], borderColor: '#4f46e5' }] } }); }
                    if (ctx2) { new Chart(ctx2, { type: 'doughnut', data: { labels: ['Internal Med','Surgery','Pediatrics','Others'], datasets: [{ data: [40,25,20,15], backgroundColor: ['#4f46e5','#10b981','#f59e0b','#ef4444'] }] } }); }
                })();
            </script>
        </div>
    </div>
</div>
</body>
</html>