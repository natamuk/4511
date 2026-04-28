<%-- queue.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ page import="com.mycompany.system.dao.AdminDashboardDao" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    AdminDashboardDao dao = new AdminDashboardDao();
    List<Map<String, Object>> queue = dao.getQueueList();
    request.setAttribute("queue", queue);
%>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Queue Management - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style>
            @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
            * {
                box-sizing: border-box;
            }
            html {
                scroll-behavior: smooth;
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
                -webkit-backdrop-filter: blur(4px);
            }
            .nav-item {
                transition: background-color .2s, transform .2s, color .2s;
                cursor:pointer;
            }
            .nav-item:hover {
                transform: translateX(8px);
                background: rgba(99,102,241,0.1);
            }
            .nav-item.active {
                background: rgba(99,102,241,0.14);
                color:#4f46e5;
                font-weight:700;
            }
            .card:hover {
                transform: translateY(-4px);
                box-shadow:0 15px 30px rgba(0,0,0,0.08);
            }
            .badge {
                display:inline-flex;
                align-items:center;
                gap:.35rem;
                padding:.35rem .7rem;
                border-radius:999px;
                font-size:.75rem;
                font-weight:700;
                white-space:nowrap;
            }
            .badge-success {
                background:#dcfce7;
                color:#166534;
            }
            .badge-warning {
                background:#fef3c7;
                color:#92400e;
            }
            .badge-danger {
                background:#fee2e2;
                color:#b91c1c;
            }
            .badge-info {
                background:#dbeafe;
                color:#1d4ed8;
            }
            #main-content {
                opacity:0;
                transform: translate3d(0,10px,0);
                will-change: opacity, transform;
                contain:layout paint;
            }
            @media (max-width:768px) {
                #sidebar {
                    transform: translateX(-100%);
                    transition: transform .3s;
                }
                #sidebar.open {
                    transform: translateX(0);
                }
            }
            .switch {
                position: relative;
                display: inline-block;
                width: 50px;
                height: 26px;
            }
            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }
            .slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #ccc;
                transition: .4s;
                border-radius: 34px;
            }
            .slider:before {
                position: absolute;
                content: "";
                height: 18px;
                width: 18px;
                left: 4px;
                bottom: 4px;
                background-color: white;
                transition: .4s;
                border-radius: 50%;
            }
            input:checked + .slider {
                background-color: #2196F3;
            }
            input:checked + .slider:before {
                transform: translateX(24px);
            }
        </style>
</head>
<body>
<div class="app">
    <aside class="sidebar"> 
        <div class="sidebar-header"><div class="flex items-center gap-2"><i class="fa-solid fa-user-shield text-2xl"></i><div><h1 class="text-xl font-bold">CCHC</h1><p class="text-sm opacity-90">Admin Console</p></div></div></div>
        <div class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item"> Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item"> User Management</a>
            <a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="nav-item"> Appointments</a>
            <a href="${pageContext.request.contextPath}/admin/queue.jsp" class="nav-item active"> Queue</a>
            <a href="${pageContext.request.contextPath}/admin/quota.jsp" class="nav-item"> Services & Quota</a>
            <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"> Reports</a>
            <a href="${pageContext.request.contextPath}/admin/logs.jsp" class="nav-item"> Audit Logs</a>
            <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item"> Notifications</a>
            <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item"> Settings</a>
            <a href="${pageContext.request.contextPath}/admin/csv.jsp" class="nav-item"> CSV Import/Export</a>
            <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"> Profile</a>
        </div>
        <div class="logout-btn"><a href="${pageContext.request.contextPath}/logout" class="nav-item justify-center text-red-600"> Logout</a></div>
    </aside>
    <div class="main">
        <header class="header"><h2 class="text-2xl font-semibold">Queue Management</h2><span id="current-date" class="text-sm text-gray-500"></span></header>
        <div class="content">
            <div class="max-w-4xl mx-auto">
                <h2 class="text-2xl font-bold mb-4">Current Queue</h2>
                <c:if test="${empty queue}"><div class="text-center py-12 text-gray-500">No active queue entries.</div></c:if>
                <c:forEach var="q" items="${queue}">
                    <div class="queue-item">
                        <div class="flex justify-between items-start">
                            <div><p class="font-semibold text-lg">${q.clinic}</p><p class="text-sm text-gray-600">Ticket: <span class="font-mono font-bold text-indigo-600">${q.ticketNo}</span></p><p class="text-sm">Patient: ${q.patient}</p></div>
                            <span class="queue-status status-${q.status}">${q.status}</span>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</div>
<script>document.getElementById('current-date').innerText = new Date().toLocaleDateString('zh-CN');</script>
</body>
</html>