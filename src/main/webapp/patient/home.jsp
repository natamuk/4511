<%-- 
    Document   : home
    Created on : 2026年3月31日, 22:17:53
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" import="java.util.*, com.mycompany.system.model.LoginUser" %>
<%
    Object userObj = session.getAttribute("loginUser");
    if (userObj == null || !"patient".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (request.getAttribute("clinics") == null) {
        response.sendRedirect(request.getContextPath() + "/patient/dashboard");
        return;
    }

    LoginUser loginUser = (LoginUser) userObj;

    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("patientProfile");
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");
    List<Map<String, Object>> records = (List<Map<String, Object>>) request.getAttribute("records");
    List<Map<String, Object>> clinics = (List<Map<String, Object>>) request.getAttribute("clinics");
    Map<Long, List<Map<String, Object>>> clinicSlots = (Map<Long, List<Map<String, Object>>>) request.getAttribute("clinicSlots");
    List<Map<String, Object>> queue = (List<Map<String, Object>>) request.getAttribute("queue");
    List<Map<String, Object>> favorites = (List<Map<String, Object>>) request.getAttribute("favorites");
    Map<Long, Integer> clinicQueueCount = (Map<Long, Integer>) request.getAttribute("clinicQueueCount");

    if (profile == null) profile = new HashMap<>();
    if (appointments == null) appointments = new ArrayList<>();
    if (notifications == null) notifications = new ArrayList<>();
    if (records == null) records = new ArrayList<>();
    if (clinics == null) clinics = new ArrayList<>();
    if (clinicSlots == null) clinicSlots = new HashMap<>();
    if (queue == null) queue = new ArrayList<>();
    if (favorites == null) favorites = new ArrayList<>();
    if (clinicQueueCount == null) clinicQueueCount = new HashMap<>();

    String realName = profile.get("realName") != null ? String.valueOf(profile.get("realName")) : loginUser.getRealName();
    String avatar = profile.get("avatar") != null ? String.valueOf(profile.get("avatar")) : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Patient Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.1/build/qrcode.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body { font-family: 'Noto Sans TC', sans-serif; background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%); }

        .glass {
            background: rgba(255,255,255,0.85);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,0.6);
            will-change: transform, backdrop-filter;
        }

        .nav-item { transition: transform 0.16s ease-out, background-color 0.16s ease-out, color 0.16s ease-out; cursor: pointer; }
        .nav-item:hover { transform: translateX(6px); background: rgba(59,135,255,0.1); }
        .nav-item.active { background: linear-gradient(90deg, rgba(37,99,235,0.15), rgba(99,102,241,0.15)); color: #1d4ed8; font-weight: 700; box-shadow: inset 4px 0 0 #2563eb; }
        .nav-item.active i { color: #2563eb; }

        .home-card { transition: transform 0.2s ease-out, box-shadow 0.2s ease-out; will-change: transform; }
        .home-card:hover { transform: translateY(-4px); box-shadow: 0 10px 25px rgba(0,0,0,0.08); }

        .quick-btn { transition: transform 0.15s ease-out; will-change: transform; }
        .quick-btn:hover { transform: scale(1.02); }

        .calendar-day { aspect-ratio: 1/1; }

        .clinic-card { transition: transform 0.2s ease-out, box-shadow 0.2s ease-out; will-change: transform; }
        .clinic-card:hover { transform: translateY(-4px); box-shadow: 0 12px 25px rgba(0,0,0,0.08); }
        .clinic-topbar { height: 8px; }

        #main-content {
            opacity: 0;
            transform: translateY(10px);
        }

        .clinic-card-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 1rem; }
        .clinic-name { font-size: 1.5rem; font-weight: 700; line-height: 1.2; color: #111827; }
        .clinic-location { font-size: 0.875rem; color: #6b7280; margin-top: 0.25rem; }
        .clinic-description { font-size: 0.95rem; color: #4b5563; margin-top: 0.75rem; line-height: 1.6; min-height: 3rem; }

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
            align-items: center;
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
            transition: transform 0.15s ease, box-shadow 0.15s ease, border-color 0.15s ease, background-color 0.15s ease;
            cursor: pointer;
        }

        .slot-btn:hover:not(.active) {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            border-color: #93c5fd;
        }

        .slot-btn.active {
            background: #2563eb !important;
            border-color: #2563eb !important;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(37,99,235,0.2);
        }

        .slot-btn.active .slot-time,
        .slot-btn.active .slot-capacity {
            color: white !important;
        }

        .slot-time { font-weight: 700; color: #111827; }
        .slot-capacity { font-size: 0.75rem; color: #6b7280; margin-top: 0.2rem; }

        .clinic-footer { margin-top: 1.25rem; }

        .queue-clinic-card {
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 200px;
            justify-content: space-between;
        }

        .queue-clinic-title {
            height: 3.5rem;
            line-height: 1.35;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .queue-clinic-meta {
            min-height: 1.5rem;
        }

        .queue-clinic-btn { margin-top: auto; }

        @media print {
            * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
        }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
    <div id="sidebar" class="w-72 glass shadow-2xl flex flex-col border-r border-white/50 z-40">
        <div class="p-6 bg-gradient-to-r from-blue-700 to-indigo-700 text-white">
            <div class="flex items-center gap-3">
                <i class="fa-solid fa-clinic-medical text-4xl"></i>
                <div>
                    <h1 class="text-2xl font-bold">CCHC</h1>
                    <p class="text-sm opacity-90">Community Clinic Appointment System</p>
                </div>
            </div>
        </div>

        <div class="p-6 flex-1 flex flex-col">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img id="sidebar-avatar" src="<%= (avatar != null && !avatar.isEmpty()) ? avatar : "https://picsum.photos/200/200?random=1" %>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                <div>
                    <p class="font-semibold" id="sidebar-name"><%= realName %></p>
                    <p class="text-emerald-600 text-sm">Patient</p>
                </div>
            </div>

            <nav class="space-y-1" id="nav"></nav>

            <div class="mt-auto pt-6 border-t border-white/40">
                <button onclick="logout()" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-white/70 hover:text-gray-900 transition">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    <span>Log Out</span>
                </button>
            </div>
        </div>
    </div>

    <div class="flex-1 flex flex-col min-w-0">
        <header class="glass border-b px-8 py-4 flex justify-between items-center z-10 relative">
            <div>
                <h2 id="page-title" class="text-2xl font-semibold">Home</h2>
                <p class="text-sm text-gray-500 mt-1" id="page-subtitle">Clinic overview for today</p>
            </div>
            <div class="flex items-center gap-3">
                <span id="current-date" class="text-sm text-gray-500 font-medium"></span>
            </div>
        </header>
        <div class="flex-1 overflow-auto p-8" id="main-content"></div>
    </div>
</div>

<script>
const appointments = <%= new com.google.gson.Gson().toJson(appointments) %>;
const notifications = <%= new com.google.gson.Gson().toJson(notifications) %>;
const records = <%= new com.google.gson.Gson().toJson(records) %>;
const clinics = <%= new com.google.gson.Gson().toJson(clinics) %>;
const clinicSlots = <%= new com.google.gson.Gson().toJson(clinicSlots) %>;
const queue = <%= new com.google.gson.Gson().toJson(queue) %>;
const favorites = <%= new com.google.gson.Gson().toJson(favorites) %>;
const profile = <%= new com.google.gson.Gson().toJson(profile) %>;
const clinicQueueCount = <%= new com.google.gson.Gson().toJson(clinicQueueCount) %>;

let currentActiveNav = null;
let currentPage = '';
let isRenderingPage = false;
let bookPageHtml = '';
let bookPageBuilt = false;

function updateDate() {
    document.getElementById('current-date').textContent = new Date().toLocaleDateString('en-US', {
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
    });
}

function loadSidebar() {
    document.getElementById('sidebar-avatar').src = profile.avatar || '<%= (avatar != null && !avatar.isEmpty()) ? avatar : "https://picsum.photos/200/200?random=1" %>';
    document.getElementById('sidebar-name').textContent = '<%= realName.replace("\\", "\\\\").replace("\"", "\\\"") %>';

    const unreadCount = notifications.filter(n => !n.read).length;
    const badge = unreadCount > 0 ? `<span class="bg-red-500 text-white text-[10px] w-5 h-5 flex items-center justify-center rounded-full ml-auto">${unreadCount}</span>` : '';

    const nav = document.getElementById('nav');
    nav.innerHTML = `
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="home"><i class="fa-solid fa-house w-5"></i><span>Home</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="book"><i class="fa-solid fa-calendar-check w-5"></i><span>Book Appointment</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="calendar"><i class="fa-solid fa-calendar w-5"></i><span>Appointment Calendar</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="my"><i class="fa-solid fa-list w-5"></i><span>My Appointments</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="queue"><i class="fa-solid fa-users-line w-5"></i><span>Join Queue</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="notifications"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span>${badge}</div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="profile"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="favorites"><i class="fa-solid fa-star w-5"></i><span>Favorite Clinics</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="record"><i class="fa-solid fa-file-medical w-5"></i><span>Medical History</span></div>
    `;

    if (!nav.dataset.bound) {
        nav.addEventListener('click', (e) => {
            const item = e.target.closest('.nav-item');
            if (!item) return;
            const page = item.dataset.page;
            if (page) loadPage(page);
        });
        nav.dataset.bound = '1';
    }
}

function setActiveNav(page) {
    const next = document.querySelector(`.nav-item[data-page="${page}"]`);
    if (currentActiveNav === next) return;
    if (currentActiveNav) currentActiveNav.classList.remove('active');
    if (next) next.classList.add('active');
    currentActiveNav = next;
}

function logout() {
    Swal.fire({
        title: 'Log out?',
        text: 'You will leave the patient portal.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Log Out',
        cancelButtonText: 'Cancel'
    }).then(r => { if (r.isConfirmed) window.location.href = '<%= request.getContextPath() %>/logout'; });
}

function openNotification(id) {
    const item = notifications.find(x => x.id === id);
    if (!item) return;
    item.read = true;
    Swal.fire({ title: item.title, text: item.message, icon: 'info' });
    loadPage('notifications');
}

function markAllRead() {
    notifications.forEach(n => n.read = true);
    Swal.fire('Success', 'All notifications were marked as read.', 'success');
    loadPage('notifications');
}

function parseErrorMessage(resp, fallbackMsg) {
    return resp.text().then(text => {
        if (resp.ok) return { ok: true, text };
        let message = fallbackMsg || 'Request failed';
        try {
            const obj = JSON.parse(text);
            message = obj.message || message;
        } catch (_) {
            message = text || message;
        }
        return { ok: false, message, text };
    });
}

function joinQueueByClinic(clinicId, clinicName) {
    fetch('<%= request.getContextPath() %>/patient/queue/join', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ clinicId: clinicId })
    })
    .then(resp => parseErrorMessage(resp, 'Join queue failed'))
    .then(result => {
        if (!result.ok) throw new Error(result.message);
        Swal.fire('Success', `Successfully joined queue for ${clinicName}`, 'success');
        window.location.href = '<%= request.getContextPath() %>/patient/dashboard';
    })
    .catch(err => {
        console.error(err);
        Swal.fire('Error', err.message || 'Join queue failed', 'error');
    });
}

function loadPage(page) {
    if (isRenderingPage) return;
    if (currentPage === page) {
        setActiveNav(page);
        return;
    }

    isRenderingPage = true;
    currentPage = page;

    const c = document.getElementById('main-content');
    setActiveNav(page);
    c.style.transition = 'none';
    c.style.opacity = '0';
    c.style.transform = 'translateY(10px)';

    setTimeout(() => {
        requestAnimationFrame(() => {
            try {
                if (page === 'home') {
                    const nextApp = appointments[0];
                    const nextQueue = queue[0];
                    document.getElementById('page-title').textContent = 'Home';
                    document.getElementById('page-subtitle').textContent = 'Clinic overview for today';
                    c.innerHTML = `
                        <div class="max-w-6xl mx-auto space-y-10">
                            <div class="text-left">
                                <h1 class="text-4xl md:text-5xl font-bold text-gray-800 mb-2">Welcome back, <%= realName %></h1>
                                <p class="text-gray-500 text-lg">Today is ${new Date().toLocaleDateString('en-US')}</p>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                                <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
                                    <div class="absolute top-0 right-0 w-24 h-24 bg-blue-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
                                    <div class="relative">
                                        <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-calendar-check text-blue-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Next Appointment</h3></div>
                                        <p class="text-2xl font-bold text-gray-800 mt-2 mb-2">${nextApp ? nextApp.date + ' ' + (nextApp.timeSlot || '') : 'No appointments yet'}</p>
                                        <p onclick="loadPage('my')" class="text-blue-600 font-medium cursor-pointer hover:underline">Manage Appointments</p>
                                    </div>
                                </div>
                                <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
                                    <div class="absolute top-0 right-0 w-24 h-24 bg-emerald-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
                                    <div class="relative">
                                        <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-users-line text-emerald-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Current Queue</h3></div>
                                        <p class="text-4xl font-bold text-emerald-600 mt-2 mb-2">${nextQueue ? nextQueue.queueNo : 'N/A'}</p>
                                        <p onclick="loadPage('queue')" class="text-gray-500 cursor-pointer hover:underline">View Live Queue</p>
                                    </div>
                                </div>
                                <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
                                    <div class="absolute top-0 right-0 w-24 h-24 bg-purple-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
                                    <div class="relative">
                                        <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-bell text-purple-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Latest Notification</h3></div>
                                        <div class="space-y-3 mt-2 text-base">
                                            <p class="text-emerald-600 font-medium">✓ System is operating normally</p>
                                            <p class="text-gray-600">${notifications[0] ? notifications[0].title : 'No notifications yet'}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div>
                                <h2 class="text-2xl font-bold mb-6 text-gray-800">Quick Services</h2>
                                <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                                    <div onclick="loadPage('book')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-calendar-plus text-blue-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Book Appointment</p></div>
                                    <div onclick="loadPage('queue')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-ticket text-emerald-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Join Queue</p></div>
                                    <div onclick="loadPage('my')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-list-check text-purple-600 text-3xl mb-3"></i><p class="font-semibold mt-2">My Appointments</p></div>
                                    <div onclick="loadPage('profile')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-user-shield text-amber-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Security</p></div>
                                </div>
                            </div>

                            <div class="glass rounded-3xl p-8">
                                <div class="flex items-center justify-between mb-4">
                                    <h2 class="text-2xl font-bold text-gray-800">Notifications</h2>
                                    <button onclick="loadPage('notifications')" class="text-sm text-blue-600 font-medium hover:underline">View All</button>
                                </div>
                                <div class="space-y-4">
                                    ${notifications.length ? notifications.slice(0, 3).map(n => `
                                        <div class="p-4 border rounded-2xl bg-white flex items-start gap-4 shadow-sm">
                                            <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${n.type === 'success' ? 'bg-green-100 text-green-700' : n.type === 'warning' ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700'}">
                                                <i class="fa-solid fa-bell"></i>
                                            </div>
                                            <div class="flex-1">
                                                <div class="flex items-center justify-between gap-4">
                                                    <p class="font-semibold text-gray-800">${n.title}</p>
                                                    <span class="text-xs text-gray-400 whitespace-nowrap">${n.time || ''}</span>
                                                </div>
                                                <p class="text-gray-600 mt-1">${n.message}</p>
                                            </div>
                                        </div>
                                    `).join('') : `
                                        <div class="text-center py-8 text-gray-500">
                                            <i class="fa-regular fa-bell-slash text-4xl mb-3"></i>
                                            <p>No notifications yet</p>
                                        </div>
                                    `}
                                </div>
                            </div>
                        </div>
                    `;
                }
                else if (page === 'book') {
                    document.getElementById('page-title').textContent = 'Book Appointment';
                    document.getElementById('page-subtitle').textContent = 'Choose a clinic and time slot';
                    if (!bookPageBuilt || !bookPageHtml) {
                        c.innerHTML = `
                            <div class="max-w-7xl mx-auto">
                                <h2 class="text-3xl font-bold mb-2">Book Appointment</h2>
                                <p class="text-gray-600 mb-10">Choose your clinic, date and available time slot</p>
                                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8" id="clinic"></div>
                            </div>
                        `;
                        renderClinics();
                        bookPageHtml = c.innerHTML;
                        bookPageBuilt = true;
                    } else {
                        c.innerHTML = bookPageHtml;
                    }
                }
                else if (page === 'calendar') {
                    document.getElementById('page-title').textContent = 'Appointment Calendar';
                    document.getElementById('page-subtitle').textContent = 'View your booked dates';
                    c.innerHTML = `
                        <div class="glass p-8 rounded-3xl max-w-4xl mx-auto">
                            <h3 class="text-2xl font-bold mb-6">Appointment Calendar</h3>
                            <div class="grid grid-cols-7 gap-2 text-center mb-4 font-semibold">
                                <div>Sun</div><div>Mon</div><div>Tue</div><div>Wed</div><div>Thu</div><div>Fri</div><div>Sat</div>
                            </div>
                            <div class="grid grid-cols-7 gap-2">
                                ${Array.from({ length: 30 }, (_, i) => {
                                    const d = i + 1;
                                    const has = appointments.some(x => Number(String(x.date).split('-')[2]) === d);
                                    return `<div class="calendar-day p-2 border rounded-lg flex items-center justify-center font-medium ${has ? 'bg-blue-100 text-blue-700 border-blue-300 shadow-sm' : 'text-gray-600 bg-white'}">${d}</div>`;
                                }).join('')}
                            </div>
                            <p class="mt-6 text-sm text-gray-500"><span class="inline-block w-3 h-3 bg-blue-100 border border-blue-300 mr-1"></span> Blue dates indicate scheduled appointments.</p>
                        </div>
                    `;
                }
                else if (page === 'my') {
                    document.getElementById('page-title').textContent = 'My Appointments';
                    document.getElementById('page-subtitle').textContent = 'Manage your booking records';
                    c.innerHTML = `
                        <div class="max-w-5xl mx-auto space-y-6">
                            <div class="glass rounded-3xl p-8">
                                <div class="flex items-center justify-between mb-6">
                                    <h3 class="text-2xl font-semibold">My Appointments</h3>
                                    <button onclick="loadPage('book')" class="px-4 py-2 bg-blue-600 text-white rounded-xl shadow-sm hover:bg-blue-700 transition">New Booking</button>
                                </div>
                                <div id="my-list" class="space-y-4"></div>
                            </div>
                        </div>
                    `;
                    renderMyAppointments();
                }
                else if (page === 'queue') {
                    document.getElementById('page-title').textContent = 'Walk-in Queue';
                    document.getElementById('page-subtitle').textContent = 'Same-day queue and calling status';

                    const queueEnabledIds = [1, 2, 3];
                    const queueClinics = clinics
                        .filter(cn => queueEnabledIds.includes(Number(cn.id)))
                        .map(cn => ({
                            ...cn,
                            waitingCount: Number((clinicQueueCount && (clinicQueueCount[cn.id] || clinicQueueCount[String(cn.id)])) || 0)
                        }));

                    c.innerHTML = `
                        <div class="max-w-5xl mx-auto space-y-6">
                            <div class="glass rounded-3xl p-8">
                                <h2 class="text-3xl font-bold mb-4">Join Walk-in Queue</h2>
                                <p class="text-gray-600 mb-8">Select a clinic and join queue instantly for today's walk-in service.</p>

                                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                    ${queueClinics.map(item => `
                                        <div class="p-5 border rounded-2xl bg-white shadow-sm hover:shadow-md transition queue-clinic-card">
                                            <p class="font-semibold text-lg leading-snug queue-clinic-title">${item.name}</p>
                                            <p class="text-sm text-gray-500 mt-2 queue-clinic-meta"><i class="fa-solid fa-users mr-1"></i> Current waiting: <span class="font-bold text-gray-800">${item.waitingCount}</span></p>
                                            <button
                                                onclick="joinQueueByClinic(${item.id}, '${String(item.name).replace(/'/g, "\\'")}')"
                                                class="w-full px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-medium transition queue-clinic-btn"
                                            >
                                                Join Queue
                                            </button>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>

                            <div class="glass rounded-3xl p-8">
                                <div class="flex items-center justify-between mb-6">
                                    <h3 class="text-2xl font-semibold">My Queue Status</h3>
                                    <button onclick="loadPage('queue')" class="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-xl transition"><i class="fa-solid fa-rotate-right mr-1"></i> Refresh</button>
                                </div>
                                <div class="space-y-4">
                                    ${queue.length ? queue.map(item => `
                                        <div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm">
                                            <div>
                                                <p class="font-semibold text-lg text-gray-800">${item.clinicName || 'Clinic'}</p>
                                                <p class="text-sm text-gray-500 mt-1">Ticket Number: <span class="font-mono font-bold text-lg text-indigo-600">${item.queueNo || '-'}</span></p>
                                                <p class="text-xs text-gray-400 mt-1">Joined at: ${item.createdTime || ''}</p>
                                            </div>
                                            <span class="px-4 py-2 rounded-full text-sm font-bold ${
                                                item.status === 'waiting' ? 'bg-yellow-100 text-yellow-700 border border-yellow-200'
                                                : item.status === 'called' ? 'bg-blue-100 text-blue-700 border border-blue-200 animate-pulse'
                                                : item.status === 'skipped' ? 'bg-red-100 text-red-700 border border-red-200'
                                                : 'bg-green-100 text-green-700 border border-green-200'
                                            }">${item.status.toUpperCase()}</span>
                                        </div>
                                    `).join('') : '<div class="text-center py-10 text-gray-500"><i class="fa-solid fa-users-slash text-4xl mb-3"></i><p>You have not joined any queue today.</p></div>'}
                                </div>
                            </div>
                        </div>
                    `;
                }
                else if (page === 'notifications') {
                    document.getElementById('page-title').textContent = 'Notifications';
                    document.getElementById('page-subtitle').textContent = 'Your personal reminders and updates';
                    c.innerHTML = `
                        <div class="max-w-4xl mx-auto glass rounded-3xl p-8 relative">
                            <div class="flex items-center justify-between mb-6">
                                <h3 class="text-2xl font-semibold">Notification List</h3>
                                <button onclick="markAllRead()" class="text-sm px-4 py-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition">
                                    <i class="fa-solid fa-check-double mr-1"></i> Mark All as Read
                                </button>
                            </div>
                            <div class="space-y-4">
                                ${notifications.length ? notifications.map(n => `
                                    <div class="p-4 border rounded-2xl bg-white flex items-start gap-4 cursor-pointer hover:shadow-md transition-shadow ${n.read ? 'opacity-60' : ''}" onclick="openNotification(${n.id})">
                                        <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${n.type === 'success' ? 'bg-green-100 text-green-700' : n.type === 'warning' ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700'}">
                                            <i class="fa-solid fa-bell"></i>
                                        </div>
                                        <div class="flex-1">
                                            <div class="flex items-center justify-between gap-4">
                                                <p class="font-semibold flex items-center gap-2 text-gray-800">
                                                    ${n.title}
                                                    ${n.read ? '' : '<span class="w-2 h-2 rounded-full bg-red-500 inline-block animate-pulse"></span>'}
                                                </p>
                                                <span class="text-xs text-gray-400 whitespace-nowrap">${n.time || ''}</span>
                                            </div>
                                            <p class="text-gray-600 mt-1">${n.message}</p>
                                        </div>
                                    </div>
                                `).join('') : '<div class="text-center py-12 text-gray-500"><i class="fa-regular fa-bell-slash text-4xl mb-3"></i><p>No new notifications.</p></div>'}
                            </div>
                        </div>
                    `;
                }
                else if (page === 'profile') {
                    document.getElementById('page-title').textContent = 'Profile & Security';
                    document.getElementById('page-subtitle').textContent = 'Manage personal info and change password';
                    const p = profile;
                    c.innerHTML = `
                        <div class="max-w-4xl mx-auto space-y-6">
                            <div class="glass rounded-3xl p-8">
                                <h3 class="text-2xl font-semibold mb-6 border-b pb-3">Personal Information</h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div class="md:col-span-2">
                                        <label class="text-sm text-gray-700 font-semibold mb-2 flex items-center gap-2">
                                            Profile Avatar
                                            <span class="text-red-500 text-xs font-normal bg-red-50 px-2 py-1 rounded-md">JPG/PNG only</span>
                                        </label>
                                        <input id="avatar-upload" type="file" accept="image/jpeg, image/png" class="w-full p-3 border rounded-xl bg-white cursor-pointer hover:bg-gray-50 transition">
                                    </div>
                                    <div class="md:col-span-2 flex items-center gap-4 mb-2">
                                        <img id="avatar-preview" src="${p.avatar || 'https://picsum.photos/200/200?random=1'}" class="w-20 h-20 rounded-2xl object-cover ring-4 ring-gray-100 shadow-sm" alt="avatar preview">
                                        <p class="text-sm text-gray-500">Image previews immediately after selection.</p>
                                    </div>
                                    <div><label class="block text-sm text-gray-700 font-medium mb-1">Full Name</label><input id="pf-name" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="${p.realName || ''}"></div>
                                    <div><label class="block text-sm text-gray-700 font-medium mb-1">Phone Number</label><input id="pf-phone" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="${p.phone || ''}"></div>
                                    <div><label class="block text-sm text-gray-700 font-medium mb-1">Email Address</label><input id="pf-email" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="${p.email || ''}"></div>
                                    <div><label class="block text-sm text-gray-700 font-medium mb-1">Home Address</label><input id="pf-address" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="${p.address || ''}"></div>
                                </div>
                            </div>

                            <div class="glass rounded-3xl p-8">
                                <h3 class="text-2xl font-semibold mb-6 border-b pb-3 text-gray-800"><i class="fa-solid fa-lock text-gray-400 mr-2"></i>Change Password</h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div class="md:col-span-2">
                                        <label class="block text-sm text-gray-700 font-medium mb-1">Current Password</label>
                                        <input type="password" id="pf-old-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Leave blank if not changing">
                                    </div>
                                    <div>
                                        <label class="block text-sm text-gray-700 font-medium mb-1">New Password</label>
                                        <input type="password" id="pf-new-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Enter new password">
                                    </div>
                                    <div>
                                        <label class="block text-sm text-gray-700 font-medium mb-1">Confirm New Password</label>
                                        <input type="password" id="pf-conf-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Re-enter new password">
                                    </div>
                                </div>
                            </div>

                            <div class="flex gap-4 pt-2">
                                <button onclick="saveProfileFromPage()" class="px-8 py-3 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 shadow-sm transition">Save All Changes</button>
                                <button onclick="loadPage('home')" class="px-8 py-3 bg-gray-200 text-gray-700 font-medium rounded-xl hover:bg-gray-300 transition">Cancel</button>
                            </div>
                        </div>
                    `;
                    const avatarUpload = document.getElementById('avatar-upload');
                    avatarUpload.addEventListener('change', function () {
                        const file = this.files[0];
                        if (!file) return;
                        if (file.type !== 'image/jpeg' && file.type !== 'image/png') {
                            Swal.fire({ title: 'Invalid format', text: 'Only JPG or PNG images are allowed.', icon: 'error', confirmButtonText: 'OK' });
                            this.value = '';
                            return;
                        }
                        const reader = new FileReader();
                        reader.onload = () => {
                            document.getElementById('avatar-preview').src = reader.result;
                            profile.avatar = reader.result;
                        };
                        reader.readAsDataURL(file);
                    });
                }
                else if (page === 'favorites') {
                    document.getElementById('page-title').textContent = 'Favorite Clinics';
                    document.getElementById('page-subtitle').textContent = 'Your saved clinics';
                    const list = clinics.filter(cn => favorites.some(f => f.clinicName === cn.name || f === cn.name));
                    c.innerHTML = `
                        <div class="glass p-8 rounded-3xl max-w-4xl mx-auto">
                            <h3 class="text-2xl font-bold mb-6 border-b pb-3">Saved Clinics</h3>
                            <div class="space-y-4">
                            ${list.length ? list.map(x => `
                                <div class="p-5 border rounded-2xl bg-white flex justify-between items-center shadow-sm hover:shadow-md transition">
                                    <div>
                                        <p class="font-semibold text-lg text-gray-800">${x.name}</p>
                                        <p class="text-sm text-gray-500 mt-1"><i class="fa-solid fa-location-dot mr-1"></i> ${x.location || x.description || ''}</p>
                                    </div>
                                    <div class="flex gap-3">
                                        <button onclick="loadPage('book')" class="px-4 py-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition font-medium">Book</button>
                                        <button onclick="toggleFavorite('${x.name}');loadPage('favorites')" class="px-4 py-2 bg-red-50 text-red-500 rounded-xl hover:bg-red-100 transition font-medium"><i class="fa-solid fa-heart"></i></button>
                                    </div>
                                </div>
                            `).join('') : '<div class="text-center py-12 text-gray-500"><i class="fa-regular fa-heart text-4xl mb-3"></i><p>No favorite clinics added yet.</p></div>'}
                            </div>
                        </div>
                    `;
                }
                else if (page === 'record') {
                    document.getElementById('page-title').textContent = 'Medical History';
                    document.getElementById('page-subtitle').textContent = 'Your past consultation records';
                    c.innerHTML = `
                        <div class="glass rounded-3xl p-8 max-w-5xl mx-auto">
                            <h3 class="text-2xl font-semibold mb-6 border-b pb-3">Consultation History</h3>
                            <div class="space-y-4">
                                ${records.length ? records.map(h => `
                                    <div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row justify-between md:items-center gap-4 shadow-sm hover:shadow-md transition">
                                        <div class="flex-1">
                                            <div class="flex items-center gap-3 mb-2">
                                                <p class="font-bold text-lg text-gray-800">${h.departmentName || 'General'}</p>
                                                <span class="px-3 py-1 rounded-full text-xs font-bold bg-green-100 text-green-700 border border-green-200">Completed</span>
                                            </div>
                                            <p class="text-sm text-gray-600 font-medium"><i class="fa-regular fa-calendar mr-1"></i> ${h.consultationTime || ''} ｜ <i class="fa-solid fa-user-doctor mr-1"></i> ${h.doctorName || '-'}</p>
                                            <div class="mt-3 p-3 bg-gray-50 rounded-xl border border-gray-100">
                                                <p class="text-sm text-gray-700"><b>Diagnosis:</b> ${h.diagnosis || 'None recorded'}</p>
                                                <p class="text-sm text-gray-700 mt-1"><b>Advice:</b> ${h.medicalAdvice || 'Rest well'}</p>
                                            </div>
                                        </div>
                                    </div>
                                `).join('') : '<div class="text-center py-12 text-gray-500"><i class="fa-solid fa-notes-medical text-4xl mb-3"></i><p>No past medical history found.</p></div>'}
                            </div>
                        </div>
                    `;
                }

                requestAnimationFrame(() => {
                    c.style.transition = 'opacity 0.2s ease-out, transform 0.2s ease-out';
                    c.style.opacity = '1';
                    c.style.transform = 'translateY(0)';
                });
            } catch (e) {
                console.error('loadPage error:', e);
            } finally {
                isRenderingPage = false;
            }
        });
    }, 20);
}

function saveProfileFromPage() {
    const newPwd = document.getElementById('pf-new-pwd')?.value;
    const confPwd = document.getElementById('pf-conf-pwd')?.value;
    if(newPwd && newPwd !== confPwd) {
        Swal.fire('Error', 'New passwords do not match!', 'error');
        return;
    }

    const name = document.getElementById('pf-name').value;
    const phone = document.getElementById('pf-phone').value;
    const email = document.getElementById('pf-email').value;
    const address = document.getElementById('pf-address').value;
    const oldPwd = document.getElementById('pf-old-pwd')?.value || '';

    fetch('<%= request.getContextPath() %>/patient/update-profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ realName: name, phone: phone, email: email, address: address, newPwd: newPwd || '', oldPwd: oldPwd })
    })
    .then(resp => parseErrorMessage(resp, 'Failed to update profile'))
    .then(result => {
        if (!result.ok) throw new Error(result.message);
        Swal.fire('Success', 'Profile & security settings updated successfully.', 'success');
    })
    .catch(err => {
        Swal.fire('Error', err.message || 'Failed to update profile', 'error');
    });
}

function toggleFavorite(name) {
    fetch('<%= request.getContextPath() %>/patient/toggle-favorite', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ clinicName: name })
    })
    .then(resp => parseErrorMessage(resp, 'Failed to toggle favorite'))
    .then(result => {
        if (!result.ok) throw new Error(result.message);
        Swal.fire('Success', 'Favorite list updated.', 'success').then(() => {
            window.location.reload();
        });
    })
    .catch(err => {
        Swal.fire('Error', err.message || 'Failed to update favorite list', 'error');
    });
}

function renderClinics() {
    const container = document.getElementById('clinic');
    if (!container) return;

    container.innerHTML = clinics.map(clinic => {
        const slots = clinicSlots[String(clinic.id)] || clinicSlots[clinic.id] || [];
        const grouped = {
            morning: slots.filter(s => s.period === 'morning'),
            afternoon: slots.filter(s => s.period === 'afternoon'),
            evening: slots.filter(s => s.period === 'evening')
        };

        const periodLabel = { morning: 'Morning', afternoon: 'Afternoon', evening: 'Evening' };

        const renderSlotGroup = (period, open = false) => {
            const items = grouped[period];
            const hasItems = items.length > 0;

            return `
                <details class="slot-group group ${hasItems ? '' : 'opacity-60'}" ${open ? 'open' : ''}>
                    <summary class="${hasItems ? 'bg-blue-50 text-blue-800' : 'bg-gray-100 text-gray-400'} hover:bg-blue-100 transition">
                        <span>${periodLabel[period]}</span>
                        <i class="fa-solid fa-chevron-down text-xs transition-transform group-open:rotate-180"></i>
                    </summary>
                    <div class="slot-grid min-h-[120px] pt-3 ${hasItems ? '' : 'bg-gray-50'}">
                        ${hasItems ? items.map(s => `
                            <button type="button" class="slot-btn" data-slot="${s.slotTime}" onclick="window.selectSlot(${clinic.id}, '${s.slotTime}', this)">
                                <div class="slot-time">${s.slotTime}</div>
                                <div class="slot-capacity">Capacity: ${s.capacity || 5}</div>
                            </button>
                        `).join('') : `<div class="col-span-2 flex items-center justify-center text-sm text-gray-400 min-h-[100px] border border-dashed border-gray-200 rounded-xl bg-white">Not available</div>`}
                    </div>
                </details>
            `;
        };

        return `
            <div class="clinic-card glass rounded-3xl overflow-hidden border flex flex-col h-full shadow-sm hover:shadow-xl">
                <div class="clinic-topbar bg-gradient-to-r from-blue-500 to-indigo-500"></div>
                <div class="p-8 flex flex-col h-full">
                    <div class="clinic-card-header">
                        <div>
                            <div class="clinic-name text-xl">${clinic.clinic_name || clinic.name}</div>
                            <div class="clinic-location"><i class="fa-solid fa-location-dot mr-1"></i> ${clinic.location || ''}</div>
                        </div>
                    </div>

                    <div class="clinic-description text-sm">
                        ${clinic.description || 'General clinic services provided.'}
                    </div>

                    <div class="mt-6">
                        <label class="block text-sm font-bold text-gray-700 mb-2">Select Booking Date</label>
                        <input
                            type="date"
                            class="w-full p-3 border border-gray-300 rounded-xl bg-white outline-none focus:ring-2 focus:ring-blue-500 transition shadow-sm"
                            id="booking-date-${clinic.id}"
                        >
                    </div>

                    <div class="mt-6 space-y-3 flex-1">
                        ${renderSlotGroup('morning', true)}
                        ${renderSlotGroup('afternoon', false)}
                        ${renderSlotGroup('evening', false)}
                    </div>

                    <input type="hidden" id="selected-slot-${clinic.id}" value="">

                    <div class="clinic-footer mt-8">
                        <button onclick="submitBooking(${clinic.id}, '${clinic.clinic_name || clinic.name}')" class="w-full py-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-2xl font-bold shadow-md transition transform hover:-translate-y-1">
                            Confirm & Book Now
                        </button>
                    </div>
                </div>
            </div>
        `;
    }).join('');

    clinics.forEach(clinic => {
        const input = document.getElementById(`booking-date-${clinic.id}`);
        if (!input) return;
        const today = new Date();
        input.min = today.toISOString().split('T')[0];
        const maxDate = new Date();
        maxDate.setDate(maxDate.getDate() + 30);
        input.max = maxDate.toISOString().split('T')[0];
        input.value = today.toISOString().split('T')[0];
    });
}

window.selectSlot = function(clinicId, slotTime, button) {
    const inputEle = document.getElementById(`selected-slot-${clinicId}`);
    if (inputEle) {
        inputEle.value = slotTime;
    } else {
        console.error('Cannot find input for clinic:', clinicId);
    }

    const card = button.closest('.clinic-card');
    if (card) {
        card.querySelectorAll('.slot-btn').forEach(btn => btn.classList.remove('active'));
    } else {
        document.querySelectorAll('.slot-btn').forEach(btn => btn.classList.remove('active'));
    }

    button.classList.add('active');
};

function submitBooking(clinicId, clinicName) {
    const dateInput = document.getElementById(`booking-date-${clinicId}`);
    const slotInput = document.getElementById(`selected-slot-${clinicId}`);
    const bookingDate = dateInput ? dateInput.value : '';
    const selectedTime = slotInput ? slotInput.value : '';

    if (!bookingDate) {
        Swal.fire('Warning', 'Please choose a booking date.', 'warning');
        return;
    }

    if (!selectedTime) {
        Swal.fire('Warning', 'Please select a specific time slot.', 'warning');
        return;
    }

    Swal.fire({
        title: 'Processing Booking...',
        text: 'Please wait while we secure your slot.',
        allowOutsideClick: false,
        didOpen: () => { Swal.showLoading(); }
    });

    fetch('<%= request.getContextPath() %>/patient/book', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            clinicId: clinicId,
            regDate: bookingDate,
            slotTime: selectedTime
        })
    })
    .then(resp => parseErrorMessage(resp, 'Booking failed'))
    .then(result => {
        if (!result.ok) throw new Error(result.message);
        bookPageBuilt = false;
        bookPageHtml = '';
        Swal.fire('Success!', 'Your appointment has been successfully booked.', 'success').then(() => {
            window.location.href = '<%= request.getContextPath() %>/patient/dashboard';
        });
    })
    .catch(err => {
        console.error(err);
        Swal.fire('Booking Failed', err.message || 'An error occurred while booking.', 'error');
    });
}

function renderMyAppointments() {
    const container = document.getElementById('my-list');
    if (!container) return;
    container.innerHTML = appointments.length ? appointments.map(item => `
        <div class="p-6 border rounded-3xl bg-white flex flex-col md:flex-row md:items-center md:justify-between gap-6 shadow-sm hover:shadow-md transition">
            <div class="flex-1">
                <div class="flex items-center gap-3 mb-2">
                    <h4 class="font-bold text-xl text-gray-800">${item.departmentName || item.clinicName || 'Clinic Appointment'}</h4>
                    <span class="px-3 py-1 rounded-full text-xs font-bold border ${item.status === 'Booked' ? 'bg-blue-50 text-blue-700 border-blue-200' : item.status === 'Completed' ? 'bg-green-50 text-green-700 border-green-200' : 'bg-red-50 text-red-700 border-red-200'}">${item.status}</span>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-gray-600 mt-3">
                    <p><i class="fa-regular fa-calendar text-gray-400 w-5"></i> <b>Date:</b> ${item.date || ''}</p>
                    <p><i class="fa-regular fa-clock text-gray-400 w-5"></i> <b>Time:</b> ${item.timeSlot || item.time || '-'}</p>
                    <p><i class="fa-solid fa-user-doctor text-gray-400 w-5"></i> <b>Doctor:</b> ${item.doctorName || 'Not Assigned'}</p>
                    <p><i class="fa-solid fa-ticket text-gray-400 w-5"></i> <b>Queue No:</b> ${item.queueNo || '-'}</p>
                </div>
            </div>
            <div class="flex flex-col sm:flex-row gap-3 md:w-auto w-full pt-4 md:pt-0 border-t md:border-t-0 border-gray-100">
                <button onclick="showAppointmentQR(${JSON.stringify(item).replace(/"/g, '&quot;')})" class="flex-1 px-4 py-2.5 rounded-xl bg-blue-50 hover:bg-blue-100 text-blue-700 font-medium transition flex items-center justify-center gap-2"><i class="fa-solid fa-qrcode"></i> QR</button>
                ${item.status === 'Booked' ? `
                    <button onclick="editBooking(${item.id}, '${item.date}', '${item.timeSlot || ''}')" class="flex-1 px-4 py-2.5 rounded-xl bg-amber-50 hover:bg-amber-100 text-amber-700 font-medium transition flex items-center justify-center gap-2"><i class="fa-regular fa-pen-to-square"></i> Reschedule</button>
                    <button onclick="cancelAppointmentById(${item.id})" class="flex-1 px-4 py-2.5 rounded-xl bg-red-50 hover:bg-red-100 text-red-600 font-medium transition flex items-center justify-center gap-2"><i class="fa-solid fa-xmark"></i> Cancel</button>
                ` : ''}
            </div>
        </div>
    `).join('') : '<div class="text-center py-16 text-gray-500"><i class="fa-regular fa-calendar-xmark text-5xl mb-4"></i><p class="text-lg">No active appointment records found.</p></div>';
}

function showAppointmentQR(item) {
    Swal.fire({
        title: 'Check-in QR Code',
        text: 'Please show this QR code at the clinic reception',
        html: `<div class="flex flex-col items-center gap-4 mt-2"><div class="p-4 bg-white border-2 border-dashed border-gray-300 rounded-2xl inline-block"><canvas id="qr-canvas"></canvas></div><p class="font-mono text-lg font-bold tracking-widest text-indigo-600">${item.regNo || item.id || 'N/A'}</p></div>`,
        didOpen: () => QRCode.toCanvas(document.getElementById('qr-canvas'), `${item.regNo || item.id || ''}|${item.departmentName || ''}|${item.date || ''}`, { width: 220, margin: 1, color: { dark: '#1e3a8a', light: '#ffffff' } }),
        confirmButtonText: 'Done',
        confirmButtonColor: '#2563eb'
    });
}

function editBooking(id, currentDate, currentTime) {
    const today = new Date().toISOString().split('T')[0];
    Swal.fire({
        title: 'Reschedule Appointment',
        html: `
            <div class="text-left mt-4">
                <p class="text-sm text-gray-500 mb-4 bg-blue-50 p-3 rounded-xl border border-blue-100"><i class="fa-solid fa-circle-info mr-1 text-blue-500"></i> Please select a new date and time slot. Your current booking will be overwritten.</p>
                <div class="mb-4">
                    <label class="block text-sm font-bold text-gray-700 mb-2">New Date</label>
                    <input type="date" id="swal-reschedule-date" class="w-full p-3 border border-gray-300 rounded-xl outline-none focus:ring-2 focus:ring-blue-500" min="${today}" value="${currentDate || today}">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">New Time Slot</label>
                    <select id="swal-reschedule-time" class="w-full p-3 border border-gray-300 rounded-xl outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">-- Select Time --</option>
                        <option value="09:00" ${currentTime === '09:00' ? 'selected' : ''}>09:00 - Morning</option>
                        <option value="10:00" ${currentTime === '10:00' ? 'selected' : ''}>10:00 - Morning</option>
                        <option value="11:00" ${currentTime === '11:00' ? 'selected' : ''}>11:00 - Morning</option>
                        <option value="14:00" ${currentTime === '14:00' ? 'selected' : ''}>14:00 - Afternoon</option>
                        <option value="15:00" ${currentTime === '15:00' ? 'selected' : ''}>15:00 - Afternoon</option>
                        <option value="16:00" ${currentTime === '16:00' ? 'selected' : ''}>16:00 - Evening</option>
                    </select>
                </div>
            </div>
        `,
        showCancelButton: true,
        confirmButtonText: 'Confirm Reschedule',
        cancelButtonText: 'Keep Original',
        confirmButtonColor: '#2563eb',
        preConfirm: () => {
            const d = document.getElementById('swal-reschedule-date').value;
            const t = document.getElementById('swal-reschedule-time').value;
            if (!d || !t) {
                Swal.showValidationMessage('Both Date and Time are required.');
            }
            return { date: d, time: t };
        }
    }).then((res) => {
        if (res.isConfirmed) {
            fetch('<%= request.getContextPath() %>/patient/reschedule-booking', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({ registrationId: id, newDate: res.value.date, newTime: res.value.time })
            })
            .then(resp => parseErrorMessage(resp, 'Failed to reschedule appointment'))
            .then(result => {
                if (!result.ok) throw new Error(result.message);
                Swal.fire('Success!', 'Your appointment has been rescheduled.', 'success').then(() => { window.location.reload(); });
            })
            .catch(err => {
                Swal.fire('Error', err.message || 'Failed to reschedule appointment', 'error');
            });
        }
    });
}

function cancelAppointmentById(id) {
    Swal.fire({
        title: 'Cancel Appointment?',
        text: "Are you sure you want to cancel this appointment? This action cannot be undone.",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ef4444',
        cancelButtonColor: '#6b7280',
        confirmButtonText: 'Yes, cancel it!',
        cancelButtonText: 'No, keep it'
    }).then((result) => {
        if (result.isConfirmed) {
            fetch('<%= request.getContextPath() %>/patient/cancel-booking', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({ registrationId: id })
            })
            .then(resp => parseErrorMessage(resp, 'Failed to cancel appointment'))
            .then(result => {
                if (!result.ok) throw new Error(result.message);
                bookPageBuilt = false;
                bookPageHtml = '';
                Swal.fire('Cancelled!', 'Your appointment has been successfully cancelled.', 'success').then(() => { window.location.reload(); });
            })
            .catch(err => {
                Swal.fire('Error', err.message || 'Failed to cancel appointment', 'error');
            });
        }
    });
}

window.onload = () => {
    loadSidebar();
    updateDate();
    loadPage('home');
};
</script>
</body>
</html>