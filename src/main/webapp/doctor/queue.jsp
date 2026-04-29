<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    List<Map<String, Object>> queueList = (List<Map<String, Object>>) request.getAttribute("queueList");
    if (queueList == null) queueList = new ArrayList<>();
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
    <meta charset="UTF-8"><title>Doctor - Queue</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
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
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #e2e8f0; }
        th { background-color: #f8fafc; font-weight: 600; }
        button { transition: all 0.15s ease; padding: 0.25rem 0.75rem; border-radius: 0.5rem; cursor: pointer; border: none; }
        .btn-primary { background-color: #3b82f6; color: white; }
        .btn-secondary { background-color: #10b981; color: white; }
        .btn-warning { background-color: #f59e0b; color: white; }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
    <!-- 左侧导航栏 -->
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
                <a href="<%= ctx %>/doctor/queue" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl active"><i class="fa-solid fa-users-line w-5"></i><span>Queue</span></a>
                <a href="<%= ctx %>/doctor/myAppointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-doctor w-5"></i><span>My Schedule</span></a>
                <a href="<%= ctx %>/doctor/search" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-magnifying-glass w-5"></i><span>Patient Search</span></a>
                <a href="<%= ctx %>/doctor/issues" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-triangle-exclamation w-5"></i><span>Issues</span></a>
                <a href="<%= ctx %>/doctor/notifications" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-bell w-5"></i><span>Alerts</span></a>
                <a href="<%= ctx %>/doctor/profile" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
            </nav>
            <div class="mt-auto pt-6 border-t border-white/40">
                <a href="<%= ctx %>/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a>
            </div>
        </div>
    </div>
    <!-- 右侧内容 -->
    <div class="flex-1 flex flex-col min-w-0 ml-80">
        <div class="flex-1 overflow-auto p-4 md:p-8">
            <div class="max-w-6xl mx-auto">
                <h2 class="text-2xl font-bold mb-6">Live Queue</h2>
                <div class="card">
                    <button id="callNextBtn" class="btn-primary mb-4">Call Next</button>
                    <div class="overflow-x-auto">
                        <table class="min-w-full">
                            <thead>
                                <tr><th>Ticket</th><th>Patient</th><th>Service</th><th>Status</th><th>Action</th></tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, Object> q : queueList) {
                                    String source = (String) q.get("source");
                                    Long id = ((Number) q.get("id")).longValue();
                                    String ticketNo = (String) q.get("ticketNo");
                                    String patient = (String) q.get("patient");
                                    String service = (String) q.get("service");
                                    int statusCode = (int) q.get("statusCode");
                                %>
                                <tr>
                                    <td><%= ticketNo %></td>
                                    <td><%= patient %></td>
                                    <td><%= service %></td>
                                    <td><%= statusCode==1?"Waiting":(statusCode==3?"Called":(statusCode==4?"Consulting":"Other")) %></td>
                                    <td>
                                        <% if (statusCode == 3) { %>
                                            <button onclick="startConsult('<%= source %>', <%= id %>)" class="btn-secondary">Start</button>
                                        <% } else if (statusCode == 4) { %>
                                            <button onclick="completeConsult('<%= source %>', <%= id %>)" class="btn-primary">Complete</button>
                                        <% } else if (statusCode == 1 || statusCode == 3) { %>
                                            <button onclick="skipPatient('<%= source %>', <%= id %>)" class="btn-warning">Skip</button>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                                <% if (queueList.isEmpty()) { %><tr><td colspan="5" class="text-center py-4">Queue is empty.</td></tr><% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
function callNext() {
    fetch('<%= ctx %>/doctor/action', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'action=callNext&ajax=true' })
    .then(res=>res.json()).then(data=>{ if(data.success) location.reload(); else alert(data.message); });
}
function startConsult(source, id) {
    fetch('<%= ctx %>/doctor/action', { method:'POST', body:`action=update&id=${id}&status=4&sourceType=${source}&ajax=true` })
    .then(res=>res.json()).then(data=>{ if(data.success) location.reload(); });
}
function completeConsult(source, id) {
    fetch('<%= ctx %>/doctor/action', { method:'POST', body:`action=update&id=${id}&status=5&sourceType=${source}&ajax=true` })
    .then(res=>res.json()).then(data=>{ if(data.success) location.reload(); });
}
function skipPatient(source, id) {
    if(confirm('Skip this patient?'))
        fetch('<%= ctx %>/doctor/action', { method:'POST', body:`action=skip&id=${id}&sourceType=${source}&ajax=true` })
        .then(res=>res.json()).then(data=>{ if(data.success) location.reload(); });
}
document.getElementById('callNextBtn').addEventListener('click', callNext);
</script>
</body>
</html>