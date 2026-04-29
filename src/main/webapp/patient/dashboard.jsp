<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("patientProfile");
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    List<Map<String, Object>> queueTickets = (List<Map<String, Object>>) request.getAttribute("queueTickets");
    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");

    String realName = (profile != null && profile.get("realName") != null) ? profile.get("realName").toString() : "Patient";
    String avatar = (profile != null && profile.get("avatar") != null) ? profile.get("avatar").toString() : "https://picsum.photos/200/200?random=1";
    if (appointments == null) {
        appointments = new ArrayList<>();
    }
    if (queueTickets == null) {
        queueTickets = new ArrayList<>();
    }
    if (notifications == null)
        notifications = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Patient Dashboard</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.1/build/qrcode.min.js"></script>
        <style>
            /* 样式保持不变，略（为了节省篇幅，实际使用时请保留原样式） */
            @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Noto Sans TC', sans-serif;
                background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%);
            }
            .glass {
                background: rgba(255,255,255,0.85);
                backdrop-filter: blur(8px);
                border: 1px solid rgba(255,255,255,0.6);
            }
            .nav-item {
                transition: transform 0.16s ease-out;
                cursor: pointer;
            }
            .nav-item:hover {
                transform: translateX(6px);
                background: rgba(59,135,255,0.1);
            }
            .nav-item.active {
                background: linear-gradient(90deg, rgba(37,99,235,0.15), rgba(99,102,241,0.15));
                color: #1d4ed8;
                font-weight: 700;
                box-shadow: inset 4px 0 0 #2563eb;
            }
            .home-card, .clinic-card {
                transition: transform 0.2s ease-out, box-shadow 0.2s ease-out;
            }
            .home-card:hover, .clinic-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 10px 25px rgba(0,0,0,0.08);
            }
            .quick-btn {
                transition: transform 0.15s ease-out;
            }
            .quick-btn:hover {
                transform: scale(1.02);
            }
            .calendar-day {
                aspect-ratio: 1/1;
            }
            .clinic-topbar {
                height: 8px;
            }
            .slot-group {
                border: 1px solid rgba(229,231,235,0.9);
                border-radius: 1rem;
                background: rgba(255,255,255,0.72);
                overflow: hidden;
            }
            .slot-group summary {
                padding: 0.9rem 1rem;
                font-weight: 700;
                display: flex;
                justify-content: space-between;
                cursor: pointer;
                list-style: none;
            }
            .slot-grid {
                padding: 0 1rem 1rem 1rem;
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 0.65rem;
            }
            .slot-btn {
                padding: 0.85rem 0.9rem;
                border: 1px solid #dbe4f0;
                border-radius: 0.9rem;
                background: white;
                text-align: left;
                transition: all 0.15s ease;
                cursor: pointer;
            }
            .slot-btn:hover:not(.active) {
                transform: translateY(-2px);
                border-color: #93c5fd;
            }
            .slot-btn.active {
                background: #2563eb !important;
                border-color: #2563eb !important;
                color: white;
            }
            .slot-btn.active .slot-time, .slot-btn.active .slot-capacity {
                color: white !important;
            }
            .slot-time {
                font-weight: 700;
                color: #111827;
            }
            .slot-capacity {
                font-size: 0.75rem;
                color: #6b7280;
                margin-top: 0.2rem;
            }
            summary::-webkit-details-marker {
                display: none;
            }
            button, input {
                border: none;
                outline: none;
            }
            input {
                border: 1px solid #ddd;
            }
        </style>
    </head>
    <body class="min-h-screen">
        <div class="flex h-screen overflow-hidden relative">
            <!-- 左侧导航栏（与原来相同，略写，实际请保留完整侧边栏） -->
            <div class="w-72 glass shadow-2xl flex flex-col border-r border-white/50 z-40">
                <div class="p-6 bg-gradient-to-r from-blue-700 to-indigo-700 text-white">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-clinic-medical text-4xl"></i>
                        <div>
                            <h1 class="text-2xl font-bold">CCHC</h1>
                            <p class="text-sm opacity-90">Community Clinic Appointment System</p>
                        </div>
                    </div>
                </div>
                <div class="p-6 flex-1 flex flex-col overflow-y-auto">
                    <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                        <img class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" src="<%= avatar%>" alt="avatar">
                        <div>
                            <p class="font-semibold"><%= realName%></p>
                            <p class="text-emerald-600 text-sm">Patient</p>
                        </div>
                    </div>
                    <nav class="space-y-1">
                        <a href="<%= ctx%>/patient/dashboard" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-house w-5"></i><span>Home</span></a>
                        <a href="<%= ctx%>/patient/book" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar-check w-5"></i><span>Book Appointment</span></a>
                        <a href="<%= ctx%>/patient/myappointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-list w-5"></i><span>My Appointments</span></a>
                        <a href="<%= ctx%>/patient/queue" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl "><i class="fa-solid fa-users-line w-5"></i><span>Join Queue</span></a>
                        <a href="<%= ctx%>/patient/notifications" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                        <a href="<%= ctx%>/patient/profile" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                    </nav>
                    <div class="mt-auto pt-6 border-t border-white/40">
                        <button onclick="logout()" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-white/70 hover:text-gray-900 transition">
                            <i class="fa-solid fa-right-from-bracket"></i> <span>Log Out</span>
                        </button>
                    </div>
                </div>
            </div>

            <div class="flex-1 flex flex-col min-w-0">
                <header class="glass border-b px-8 py-4 flex justify-between items-center z-10">
                    <div>
                        <h2 class="text-2xl font-semibold">Home</h2>
                        <p class="text-sm text-gray-500 mt-1">Clinic overview for today</p>
                    </div>
                    <span id="current-date" class="text-sm text-gray-500 font-medium"></span>
                </header>
                <div class="flex-1 overflow-auto p-8">
                    <div class="max-w-6xl mx-auto space-y-10">
                        <div class="text-left">
                            <h1 class="text-4xl md:text-5xl font-bold text-gray-800 mb-2">Welcome back, <%= realName%></h1>
                            <p class="text-gray-500 text-lg" id="today-date"></p>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                            <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
                                <div class="absolute top-0 right-0 w-24 h-24 bg-blue-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
                                <div class="relative">
                                    <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-calendar-check text-blue-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Next Appointment</h3></div>
                                    <p class="text-2xl font-bold text-gray-800 mt-2 mb-2">
                                        <%
                                            String nextApptHtml = "No appointments yet";
                                            if (!appointments.isEmpty()) {
                                                Map<String, Object> first = appointments.get(0);
                                                String dateStr = first.get("regDate") != null ? first.get("regDate").toString() : "";
                                                String timeStr = first.get("slotTime") != null ? first.get("slotTime").toString() : "";
                                                nextApptHtml = dateStr + (timeStr.isEmpty() ? "" : " " + timeStr);
                                            }
                                        %>
                                        <%= nextApptHtml%>
                                    </p>
                                    <a href="<%= ctx%>/patient/myappointments" class="text-blue-600 font-medium hover:underline">Manage Appointments</a>
                                </div>
                            </div>
                            <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
                                <div class="absolute top-0 right-0 w-24 h-24 bg-emerald-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
                                <div class="relative">
                                    <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-users-line text-emerald-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Current Queue</h3></div>
                                    <p class="text-4xl font-bold text-emerald-600 mt-2 mb-2"><%= !queueTickets.isEmpty() ? queueTickets.get(0).get("queueNo") : "N/A"%></p>
                                    <a href="<%= ctx%>/patient/queue" class="text-gray-500 hover:underline">View Live Queue</a>
                                </div>
                            </div>
                            <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
                                <div class="absolute top-0 right-0 w-24 h-24 bg-purple-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
                                <div class="relative">
                                    <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-bell text-purple-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Latest Notification</h3></div>
                                    <div class="space-y-3 mt-2 text-base">
                                        <p class="text-emerald-600 font-medium">✓ <%= !notifications.isEmpty() ? notifications.get(0).get("title") : "No new notifications"%></p>
                                        <p class="text-gray-600"><%= !notifications.isEmpty() ? notifications.get(0).get("message") : ""%></p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div>
                            <h2 class="text-2xl font-bold mb-6 text-gray-800">Quick Services</h2>
                            <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                                <a href="<%= ctx%>/patient/book" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-calendar-plus text-blue-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Book Appointment</p></a>
                                <a href="<%= ctx%>/patient/queue" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-ticket text-emerald-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Join Queue</p></a>
                                <a href="<%= ctx%>/patient/myappointments" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-list-check text-purple-600 text-3xl mb-3"></i><p class="font-semibold mt-2">My Appointments</p></a>
                                <a href="<%= ctx%>/patient/profile" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-user-shield text-amber-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Security</p></a>
                            </div>
                        </div>

                        <div class="glass rounded-3xl p-8">
                            <div class="flex items-center justify-between mb-4">
                                <h2 class="text-2xl font-bold text-gray-800">Notifications</h2>
                                <a href="<%= ctx%>/patient/notifications" class="text-sm text-blue-600 font-medium hover:underline">View All</a>
                            </div>
                            <div class="space-y-4">
                                <% if (notifications.isEmpty()) { %>
                                <div class="text-center py-8 text-gray-500"><i class="fa-regular fa-bell-slash text-4xl mb-3"></i><p>No notifications yet</p></div>
                                        <% } else {
                                            int count = Math.min(3, notifications.size());
                                            for (int i = 0; i < count; i++) {
                                                Map<String, Object> n = notifications.get(i);
                                                String type = n.get("type") != null ? n.get("type").toString() : "info";
                                                String typeClass = "success".equals(type) ? "bg-green-100 text-green-700" : ("warning".equals(type) ? "bg-yellow-100 text-yellow-700" : "bg-blue-100 text-blue-700");
                                                String timeStr = "";
                                                if (n.get("time") != null) {
                                                    try {
                                                        timeStr = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format((java.util.Date) n.get("time"));
                                                    } catch (Exception e) {
                                                    }
                                                }
                                        %>
                                <div class="p-4 border rounded-2xl bg-white flex items-start gap-4 shadow-sm">
                                    <div class="w-10 h-10 rounded-full <%= typeClass%> flex items-center justify-center flex-shrink-0"><i class="fa-solid fa-bell"></i></div>
                                    <div class="flex-1">
                                        <div class="flex items-center justify-between gap-4 flex-wrap"><p class="font-semibold text-gray-800"><%= n.get("title")%></p><span class="text-xs text-gray-400 whitespace-nowrap"><%= timeStr%></span></div>
                                        <p class="text-gray-600 mt-1"><%= n.get("message")%></p>
                                    </div>
                                </div>
                                <% }
                            }%>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            document.getElementById('current-date').textContent = new Date().toLocaleDateString('en-US', {
                weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
            });
            document.getElementById('today-date').innerHTML = 'Today is ' + new Date().toLocaleDateString('en-US', {month: 'long', day: 'numeric', year: 'numeric'});

            // ========= 新增：自动检测数据是否为空，若为空则自动刷新一次（解决首次登录数据不显示问题） =========
            (function () {
                let hasAppointments = <%= !appointments.isEmpty()%>;
                let hasQueue = <%= !queueTickets.isEmpty()%>;
                let hasNotifications = <%= !notifications.isEmpty()%>;

                // 如果没有任何数据，且尚未执行过自动重载（通过 sessionStorage 标记）
                if (!hasAppointments && !hasQueue && !hasNotifications && !sessionStorage.getItem('dashboardReloaded')) {
                    sessionStorage.setItem('dashboardReloaded', 'true');
                    setTimeout(function () {
                        location.reload();
                    }, 200);  // 延迟200ms刷新，避免与其他代码冲突
                }
            })();
            // ======================================================================

            function logout() {
                Swal.fire({
                    title: 'Confirm logout?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, log out',
                    cancelButtonText: 'Cancel'
                }).then(r => {
                    if (r.isConfirmed)
                        window.location.href = '<%= ctx%>/login.jsp';
                });
            }
        </script>
    </body>
</html>