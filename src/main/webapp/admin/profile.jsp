<%-- profile.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ page import="com.mycompany.system.db.AdminDB" %>
<%@ page import="com.mycompany.system.bean.AdminBean" %>
<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    AdminBean admin = AdminDB.getById(loginUser.getId());
    request.setAttribute("adminProfile", admin);
%>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>Profile - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: system-ui, sans-serif; background: #f0f2f5; }
        .app { display: flex; height: 100vh; }
        .sidebar { width: 260px; background: white; border-right: 1px solid #e5e7eb; display: flex; flex-direction: column; }
        .sidebar-header { padding: 1.5rem; background: linear-gradient(135deg, #4f46e5, #7c3aed); color: white; }
        .sidebar-nav { flex: 1; padding: 1rem; }
        .nav-item { display: flex; align-items: center; gap: 0.75rem; padding: 0.6rem 1rem; border-radius: 0.5rem; color: #1f2937; text-decoration: none; margin-bottom: 0.25rem; }
        .nav-item:hover { background: #f3f4f6; }
        .nav-item.active { background: #e0e7ff; color: #4f46e5; font-weight: 600; }
        .logout-btn { margin-top: auto; padding: 1rem; border-top: 1px solid #e5e7eb; text-align: center; }
        .main { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .header { background: white; border-bottom: 1px solid #e5e7eb; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .content { padding: 2rem; }
        .card { background: white; border-radius: 1rem; padding: 2rem; max-width: 700px; margin: 0 auto; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 1.5rem; }
        label { font-weight: 600; display: block; margin-bottom: 0.5rem; }
        input { width: 100%; padding: 0.6rem; border: 1px solid #d1d5db; border-radius: 0.5rem; }
        button { padding: 0.5rem 1.5rem; border-radius: 0.5rem; font-weight: 600; border: none; cursor: pointer; }
        .btn-primary { background: #4f46e5; color: white; }
        .btn-warning { background: #f59e0b; color: white; }
        hr { margin: 2rem 0; }
    </style>
</head>
<body>
<div class="app">
    <aside class="sidebar"><!-- 侧边栏略，同前，实际请复制完整 -->
        <div class="sidebar-header"><div class="flex items-center gap-2"><i class="fa-solid fa-user-shield text-2xl"></i><div><h1 class="text-xl font-bold">CCHC</h1><p class="text-sm opacity-90">Admin Console</p></div></div></div>
        <div class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item">Dashboard</a>
            <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item">User Management</a>
            <a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="nav-item">Appointments</a>
            <a href="${pageContext.request.contextPath}/admin/queue.jsp" class="nav-item">Queue</a>
            <a href="${pageContext.request.contextPath}/admin/quota.jsp" class="nav-item">Services & Quota</a>
            <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item">Reports</a>
            <a href="${pageContext.request.contextPath}/admin/logs.jsp" class="nav-item">Audit Logs</a>
            <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item">Notifications</a>
            <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item">Settings</a>
            <a href="${pageContext.request.contextPath}/admin/csv.jsp" class="nav-item">CSV Import/Export</a>
            <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item active">Profile</a>
        </div>
        <div class="logout-btn"><a href="${pageContext.request.contextPath}/logout" class="nav-item justify-center text-red-600">Logout</a></div>
    </aside>
    <div class="main">
        <header class="header"><h2 class="text-2xl font-semibold">Account Profile</h2><span id="current-date" class="text-sm text-gray-500"></span></header>
        <div class="content">
            <div class="card">
                <form action="${pageContext.request.contextPath}/admin/update-profile" method="post">
                    <div class="form-group"><label>Full Name</label><input type="text" name="realName" value="${adminProfile.realName}" required></div>
                    <div class="form-group"><label>Username</label><input type="text" value="${adminProfile.username}" disabled style="background:#f3f4f6;"></div>
                    <div class="form-group"><label>Email Address</label><input type="email" name="email" value="${adminProfile.email}" required></div>
                    <div class="form-group"><label>Phone Number</label><input type="text" name="phone" value="${adminProfile.phone}" required></div>
                    <div class="flex justify-end"><button type="submit" class="btn-primary">Save Profile Changes</button></div>
                </form>
                <hr>
                <h3 class="text-xl font-bold mb-4">Change Password</h3>
                <form action="${pageContext.request.contextPath}/admin/update-profile" method="post">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="form-group"><label>Current Password</label><input type="password" name="oldPwd" required></div>
                    <div class="form-group"><label>New Password</label><input type="password" name="newPwd" id="newPwd" required></div>
                    <div class="form-group"><label>Confirm New Password</label><input type="password" name="confirmPwd" id="confirmPwd" required></div>
                    <div class="flex justify-end"><button type="submit" class="btn-warning">Update Password</button></div>
                </form>
            </div>
        </div>
    </div>
</div>
<script>
    document.getElementById('current-date').innerText = new Date().toLocaleDateString('zh-CN');
    document.querySelector('form[action*="changePassword"]').addEventListener('submit', function(e) {
        if(document.getElementById('newPwd').value !== document.getElementById('confirmPwd').value) {
            e.preventDefault();
            Swal.fire('Error', 'New passwords do not match!', 'error');
        }
    });
</script>
</body>
</html>