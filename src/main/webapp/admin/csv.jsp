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
    <title>CSV Import & Export - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
        body {
            font-family: 'Noto Sans TC', sans-serif;
            background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%);
            margin: 0;
            height: 100vh;
            overflow: hidden;
        }
        .app {
            display: flex;
            height: 100vh;
            overflow: hidden;
        }
        .sidebar {
            width: 320px;
            background: white;
            border-right: 1px solid #e5e7eb;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            box-shadow: 2px 0 10px rgba(0,0,0,0.05);
        }
        .main {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .header {
            background: white;
            border-bottom: 1px solid #e5e7eb;
            padding: 1.5rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .content {
            flex: 1;
            overflow-y: auto;
            padding: 2rem;
        }
        .nav-item {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1.25rem;
            border-radius: 1rem;
            color: #374151;
            text-decoration: none;
            transition: all 0.2s;
        }
        .nav-item:hover {
            background: #f1f5f9;
            transform: translateX(8px);
        }
        .nav-item.active {
            background: #e0e7ff;
            color: #4f46e5;
            font-weight: 700;
        }
        .card {
            background: white;
            border-radius: 1rem;
            padding: 2rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
        }
        .card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 25px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="app">

       <aside class="w-80 glass bg-white shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
                <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white"><div class="flex items-center gap-3"><i class="fa-solid fa-user-shield text-4xl"></i><div><h1 class="text-2xl font-bold">CCHC</h1><p class="text-sm opacity-90">Admin Console</p></div></div></div>
                <div class="p-6 flex-1 flex flex-col overflow-y-auto">
                    <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8"><img src="https://picsum.photos/200/200?random=99" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover"><div><p class="font-semibold"><%= loginUser.getRealName()%></p><p class="text-indigo-600 text-sm">Full Access</p></div></div>
                    <nav class="space-y-1">
                        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item"><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                        <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item"><i class="fa-solid fa-users w-5"></i><span>User Management</span></a>
                        <a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="nav-item"><i class="fa-solid fa-calendar-check w-5"></i><span>Appointments</span></a>
                        <a href="${pageContext.request.contextPath}/admin/queue.jsp" class="nav-item"><i class="fa-solid fa-list-ol w-5"></i><span>Queue</span></a>
                        <a href="${pageContext.request.contextPath}/admin/quota.jsp" class="nav-item"><i class="fa-solid fa-server w-5"></i><span>Services & Quota</span></a>
                        <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"><i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span></a>
                        <a href="${pageContext.request.contextPath}/admin/logs.jsp" class="nav-item"><i class="fa-solid fa-clipboard-list w-5"></i><span>Audit Logs</span></a>
                        <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                        <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item"><i class="fa-solid fa-sliders w-5"></i><span>Settings</span></a>
                        <a href="${pageContext.request.contextPath}/admin/csv.jsp" class="nav-item active"><i class="fa-solid fa-file-csv w-5"></i><span>CSV Import/Export</span></a>
                        <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                    </nav>
                    <div class="mt-auto pt-6 border-t border-white/40"><a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a></div>
                </div>
            </aside>


        <div class="main">
            <header class="header">
                <h2 class="text-2xl font-semibold">Data Import & Export</h2>
                <span id="current-date" class="text-sm text-gray-500"></span>
            </header>

            <div class="content">
                <div class="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-8">
                    <div class="card p-10 text-center hover:shadow-xl transition-all cursor-pointer"
                         onclick="Swal.fire('Info', 'Export functionality can be connected to backend.', 'info')">
                        <div class="w-24 h-24 mx-auto bg-emerald-100 rounded-3xl flex items-center justify-center mb-6">
                            <i class="fa-solid fa-file-export text-emerald-600 text-5xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-2">Export Data</h3>
                        <p class="text-gray-600">Download appointments, users, queue records, etc.</p>
                    </div>

                    <div class="card p-10 text-center hover:shadow-xl transition-all cursor-pointer"
                         onclick="Swal.fire('Info', 'Import functionality can be connected to backend.', 'info')">
                        <div class="w-24 h-24 mx-auto bg-indigo-100 rounded-3xl flex items-center justify-center mb-6">
                            <i class="fa-solid fa-file-import text-indigo-600 text-5xl"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-2">Import CSV</h3>
                        <p class="text-gray-600">Batch upload doctors, patients, time slots, etc.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('current-date').innerText = new Date().toLocaleDateString('zh-CN', {
            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
        });
    </script>
</body>
</html>