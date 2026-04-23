<%-- 
    Document   : home
    Created on : 2026年3月31日, 22:17:49
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Doctor Dashboard - CCHC Community Clinic System</title>
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

            .home-card {
                transition: transform 0.15s ease, box-shadow 0.15s ease;
            }
            .home-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 15px 30px rgba(0,0,0,0.08);
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
            .status-pending {
                background:#fef3c7;
                color:#92400e;
            }
            .status-approved {
                background:#dbeafe;
                color:#1d4ed8;
            }
            .status-arrived {
                background:#dcfce7;
                color:#166534;
            }
            .status-no-show {
                background:#fee2e2;
                color:#b91c1c;
            }
            .status-completed {
                background:#e9d5ff;
                color:#6b21a8;
            }
            .status-cancelled {
                background:#e5e7eb;
                color:#374151;
            }

            .queue-card {
                transition: transform 0.15s ease, box-shadow 0.15s ease;
            }
            .queue-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 24px rgba(0,0,0,0.06);
            }

            button {
                transition: all 0.15s ease;
            }

            .page {
                display: none;
            }
            .page.active {
                display: block;
            }
        </style>
    </head>
    <body class="min-h-screen">
        <div class="flex h-screen overflow-hidden relative">
            <div class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 z-40 fixed h-full">
                <div class="p-6 bg-gradient-to-r from-sky-700 to-blue-700">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-user-doctor text-4xl"></i>
                        <div>
                            <h1 class="text-2xl font-bold">CCHC</h1>
                            <p class="text-sm opacity-90">Doctor Dashboard</p>
                        </div>
                    </div>
                </div>

                <div class="p-6 flex-1 flex flex-col overflow-y-auto">
                    <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                        <img src="https://picsum.photos/200" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                        <div>
                            <p class="font-semibold">Doctor</p>
                            <p class="text-sky-600 text-sm">Physician</p>
                            <p class="text-xs text-gray-500 mt-1">General Clinic</p>
                        </div>
                    </div>

                    <button onclick="show('dashboard')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span>
                    </button>
                    <button onclick="show('appointments')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-calendar-days w-5"></i><span>Appointments</span>
                    </button>
                    <button onclick="show('checkin')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-clipboard-check w-5"></i><span>Consultation</span>
                    </button>
                    <button onclick="show('queue')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-users-line w-5"></i><span>Queue</span>
                    </button>
                    <button onclick="show('myAppointments')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-user-doctor w-5"></i><span>My Schedule</span>
                    </button>
                    <button onclick="show('search')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-magnifying-glass w-5"></i><span>Patient Search</span>
                    </button>
                    <button onclick="show('issues')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-triangle-exclamation w-5"></i><span>Issues</span>
                    </button>
                    <button onclick="show('notifications')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-bell w-5"></i><span>Alerts</span>
                    </button>
                    <button onclick="show('profile')" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl text-left ">
                        <i class="fa-solid fa-user-gear w-5"></i><span>Profile</span>
                    </button>

                    <div class="mt-auto pt-6 border-t border-white/40">
                        <button onclick="logout()" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition">
                            <i class="fa-solid fa-right-from-bracket"></i>
                            <span>Logout</span>
                        </button>
                    </div>
                </div>
            </div>

            <div class="flex-1 flex flex-col min-w-0 ml-80">
                <div class="flex-1 overflow-auto p-4 md:p-8">
                    <div class="page active" id="dashboard"><%@ include file="contents/dashboard-contents.jsp" %></div>
                    <div class="page" id="appointments"><%@ include file="contents/appointments-contents.jsp" %></div>
                    <div class="page" id="checkin"><%@ include file="contents/checkin-contents.jsp" %></div>
                    <div class="page" id="queue"><%@ include file="contents/queue-contents.jsp" %></div>
                    <div class="page" id="myAppointments"><%@ include file="contents/myAppointments-contents.jsp" %></div>
                    <div class="page" id="search"><%@ include file="contents/search-contents.jsp" %></div>
                    <div class="page" id="notifications"><%@ include file="contents/notifications-contents.jsp" %></div>
                    <div class="page" id="issues"><%@ include file="contents/issues-contents.jsp" %></div>
                    <div class="page" id="profile"><%@ include file="contents/profile-contents.jsp" %></div>
                </div>
            </div>
        </div>

        <script>
            function escapeHtml(str) {
                if (!str)
                    return'';
                return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            }
            function queueStatusBadge(c) {
                if (c == 1)
                    return'<span class="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">Waiting</span>';
                if (c == 3)
                    return'<span class="px-2 py-1 bg-yellow-100 text-yellow-700 text-xs rounded">Called</span>';
                if (c == 4)
                    return'<span class="px-2 py-1 bg-indigo-100 text-indigo-700 text-xs rounded">Consulting</span>';
                if (c == 5)
                    return'<span class="px-2 py-1 bg-green-100 text-green-700 text-xs rounded">Completed</span>';
                return'<span class="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded">Skipped</span>';
            }
            function appointmentStatusBadge(c) {
                if (c == 2)
                    return'<span class="px-2 py-1 bg-yellow-100 text-yellow-700 text-xs rounded">Pending</span>';
                if (c == 3)
                    return'<span class="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">Checked In</span>';
                if (c == 4)
                    return'<span class="px-2 py-1 bg-indigo-100 text-indigo-700 text-xs rounded">Consulting</span>';
                if (c == 5)
                    return'<span class="px-2 py-1 bg-green-100 text-green-700 text-xs rounded">Done</span>';
                return'<span class="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded">Rejected</span>';
            }

            function logout() {
                Swal.fire({
                    title: 'Confirm logout?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, log out',
                    cancelButtonText: 'Cancel'
                }).then(r => {
                    if (r.isConfirmed) {
                        window.location.href = "../login.jsp";
                    }
                });
            }

            function show(id) {
                document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
                document.getElementById(id).classList.add('active');
            }
        </script>
    </body>
</html>