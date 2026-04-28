<%-- csv.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
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
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dashboard - CCHC Admin</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
            * {
                box-sizing: border-box;
            }
            body {
                font-family: 'Noto Sans TC', sans-serif;
                background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%);
            }
            .glass {
                background: rgba(255,255,255,0.95);
                border:1px solid rgba(255,255,255,0.6);
                box-shadow:0 4px 6px -1px rgba(0,0,0,0.05);
                backdrop-filter: blur(4px);
            }
            .nav-item {
                transition: all .2s;
                display: flex;
                align-items: center;
                gap: 0.75rem;
                padding: 0.75rem 1.25rem;
                border-radius: 1rem;
            }
            .nav-item:hover {
                transform: translateX(8px);
                background: rgba(99,102,241,0.1);
            }
            .nav-item.active {
                background: rgba(99,102,241,0.14);
                color: #4f46e5;
                font-weight: 700;
            }
            .badge {
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
                padding: 0.35rem 0.7rem;
                border-radius: 999px;
                font-size: 0.75rem;
                font-weight: 700;
            }
            .badge-success {
                background: #dcfce7;
                color: #166534;
            }
            .badge-danger {
                background: #fee2e2;
                color: #b91c1c;
            }
            .badge-info {
                background: #dbeafe;
                color: #1d4ed8;
            }
        </style>
    </head>
    <body>
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
                <div class="space-y-1">
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item"><i class="fa-solid fa-chart-pie"></i> Dashboard</a>
                    <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item"><i class="fa-solid fa-users"></i> User Management</a>
                    <a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="nav-item active"><i class="fa-solid fa-calendar-check"></i> Appointments</a>
                    <a href="${pageContext.request.contextPath}/admin/queue.jsp" class="nav-item"><i class="fa-solid fa-list-ol"></i> Queue</a>
                    <a href="${pageContext.request.contextPath}/admin/quota.jsp" class="nav-item"><i class="fa-solid fa-server"></i> Services & Quota</a>
                    <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"><i class="fa-solid fa-chart-bar"></i> Reports</a>
                    <a href="${pageContext.request.contextPath}/admin/logs.jsp" class="nav-item"><i class="fa-solid fa-clipboard-list"></i> Audit Logs</a>
                    <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item"><i class="fa-solid fa-bell"></i> Notifications</a>
                    <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item"><i class="fa-solid fa-sliders"></i> Settings</a>
                    <a href="${pageContext.request.contextPath}/admin/csv.jsp" class="nav-item"><i class="fa-solid fa-file-csv"></i> CSV Import/Export</a>
                    <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"><i class="fa-solid fa-user-gear"></i> Profile</a>
                </div>
                <div class="logout-btn"><a href="${pageContext.request.contextPath}/logout" class="nav-item justify-center text-red-600 hover:bg-red-50"><i class="fa-solid fa-right-from-bracket"></i> Logout</a></div>
            </aside>
    <div class="main">
        <header class="header"><h2 class="text-2xl font-semibold">Data Import & Export</h2><span id="current-date" class="text-sm text-gray-500"></span></header>
        <div class="content">
            <div class="grid-card">
                <div class="card" onclick="Swal.fire('Info','Export functionality can be connected to a backend API.','info')">
                    <div class="w-20 h-20 mx-auto bg-emerald-50 rounded-full flex items-center justify-center mb-4"><i class="fa-solid fa-file-export text-emerald-600 text-3xl"></i></div>
                    <p class="text-xl font-bold">Export Data</p><p class="text-sm text-gray-500">Download appointment records and user data.</p>
                </div>
                <div class="card" onclick="Swal.fire('Info','Import functionality can be connected to a backend API.','info')">
                    <div class="w-20 h-20 mx-auto bg-indigo-50 rounded-full flex items-center justify-center mb-4"><i class="fa-solid fa-file-import text-indigo-600 text-3xl"></i></div>
                    <p class="text-xl font-bold">Import CSV</p><p class="text-sm text-gray-500">Batch create time slots, services, or new accounts.</p>
                </div>
            </div>
        </div>
    </div>
</div>
<script>document.getElementById('current-date').innerText = new Date().toLocaleDateString('zh-CN');</script>
</body>
</html>