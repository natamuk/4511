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
    List<Map<String, Object>> notifications = dao.getNotifications(loginUser.getId());
    request.setAttribute("notifications", notifications);
%>
<!DOCTYPE html>
<html lang="zh">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Notifications - CCHC Admin</title>
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
            .badge{
                display:inline-flex;
                align-items:center;
                gap:0.35rem;
                padding:0.35rem 0.7rem;
                border-radius:999px;
                font-size:0.75rem;
                font-weight:700
            }
            .badge-success{
                background:#dcfce7;
                color:#166534
            }
            .badge-danger{
                background:#fee2e2;
                color:#b91c1c
            }
            .badge-info{
                background:#dbeafe;
                color:#1d4ed8
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
                        <a href="${pageContext.request.contextPath}/admin/clinic_config.jsp" class="nav-item"><i class="fa-solid fa-building"></i><span>Clinic & Services</span></a>
                        <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"><i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span></a>
                        <a href="${pageContext.request.contextPath}/admin/abnormal_records.jsp" class="nav-item"><i class="fa-solid fa-exclamation-triangle"></i><span>Abnormal Records</span></a>
                        <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item active"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                        <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item"><i class="fa-solid fa-sliders w-5"></i><span>Settings</span></a>
                        <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                    </nav>
                    <div class="mt-auto pt-6 border-t border-white/40"><a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a></div>
                </div>
            </aside>
            <div class="flex-1 flex flex-col min-w-0">
                <header class="glass border-b px-8 py-4 flex justify-between items-center"><h2 class="text-2xl font-semibold">Notifications</h2><div class="flex items-center gap-3">
                        <today:today/></div></header>
                <div class="flex-1 overflow-auto p-4 md:p-8">
                    <div class="glass rounded-3xl p-8 max-w-5xl mx-auto">
                        <div class="flex items-center justify-between mb-6 border-b pb-4"><h3 class="text-2xl font-bold text-gray-800">Alerts & Notifications</h3><button onclick="markAllRead()" class="px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-medium rounded-xl transition"><i class="fa-solid fa-check-double mr-1"></i> Mark All as Read</button></div>
                        <div class="space-y-4">
                            <c:if test="${empty notifications}"><div class="text-center py-16 text-gray-500"><i class="fa-regular fa-bell-slash text-5xl mb-4"></i><p class="text-lg">Inbox is empty.</p></div></c:if>
                                    <c:forEach var="n" items="${notifications}">
                                <div class="p-5 border rounded-2xl bg-white flex items-start gap-4 shadow-sm hover:shadow-md transition cursor-pointer ${n.read ? 'opacity-70' : ''}" onclick="openNotification(${n.id})">
                                    <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${n.type == 'success' ? 'bg-emerald-100 text-emerald-700' : n.type == 'warning' ? 'bg-amber-100 text-amber-700' : 'bg-blue-100 text-blue-700'}">
                                        <i class="fa-solid ${n.type == 'warning' ? 'fa-triangle-exclamation' : 'fa-bell'}"></i>
                                    </div>
                                    <div class="flex-1"><div class="flex items-center justify-between gap-4 mb-1"><p class="font-bold text-lg text-gray-800 flex items-center gap-2">${n.title}<c:if test="${!n.read}"><span class="w-2.5 h-2.5 rounded-full bg-red-500 inline-block shadow-sm shadow-red-200"></span></c:if></p><span class="text-xs font-medium text-gray-400 bg-gray-50 px-2 py-1 rounded">${n.time}</span></div><p class="text-gray-600">${n.message}</p></div>
                                    </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            function markAllRead() {
                fetch('<%= request.getContextPath()%>/admin/notifications/mark-all-read', {method: 'POST', headers: {'X-Requested-With': 'XMLHttpRequest'}})
                        .then(res => res.json()).then(data => {
                    if (data.success)
                        location.reload();
                    else
                        Swal.fire('Error', 'Failed', 'error');
                });
            }
            function openNotification(id) {
                console.log('open', id);
            }
            document.getElementById('current-date').innerText = new Date().toLocaleDateString('zh-CN', {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'});
        </script>
    </body>
</html>