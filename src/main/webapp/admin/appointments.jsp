<%-- appointments.jsp --%>
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
    request.setAttribute("appointments", appointments);
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
            <aside class="w-80  bg-white glass shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
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
                            <p class="font-semibold"><%= loginUser.getRealName()%></p>
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
                <header class="header">
                    <h2 class="text-2xl font-semibold">Appointments Management</h2>
                    <today:today/>
                </header>

                <div class="content">
                    <div class="bg-white rounded-3xl shadow-sm p-8">
                        <h3 class="text-xl font-semibold mb-6">Appointment Overview</h3>
                        <div class="overflow-x-auto">
                            <table class="w-full">
                                <thead>
                                    <tr class="bg-gray-50">
                                        <th class="py-4 px-6 text-left">Date & Time</th>
                                        <th class="py-4 px-6 text-left">Ticket No.</th>
                                        <th class="py-4 px-6 text-left">Patient Name</th>
                                        <th class="py-4 px-6 text-left">Doctor</th>
                                        <th class="py-4 px-6 text-left">Department</th>
                                        <th class="py-4 px-6 text-left">Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:if test="${empty appointments}">
                                        <tr>
                                            <td colspan="6" class="text-center py-12 text-gray-500">No appointment records found</td>
                                        </tr>
                                    </c:if>
                                    <c:forEach var="a" items="${appointments}">
                                        <tr class="border-b hover:bg-gray-50">
                                            <td class="py-4 px-6">${a.date} ${a.time}</td>
                                            <td class="py-4 px-6 font-mono text-indigo-600">${a.regNo}</td>
                                            <td class="py-4 px-6 font-semibold">${a.patient}</td>
                                            <td class="py-4 px-6">${a.doctor}</td>
                                            <td class="py-4 px-6">${a.department}</td>
                                            <td class="py-4 px-6">
                                                <span class="badge ${a.status eq 'Completed' ? 'badge-success' : (a.status eq 'Cancelled' ? 'badge-danger' : 'badge-info')}">
                                                    ${a.status}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</body>
</html>