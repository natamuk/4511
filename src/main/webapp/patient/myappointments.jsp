<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    if (appointments == null) appointments = new ArrayList<>();
    String realName = (String) session.getAttribute("realName");
    if (realName == null) realName = "Patient";
    String avatar = "https://picsum.photos/200/200?random=1";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Appointments</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.1/build/qrcode.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Noto Sans TC', sans-serif; background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%); }
        .glass { background: rgba(255,255,255,0.85); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.6); }
        .nav-item { transition: transform 0.16s ease-out; cursor: pointer; }
        .nav-item:hover { transform: translateX(6px); background: rgba(59,135,255,0.1); }
        .nav-item.active { background: linear-gradient(90deg, rgba(37,99,235,0.15), rgba(99,102,241,0.15)); color: #1d4ed8; font-weight: 700; box-shadow: inset 4px 0 0 #2563eb; }
        .home-card, .clinic-card { transition: transform 0.2s ease-out, box-shadow 0.2s ease-out; }
        .home-card:hover, .clinic-card:hover { transform: translateY(-4px); box-shadow: 0 10px 25px rgba(0,0,0,0.08); }
        .quick-btn { transition: transform 0.15s ease-out; }
        .quick-btn:hover { transform: scale(1.02); }
        .calendar-day { aspect-ratio: 1/1; }
        .clinic-topbar { height: 8px; }
        .slot-group { border: 1px solid rgba(229,231,235,0.9); border-radius: 1rem; background: rgba(255,255,255,0.72); overflow: hidden; }
        .slot-group summary { padding: 0.9rem 1rem; font-weight: 700; display: flex; justify-content: space-between; cursor: pointer; list-style: none; }
        .slot-grid { padding: 0 1rem 1rem 1rem; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 0.65rem; }
        .slot-btn { padding: 0.85rem 0.9rem; border: 1px solid #dbe4f0; border-radius: 0.9rem; background: white; text-align: left; transition: all 0.15s ease; cursor: pointer; }
        .slot-btn:hover:not(.active) { transform: translateY(-2px); border-color: #93c5fd; }
        .slot-btn.active { background: #2563eb !important; border-color: #2563eb !important; color: white; }
        .slot-btn.active .slot-time, .slot-btn.active .slot-capacity { color: white !important; }
        .slot-time { font-weight: 700; color: #111827; }
        .slot-capacity { font-size: 0.75rem; color: #6b7280; margin-top: 0.2rem; }
        summary::-webkit-details-marker { display: none; }
        button, input { border: none; outline: none; }
        input { border: 1px solid #ddd; }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
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
                <img class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" src="<%= avatar %>" alt="avatar">
                <div>
                    <p class="font-semibold"><%= realName %></p>
                    <p class="text-emerald-600 text-sm">Patient</p>
                </div>
            </div>
            <nav class="space-y-1">
                <a href="<%= ctx %>/patient/dashboard" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-house w-5"></i><span>Home</span></a>
                <a href="<%= ctx %>/patient/book" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar-check w-5"></i><span>Book Appointment</span></a>
                <a href="<%= ctx %>/patient/calendar" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar w-5"></i><span>Appointment Calendar</span></a>
                <a href="<%= ctx %>/patient/myappointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl active"><i class="fa-solid fa-list w-5"></i><span>My Appointments</span></a>
                <a href="<%= ctx %>/patient/queue" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-users-line w-5"></i><span>Join Queue</span></a>
                <a href="<%= ctx %>/patient/notifications" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                <a href="<%= ctx %>/patient/profile" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                <a href="<%= ctx %>/patient/favorites" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-star w-5"></i><span>Favorite Clinics</span></a>
                <a href="<%= ctx %>/patient/record" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-file-medical w-5"></i><span>Medical History</span></a>
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
                <h2 class="text-2xl font-semibold">My Appointments</h2>
                <p class="text-sm text-gray-500 mt-1">Manage bookings</p>
            </div>
            <span id="current-date" class="text-sm text-gray-500 font-medium"></span>
        </header>
        <div class="flex-1 overflow-auto p-8">
            <div class="max-w-5xl mx-auto space-y-6">
                <div class="glass rounded-3xl p-8">
                    <div class="flex items-center justify-between mb-6">
                        <h3 class="text-2xl font-semibold">My Appointments</h3>
                        <a href="<%= ctx %>/patient/book" class="px-4 py-2 bg-blue-600 text-white rounded-xl shadow-sm hover:bg-blue-700 transition">New Booking</a>
                    </div>
                    <div class="space-y-4">
                        <% if (appointments.isEmpty()) { %>
                            <div class="text-center py-16 text-gray-500"><i class="fa-regular fa-calendar-xmark text-5xl mb-4"></i><p class="text-lg">No records found</p></div>
                        <% } else {
                            for (Map<String, Object> item : appointments) {
                                String status = item.get("status") != null ? item.get("status").toString() : "";
                                String statusClass = "";
                                if ("Booked".equals(status)) statusClass = "bg-blue-50 text-blue-700 border-blue-200";
                                else if ("Completed".equals(status)) statusClass = "bg-green-50 text-green-700 border-green-200";
                                else statusClass = "bg-red-50 text-red-700 border-red-200";

                                // 直接获取 slotTime 字符串 (如 "09:00")
                                String timeDisplay = item.get("slotTime") != null ? item.get("slotTime").toString() : "";
                        %>
                            <div class="p-6 border rounded-3xl bg-white flex flex-col md:flex-row md:items-center md:justify-between gap-6 shadow-sm hover:shadow-md transition">
                                <div class="flex-1">
                                    <div class="flex items-center gap-3 mb-2">
                                        <h4 class="font-bold text-xl text-gray-800"><%= item.get("clinicName") != null ? item.get("clinicName") : "Clinic" %></h4>
                                        <span class="px-3 py-1 rounded-full text-xs font-bold border <%= statusClass %>"><%= status %></span>
                                    </div>
                                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-gray-600 mt-3">
                                        <p><i class="fa-regular fa-calendar text-gray-400 w-5"></i> <b>Date:</b> <%= item.get("regDate") != null ? item.get("regDate") : "" %></p>
                                        <p><i class="fa-regular fa-clock text-gray-400 w-5"></i> <b>Time:</b> <%= timeDisplay %></p>
                                        <p><i class="fa-solid fa-user-doctor text-gray-400 w-5"></i> <b>Doctor:</b> <%= item.get("doctorName") != null ? item.get("doctorName") : "Not Assigned" %></p>
                                        <p><i class="fa-solid fa-ticket text-gray-400 w-5"></i> <b>Queue No:</b> <%= item.get("queueNo") != null ? item.get("queueNo") : "-" %></p>
                                    </div>
                                </div>
                                <div class="flex flex-col sm:flex-row gap-3 md:w-auto w-full pt-4 md:pt-0 border-t md:border-t-0 border-gray-100">
                                    <button class="flex-1 px-4 py-2.5 rounded-xl bg-blue-50 hover:bg-blue-100 text-blue-700 font-medium transition" onclick="showQR('<%= item.get("regNo") %>')">
                                        <i class="fa-solid fa-qrcode"></i> QR
                                    </button>
                                    <% if ("Booked".equals(status)) { %>
                                        <form action="<%= ctx %>/patient/cancel-booking" method="post" style="display:inline;" onsubmit="return confirm('Cancel this appointment?')">
                                            <input type="hidden" name="registrationId" value="<%= item.get("id") %>">
                                            <button type="submit" class="flex-1 px-4 py-2.5 rounded-xl bg-red-50 hover:bg-red-100 text-red-600 font-medium transition">
                                                <i class="fa-solid fa-xmark"></i> Cancel
                                            </button>
                                        </form>
                                    <% } %>
                                </div>
                            </div>
                        <% } } %>
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
    function showQR(regNo) {
        Swal.fire({
            title: 'Check-in QR Code',
            html: `<div class="flex flex-col items-center"><canvas id="qrCanvas" class="mt-2 border p-2 rounded"></canvas><p class="font-mono mt-3">\${regNo}</p></div>`,
            didOpen: () => {
                QRCode.toCanvas(document.getElementById('qrCanvas'), regNo, { width: 200, margin: 1 });
            }
        });
    }
    function logout() {
        Swal.fire({
            title: 'Confirm logout?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Yes, log out',
            cancelButtonText: 'Cancel'
        }).then(r => { if (r.isConfirmed) window.location.href = '<%= ctx %>/login.jsp'; });
    }
</script>
</body>
</html>