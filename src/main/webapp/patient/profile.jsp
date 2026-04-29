<%-- patient/profile.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ page import="com.mycompany.system.bean.PatientBean" %>
<%@ page import="com.mycompany.system.db.PatientDB" %>
<%@taglib uri="/WEB-INF/tlds/current-date.tld" prefix="today" %>

<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"patient".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Load Patient Bean
    PatientBean patient = PatientDB.getById(loginUser.getId());

    String ctx = request.getContextPath();

    String realName = (patient != null && patient.getRealName() != null) ? patient.getRealName() : "";
    String phone    = (patient != null && patient.getPhone() != null) ? patient.getPhone() : "";
    String email    = (patient != null && patient.getEmail() != null) ? patient.getEmail() : "";
    String address  = (patient != null && patient.getAddress() != null) ? patient.getAddress() : "";
    String avatar   = (patient != null && patient.getAvatar() != null) ? patient.getAvatar() : "https://picsum.photos/200/200?random=1";
%>

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - CCHC Patient</title>
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
        .app { display: flex; height: 100vh; overflow: hidden; }
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
        .nav-item { transition: transform 0.16s ease-out; cursor: pointer; }
        .nav-item:hover { transform: translateX(6px); background: rgba(59,135,255,0.1); }
        .nav-item.active { background: linear-gradient(90deg, rgba(37,99,235,0.15), rgba(99,102,241,0.15)); color: #1d4ed8; font-weight: 700; box-shadow: inset 4px 0 0 #2563eb; }
    </style>
</head>
<body>
<div class="app">

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="p-6 bg-gradient-to-r from-blue-700 to-indigo-700 text-white">
            <div class="flex items-center gap-3">
                <i class="fa-solid fa-clinic-medical text-4xl"></i>
                <div>
                    <h1 class="text-2xl font-bold">CCHC</h1>
                    <p class="text-sm opacity-90">Patient Portal</p>
                </div>
            </div>
        </div>

        <div class="p-6 flex-1 flex flex-col overflow-y-auto">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img src="<%= avatar %>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                <div>
                    <p class="font-semibold"><%= realName.isEmpty() ? "Patient" : realName %></p>
                    <p class="text-emerald-600 text-sm">Patient</p>
                </div>
            </div>

            <nav class="space-y-1">
                <a href="<%= ctx %>/patient/dashboard" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-house w-5"></i><span>Home</span></a>
                <a href="<%= ctx %>/patient/book" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar-check w-5"></i><span>Book Appointment</span></a>
                <a href="<%= ctx %>/patient/calendar" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar w-5"></i><span>Appointment Calendar</span></a>
                <a href="<%= ctx %>/patient/myappointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-list w-5"></i><span>My Appointments</span></a>
                <a href="<%= ctx %>/patient/queue" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-users-line w-5"></i><span>Join Queue</span></a>
                <a href="<%= ctx %>/patient/notifications" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                <a href="<%= ctx %>/patient/profile" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl active"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
            </nav>

            <div class="mt-auto pt-6 border-t border-white/40">
                <a href="<%= ctx %>/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition">
                    <i class="fa-solid fa-right-from-bracket"></i><span>Logout</span>
                </a>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <div class="main">
        <header class="header">
            <h2 class="text-2xl font-semibold">My Profile</h2>
            <today:today />
        </header>

        <div class="content">
            <div class="max-w-2xl mx-auto bg-white rounded-3xl shadow p-10">

                <!-- Success / Error Messages -->
                <% if (request.getAttribute("success") != null) { %>
                    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-2xl mb-6">
                        <%= request.getAttribute("success") %>
                    </div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-2xl mb-6">
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>

                <!-- Profile Form -->
                <form action="<%= ctx %>/patient/update-profile" method="post" class="space-y-6">
                    <div>
                        <label class="block text-sm font-semibold mb-2">Real Name</label>
                        <input type="text" name="realName" value="<%= realName %>" 
                               class="w-full px-5 py-3 border border-gray-300 rounded-2xl focus:outline-none focus:border-indigo-500">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold mb-2">Phone Number</label>
                        <input type="text" name="phone" value="<%= phone %>" 
                               class="w-full px-5 py-3 border border-gray-300 rounded-2xl focus:outline-none focus:border-indigo-500">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold mb-2">Email Address</label>
                        <input type="email" name="email" value="<%= email %>" 
                               class="w-full px-5 py-3 border border-gray-300 rounded-2xl focus:outline-none focus:border-indigo-500">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold mb-2">Home Address</label>
                        <input type="text" name="address" value="<%= address %>" 
                               class="w-full px-5 py-3 border border-gray-300 rounded-2xl focus:outline-none focus:border-indigo-500">
                    </div>

                    <div class="flex justify-end">
                        <button type="submit" class="px-8 py-3 bg-indigo-600 text-white font-semibold rounded-2xl hover:bg-indigo-700">
                            Save Profile Changes
                        </button>
                    </div>
                </form>

                <hr class="my-10">

                <!-- Change Password -->
                <h3 class="text-xl font-bold mb-6">Change Password</h3>
                <form action="<%= ctx %>/patient/update-profile" method="post">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="space-y-6">
                        <div>
                            <label class="block text-sm font-semibold mb-2">Current Password</label>
                            <input type="password" name="oldPwd" required class="w-full px-5 py-3 border border-gray-300 rounded-2xl">
                        </div>
                        <div>
                            <label class="block text-sm font-semibold mb-2">New Password</label>
                            <input type="password" name="newPwd" id="newPwd" required class="w-full px-5 py-3 border border-gray-300 rounded-2xl">
                        </div>
                        <div>
                            <label class="block text-sm font-semibold mb-2">Confirm New Password</label>
                            <input type="password" name="confirmPwd" id="confirmPwd" required class="w-full px-5 py-3 border border-gray-300 rounded-2xl">
                        </div>
                    </div>
                    <div class="flex justify-end mt-8">
                        <button type="submit" class="px-8 py-3 bg-amber-600 text-white font-semibold rounded-2xl hover:bg-amber-700">
                            Update Password
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // Password confirmation
    document.querySelector('form[action*="changePassword"]').addEventListener('submit', function (e) {
        if (document.getElementById('newPwd').value !== document.getElementById('confirmPwd').value) {
            e.preventDefault();
            Swal.fire('Error', 'New passwords do not match!', 'error');
        }
    });
</script>
</body>
</html>
