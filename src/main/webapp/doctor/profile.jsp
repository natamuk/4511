<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("staffProfile");
    String realName = (profile != null && profile.get("realName") != null) ? profile.get("realName").toString() : "Doctor";
    String title = (profile != null && profile.get("title") != null) ? profile.get("title").toString() : "Physician";
    String dept = (profile != null && profile.get("departmentName") != null) ? profile.get("departmentName").toString() : "General";
        String clinicName = (profile != null && profile.get("clinicName") != null) ? profile.get("clinicName").toString() : title;
    String avatar = (profile != null && profile.get("avatar") != null) ? profile.get("avatar").toString() : "https://picsum.photos/200";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><title>Doctor - Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
        body {
            font-family: 'Noto Sans TC', sans-serif;
            background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%);
        }
        .glass {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid rgba(255, 255, 255, 0.6);
            backdrop-filter: blur(4px);
        }
        .nav-item {
            transition: background-color 0.15s ease, transform 0.15s ease;
            cursor: pointer;
        }
        .nav-item:hover { transform: translateX(8px); background: rgba(14,165,233,0.1); }
        .nav-item.active { background: rgba(14,165,233,0.14); color: #0369a1; font-weight: 700; }
        .card {
            background: white; border-radius: 1rem; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        input { padding: 0.5rem; border: 1px solid #ccc; border-radius: 0.5rem; width: 100%; margin-bottom: 1rem; }
        label { font-weight: 500; display: block; margin-bottom: 0.25rem; }
        button { padding: 0.5rem 1rem; background-color: #3b82f6; color: white; border: none; border-radius: 0.5rem; cursor: pointer; }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
    <div class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 z-40 fixed h-full">
        <div class="p-6 bg-gradient-to-r from-sky-700 to-blue-700">
            <div class="flex items-center gap-3">
                <i class="fa-solid fa-user-doctor text-4xl text-white"></i>
                <div><h1 class="text-2xl font-bold text-white">CCHC</h1><p class="text-sm text-white/90">Doctor Dashboard</p></div>
            </div>
        </div>
        <div class="p-6 flex-1 flex flex-col overflow-y-auto">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img src="<%= avatar %>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                <div><p class="font-semibold"><%= realName %></p><p class="text-sky-600 text-sm"><%= clinicName %></p></div>
            </div>
            <nav class="flex flex-col gap-1">
                <a href="<%= ctx %>/doctor/dashboard" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                <a href="<%= ctx %>/doctor/appointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar-days w-5"></i><span>Appointments</span></a>
                <a href="<%= ctx %>/doctor/checkin" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-clipboard-check w-5"></i><span>Consultation</span></a>
                <a href="<%= ctx %>/doctor/queue" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-users-line w-5"></i><span>Queue</span></a>
                <a href="<%= ctx %>/doctor/myAppointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-doctor w-5"></i><span>My Schedule</span></a>
                <a href="<%= ctx %>/doctor/search" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-magnifying-glass w-5"></i><span>Patient Search</span></a>
                <a href="<%= ctx %>/doctor/issues" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-triangle-exclamation w-5"></i><span>Issues</span></a>
                <a href="<%= ctx %>/doctor/notifications" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-bell w-5"></i><span>Alerts</span></a>
                <a href="<%= ctx %>/doctor/profile" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl active"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
            </nav>
            <div class="mt-auto pt-6 border-t border-white/40">
                <a href="<%= ctx %>/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a>
            </div>
        </div>
    </div>
    <div class="flex-1 flex flex-col min-w-0 ml-80">
        <div class="flex-1 overflow-auto p-4 md:p-8">
            <div class="max-w-2xl mx-auto">
                <h2 class="text-2xl font-bold mb-6">Profile & Security</h2>
                <div class="card">
                    <form action="<%= ctx %>/doctor/update-profile" method="post">
                        <label>Full Name:</label>
                        <input type="text" name="name" value="<%= realName %>" readonly>
                        <label>Title:</label>
                        <input type="text" value="<%= title %>" readonly>
                        <label>Department:</label>
                        <input type="text" value="<%= dept %>" readonly>
                        <hr class="my-4">
                        <h3 class="text-lg font-semibold mb-4">Change Password</h3>
                        <label>Current Password:</label>
                        <input type="password" name="oldPwd">
                        <label>New Password:</label>
                        <input type="password" name="newPwd">
                        <label>Confirm New:</label>
                        <input type="password" name="confirmPwd">
                        <button type="submit" class="mt-2">Save Changes</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>