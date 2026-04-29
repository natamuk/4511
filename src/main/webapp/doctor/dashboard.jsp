<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("staffProfile");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    List<Map<String, Object>> queueList = (List<Map<String, Object>>) request.getAttribute("queueList");
    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");

    String realName = (profile != null && profile.get("realName") != null) ? profile.get("realName").toString() : "Doctor";
    String title = (profile != null && profile.get("title") != null) ? profile.get("title").toString() : "Physician";
    String dept = (profile != null && profile.get("departmentName") != null) ? profile.get("departmentName").toString() : "General";
    String avatar = (profile != null && profile.get("avatar") != null) ? profile.get("avatar").toString() : "https://picsum.photos/200";
    String clinicName = (profile != null && profile.get("clinicName") != null) ? profile.get("clinicName").toString() : title;
    if (stats == null) {
        stats = new HashMap<>();
    }
    if (appointments == null) {
        appointments = new ArrayList<>();
    }
    if (queueList == null) {
        queueList = new ArrayList<>();
    }
    if (notifications == null)
        notifications = new ArrayList<>();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><title>Doctor Dashboard</title>
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
                background: rgba(255, 255, 255, 0.95);
                border: 1px solid rgba(255, 255, 255, 0.6);
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
                backdrop-filter: blur(4px);
                -webkit-backdrop-filter: blur(4px);
                transform: translateZ(0);
            }
            .nav-item {
                transition: background-color 0.15s ease, transform 0.15s ease, color 0.15s ease;
                cursor: pointer;
            }
            .nav-item:hover {
                transform: translateX(8px);
                background: rgba(14,165,233,0.1);
            }
            .nav-item.active {
                background: rgba(14,165,233,0.14);
                color: #0369a1;
                font-weight: 700;
            }
            .status-badge {
                display: inline-flex;
                align-items: center;
                gap: .35rem;
                padding: .35rem .75rem;
                border-radius: 9999px;
                font-size: .75rem;
                font-weight: 700;
                white-space: nowrap;
            }
            .card {
                background: white;
                border-radius: 1rem;
                padding: 1.5rem;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            }
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(4,1fr);
                gap: 1rem;
                margin-bottom: 2rem;
            }
            .stat-card {
                background: white;
                border-radius: 1rem;
                padding: 1rem;
                text-align: center;
                box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 0.75rem;
                text-align: left;
                border-bottom: 1px solid #e2e8f0;
            }
            th {
                background-color: #f8fafc;
                font-weight: 600;
            }
            button {
                transition: all 0.15s ease;
                padding: 0.5rem 1rem;
                border-radius: 0.5rem;
                cursor: pointer;
                border: none;
            }
            .btn-primary {
                background-color: #3b82f6;
                color: white;
            }
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
                        <img src="<%= avatar%>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                        <div><p class="font-semibold"><%= realName%></p><p class="text-sky-600 text-sm"><%= clinicName%></p></p></div>
                    </div>
                    <nav class="flex flex-col gap-1">
                        <a href="<%= ctx%>/doctor/dashboard" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl active"><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                        <a href="<%= ctx%>/doctor/appointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar-days w-5"></i><span>Appointments</span></a>
                        <a href="<%= ctx%>/doctor/checkin" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-clipboard-check w-5"></i><span>Consultation</span></a>
                        <a href="<%= ctx%>/doctor/queue" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-users-line w-5"></i><span>Queue</span></a>
                        <a href="<%= ctx%>/doctor/myAppointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-doctor w-5"></i><span>My Schedule</span></a>
                        <a href="<%= ctx%>/doctor/search" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-magnifying-glass w-5"></i><span>Patient Search</span></a>
                        <a href="<%= ctx%>/doctor/issues" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-triangle-exclamation w-5"></i><span>Issues</span></a>
                        <a href="<%= ctx%>/doctor/notifications" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-bell w-5"></i><span>Alerts</span></a>
                        <a href="<%= ctx%>/doctor/profile" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                    </nav>
                    <div class="mt-auto pt-6 border-t border-white/40">
                        <a href="<%= ctx%>/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a>
                    </div>
                </div>
            </div>
            <div class="flex-1 flex flex-col min-w-0 ml-80">
                <div class="flex-1 overflow-auto p-4 md:p-8">
                    <div class="max-w-6xl mx-auto">
                        <h1 class="text-3xl font-bold mb-4">Welcome, <%= realName%></h1>
                        <div class="card mb-6">
                            <div class="flex justify-between items-center">
                                <div><h3 class="text-lg font-semibold">Daily Check-in</h3><p id="checkin-status" class="text-gray-500">Not checked in</p></div>
                                <button id="checkinBtn" class="btn-primary">Check In</button>
                            </div>
                        </div>
                        <div class="stats-grid">
                            <div class="stat-card"><h3 class="font-semibold">Total Booked</h3><p class="text-2xl font-bold"><%= stats.get("bookedCount") != null ? stats.get("bookedCount") : 0%></p></div>
                            <div class="stat-card"><h3 class="font-semibold">Queue Count</h3><p class="text-2xl font-bold"><%= stats.get("waitingCount") != null ? stats.get("waitingCount") : 0%></p></div>
                            <div class="stat-card"><h3 class="font-semibold">Consulting</h3><p class="text-2xl font-bold"><%= stats.get("consultingCount") != null ? stats.get("consultingCount") : 0%></p></div>
                            <div class="stat-card"><h3 class="font-semibold">Completed</h3><p class="text-2xl font-bold"><%= stats.get("completedCount") != null ? stats.get("completedCount") : 0%></p></div>
                        </div>
                        <div class="card">
                            <h3 class="text-lg font-semibold mb-4">Today's Appointments</h3>
                            <div class="overflow-x-auto">
                                <table class="min-w-full">
                                    <thead><tr><th>Ticket</th><th>Patient</th><th>Status</th></tr></thead>
                                    <tbody>
                                        <% for (Map<String, Object> a : appointments) {%>
                                        <tr><td><%= a.get("ticketNo")%></td><td><%= a.get("patient")%></td><td><%= a.get("status")%></td></tr>
                                        <% } %>
                                        <% if (appointments.isEmpty()) { %><tr><td colspan="3" class="text-center py-4">No appointments today.</td></tr><% }%>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            document.getElementById('checkinBtn').addEventListener('click', function () {
                fetch('<%= ctx%>/doctor/checkin', {method: 'POST', body: 'action=checkin'})
                        .then(res => res.json())
                        .then(data => {
                            if (data.success) {
                                document.getElementById('checkin-status').innerHTML = 'Checked in at ' + data.checkinTime;
                                document.getElementById('checkinBtn').disabled = true;
                                Swal.fire('Success', data.message, 'success');
                            } else if (data.alreadyChecked) {
                                document.getElementById('checkin-status').innerHTML = 'Checked in at ' + data.checkinTime;
                                document.getElementById('checkinBtn').disabled = true;
                                Swal.fire('Info', data.message, 'info');
                            } else {
                                Swal.fire('Error', data.message, 'error');
                            }
                        })
                        .catch(err => {
                            Swal.fire('Network Error', 'Please try again later.', 'error');
                        });
            });
        </script>
    </body>
</html>