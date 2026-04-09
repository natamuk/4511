<%-- 
    Document   : home
    Created on : 2026年3月31日, 21:43:42
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" import="java.util.*, com.mycompany.system.model.LoginUser" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:useBean id="now" class="java.util.Date" />

<%
    Object userObj = session.getAttribute("loginUser");
    if (userObj == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    LoginUser loginUser = (LoginUser) userObj;

    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("adminProfile");
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    List<Map<String, Object>> queueList = (List<Map<String, Object>>) request.getAttribute("queueList");
    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");
    List<Map<String, Object>> issues = (List<Map<String, Object>>) request.getAttribute("issues");
    List<Map<String, Object>> logs = (List<Map<String, Object>>) request.getAttribute("logs");
    List<Map<String, Object>> doctorUsers = (List<Map<String, Object>>) request.getAttribute("doctorUsers");
    List<Map<String, Object>> patientUsers = (List<Map<String, Object>>) request.getAttribute("patientUsers");
    List<Map<String, Object>> clinics = (List<Map<String, Object>>) request.getAttribute("clinics");
    List<Map<String, Object>> quota = (List<Map<String, Object>>) request.getAttribute("quota");
    Map<String, String> settings = (Map<String, String>) request.getAttribute("settings");

    if (profile == null) profile = new HashMap<>();
    if (appointments == null) appointments = new ArrayList<>();
    if (queueList == null) queueList = new ArrayList<>();
    if (notifications == null) notifications = new ArrayList<>();
    if (issues == null) issues = new ArrayList<>();
    if (logs == null) logs = new ArrayList<>();
    if (doctorUsers == null) doctorUsers = new ArrayList<>();
    if (patientUsers == null) patientUsers = new ArrayList<>();
    if (clinics == null) clinics = new ArrayList<>();
    if (quota == null) quota = new ArrayList<>();
    if (settings == null) settings = new HashMap<>();

    String realName = loginUser.getRealName();
    String avatar = "";
    String email = "";
    String phone = "";

    if (profile.get("realName") != null) realName = String.valueOf(profile.get("realName"));
    if (profile.get("avatar") != null) avatar = String.valueOf(profile.get("avatar"));
    if (profile.get("email") != null) email = String.valueOf(profile.get("email"));
    if (profile.get("phone") != null) phone = String.valueOf(profile.get("phone"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Console - CCHC Clinic Management System</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body { font-family: 'Noto Sans TC', sans-serif; background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%); }
        .glass {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid rgba(255, 255, 255, 0.6);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
        }
        .nav-item {
            transition: background-color 0.2s ease, transform 0.2s ease, color 0.2s ease;
            cursor: pointer;
        }
        .nav-item:hover {
            transform: translateX(8px);
            background: rgba(99,102,241,0.1);
        }
        .nav-item.active {
            background: rgba(99,102,241,0.14);
            color: #4f46e5;
            font-weight: 700;
        }
        .card { transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .card:hover { transform: translateY(-4px); box-shadow: 0 15px 30px rgba(0,0,0,0.08); }
        .badge {
            display: inline-flex; align-items: center; gap: .35rem; padding: .35rem .7rem;
            border-radius: 999px; font-size: .75rem; font-weight: 700; white-space: nowrap;
        }
        .badge-success { background:#dcfce7; color:#166534; }
        .badge-warning { background:#fef3c7; color:#92400e; }
        .badge-danger { background:#fee2e2; color:#b91c1c; }
        .badge-info { background:#dbeafe; color:#1d4ed8; }
        #main-content {
            opacity: 0;
            transform: translate3d(0, 10px, 0);
            will-change: opacity, transform;
            contain: layout paint;
        }
        @media (max-width: 768px) {
            #sidebar { transform: translateX(-100%); transition: transform 0.3s ease; }
            #sidebar.open { transform: translateX(0); }
        }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
    <button id="menu-btn" class="md:hidden absolute top-4 left-4 z-50 p-2 glass rounded-xl text-gray-700 shadow-sm">
        <i class="fa-solid fa-bars"></i>
    </button>

    <aside id="sidebar" class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 z-40 fixed md:relative h-full">
        <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <i class="fa-solid fa-user-shield text-4xl"></i>
                    <div>
                        <h1 class="text-2xl font-bold">CCHC</h1>
                        <p class="text-sm opacity-90">Admin Console</p>
                    </div>
                </div>
                <button id="close-menu-btn" class="md:hidden text-white/80 hover:text-white"><i class="fa-solid fa-xmark text-xl"></i></button>
            </div>
        </div>

        <div class="p-6 flex-1 flex flex-col overflow-y-auto">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img id="sidebar-avatar" src="<%= (avatar != null && !avatar.isEmpty()) ? avatar : "https://picsum.photos/200/200?random=99" %>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                <div>
                    <p class="font-semibold" id="sidebar-name"><%= realName %></p>
                    <p class="text-indigo-600 text-sm">Full Access</p>
                    <p class="text-xs text-gray-500 mt-1">Head Office Management Center</p>
                </div>
            </div>

            <nav class="space-y-1" id="nav">
                <c:forEach var="menu" items="${menuItems}">
                    <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('${menu.id}')" data-page="${menu.id}">
                        <i class="fa-solid ${menu.icon} w-5"></i><span>${menu.name}</span>
                        <c:if test="${menu.id == 'notifications'}">
                            <span id="nav-badge-notifications" class="hidden"></span>
                        </c:if>
                    </div>
                </c:forEach>
            </nav>

            <div class="mt-auto pt-6 border-t border-white/40">
                <button onclick="logout()" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    <span>Logout</span>
                </button>
            </div>
        </div>
    </aside>

    <div class="flex-1 flex flex-col min-w-0">
        <header class="glass border-b px-8 py-4 flex justify-between items-center z-10 relative">
            <div class="pl-10 md:pl-0">
                <h2 id="page-title" class="text-2xl font-semibold">Dashboard</h2>
                <p id="page-subtitle" class="text-sm text-gray-500 mt-1">Overview and administration</p>
            </div>
            <div class="flex items-center gap-3">
                <button onclick="loadPage(state.activePage)" class="p-2 hover:bg-gray-100 rounded-xl transition" title="Refresh">
                    <i class="fa-solid fa-rotate-right text-gray-700"></i>
                </button>
                <button onclick="loadPage('notifications')" class="relative p-2 hover:bg-gray-100 rounded-xl transition" title="Notifications">
                    <i class="fa-solid fa-bell text-xl text-gray-700"></i>
                    <span id="notif-count" class="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] font-bold w-5 h-5 flex items-center justify-center rounded-full hidden">0</span>
                </button>
                <span id="current-date" class="text-sm text-gray-500 font-medium hidden md:inline-block"></span>
            </div>
        </header>
        <div class="flex-1 overflow-auto p-4 md:p-8" id="main-content"></div>
    </div>
</div>

<script>
// 使用 Gson 安全地將 Java 物件轉為 JavaScript 變數
const appointments = <%= new com.google.gson.Gson().toJson(appointments) %> || [];
const queueList = <%= new com.google.gson.Gson().toJson(queueList) %> || [];
const notifications = <%= new com.google.gson.Gson().toJson(notifications) %> || [];
const issues = <%= new com.google.gson.Gson().toJson(issues) %> || [];
const logs = <%= new com.google.gson.Gson().toJson(logs) %> || [];
const doctorUsers = <%= new com.google.gson.Gson().toJson(doctorUsers) %> || [];
const patientUsers = <%= new com.google.gson.Gson().toJson(patientUsers) %> || [];
const clinics = <%= new com.google.gson.Gson().toJson(clinics) %> || [];
const quota = <%= new com.google.gson.Gson().toJson(quota) %> || [];
const settings = <%= new com.google.gson.Gson().toJson(settings) %> || {};

const email = <%= new com.google.gson.Gson().toJson(email) %> || "";
const phone = <%= new com.google.gson.Gson().toJson(phone) %> || "";
const realNameJS = <%= new com.google.gson.Gson().toJson(realName) %> || "";
const avatarJS = <%= new com.google.gson.Gson().toJson(avatar != null && !avatar.isEmpty() ? avatar : "https://picsum.photos/200/200?random=99") %> || "";

const state = { activePage: null };

function updateDate() {
    const el = document.getElementById('current-date');
    if (el) el.textContent = new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
}

function setActiveNav(page) {
    document.querySelectorAll('.nav-item').forEach(el => el.classList.toggle('active', el.dataset.page === page));
    state.activePage = page;
    if(window.innerWidth <= 768) document.getElementById('sidebar').classList.remove('open');
}

function logout() {
    Swal.fire({
        title: 'Confirm logout?',
        text: 'You will leave the admin console',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Logout',
        cancelButtonText: 'Cancel'
    }).then(r => {
        if (r.isConfirmed) window.location.href = '<%= request.getContextPath() %>/logout';
    });
}

function updateNotificationCount() {
    const unread = notifications.filter(n => !n.read).length;
    const el = document.getElementById('notif-count');
    const sidebarBadge = document.getElementById('nav-badge-notifications');
    if (el) {
        if (unread > 0) {
            el.textContent = unread > 99 ? '99' : unread;
            el.classList.remove('hidden');
        } else {
            el.classList.add('hidden');
        }
    }
    if (sidebarBadge) {
        if (unread > 0) {
            sidebarBadge.textContent = unread > 99 ? '99' : unread;
            sidebarBadge.classList.remove('hidden');
        } else {
            sidebarBadge.classList.add('hidden');
        }
    }
}

async function parseResponseSafe(resp, fallbackMsg) {
    const text = await resp.text();
    let data = null;
    try { data = JSON.parse(text); } catch (_) {}
    if (!resp.ok) {
        const msg = (data && data.message) ? data.message : (text || fallbackMsg || 'Request failed');
        throw new Error(msg);
    }
    return data || { success: true, message: text };
}

function deleteUser(id, type) {
    Swal.fire({
        title: 'Delete User?',
        text: "This will disable the user account.",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ef4444',
        confirmButtonText: 'Yes, delete it!'
    }).then((result) => {
        if (!result.isConfirmed) return;

        fetch('<%= request.getContextPath() %>/admin/user/manage', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({ id: id, type: type })
        })
        .then(resp => parseResponseSafe(resp, 'Operation failed'))
        .then(res => {
            if (res.success) {
                Swal.fire('Deleted!', 'User has been disabled.', 'success').then(() => location.reload());
            } else {
                Swal.fire('Error', res.message || 'Operation failed', 'error');
            }
        })
        .catch(err => Swal.fire('Error', err.message || 'Server communication error', 'error'));
    });
}

function addUser() {
    Swal.fire({
        title: 'Create New User',
        html: `
            <select id="swal-type" class="w-full p-3 border rounded-xl mb-3 outline-none focus:ring-2 focus:ring-indigo-500"><option value="doctor">Doctor / Staff</option><option value="admin">Admin</option></select>
            <input id="swal-name" class="w-full p-3 border rounded-xl mb-3 outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Full Name">
            <input id="swal-user" class="w-full p-3 border rounded-xl mb-3 outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Username">
            <input type="password" id="swal-pass" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Password">
        `,
        showCancelButton: true,
        confirmButtonText: 'Create',
        preConfirm: () => ({
            type: document.getElementById('swal-type').value,
            name: document.getElementById('swal-name').value,
            user: document.getElementById('swal-user').value,
            pass: document.getElementById('swal-pass').value
        })
    }).then(r => {
        if (r.isConfirmed) {
            Swal.fire('Success', 'Creation request sent.', 'success');
        }
    });
}

function saveAdminProfile() {
    const newPwd = document.getElementById('admin-new-pwd')?.value || '';
    const confPwd = document.getElementById('admin-conf-pwd')?.value || '';
    if (newPwd && newPwd !== confPwd) {
        Swal.fire({
            icon: 'error',
            title: 'Password Mismatch',
            text: 'New password and confirmation do not match!'
        });
        return;
    }

    fetch('<%= request.getContextPath() %>/admin/update-profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            oldPwd: document.getElementById('admin-old-pwd')?.value || '',
            newPwd: newPwd
        })
    })
    .then(resp => parseResponseSafe(resp, 'Failed to update profile'))
    .then(res => {
        if (res.success) {
            Swal.fire({
                icon: 'success',
                title: 'Profile Updated',
                text: 'Security settings have been saved successfully.',
                timer: 2000,
                showConfirmButton: false
            });
        } else {
            Swal.fire('Error', res.message || 'Failed to update profile', 'error');
        }
    })
    .catch(err => Swal.fire('Error', err.message || 'Server communication error', 'error'));
}

function openNotification(id) { Swal.fire('Notification', 'This is a frontend-only display for now.', 'info'); }
function markAllRead() { Swal.fire('Info', 'If you want to persist read status, add a backend API.', 'info'); }

function loadPage(page) {
    if (state.activePage === page) return;
    setActiveNav(page);

    const c = document.getElementById('main-content');
    c.style.transition = 'none';
    c.style.opacity = '0';
    c.style.transform = 'translate3d(0, 10px, 0)';

    setTimeout(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' });

        if (page === 'dashboard') {
            document.getElementById('page-title').textContent = 'Dashboard';
            document.getElementById('page-subtitle').textContent = 'Overview and live status';
            const noShowCount = appointments.filter(x => x.status === 'no_show').length;
            const cancelCount = appointments.filter(x => x.status === 'cancelled').length;
            c.innerHTML = `
                <div class="max-w-7xl mx-auto space-y-8">
                    <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                        <div>
                            <h1 class="text-4xl font-bold text-gray-800 mb-2">Admin Console</h1>
                            <p class="text-gray-500">Monitor clinic operations, appointment trends, and system events</p>
                        </div>
                        <div class="flex gap-3 flex-wrap items-center">
                            <button onclick="addUser()" class="px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-700 transition text-white font-medium shadow-sm">Add User</button>
                            <button onclick="loadPage('appointments')" class="px-4 py-2 rounded-xl bg-white border hover:bg-gray-50 transition text-gray-700 font-medium shadow-sm">Appointments</button>
                            <button onclick="loadPage('reports')" class="px-4 py-2 rounded-xl bg-white border hover:bg-gray-50 transition text-gray-700 font-medium shadow-sm">View Reports</button>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
                        <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Total Appointments</div><div class="text-4xl font-bold text-indigo-600 mt-2">${'${'}appointments.length}</div><div class="text-xs text-gray-400 mt-2">All appointment records</div></div>
                        <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Queue Waiting</div><div class="text-4xl font-bold text-emerald-600 mt-2">${'${'}queueList.length}</div><div class="text-xs text-gray-400 mt-2">Same-day queue patients</div></div>
                        <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">No-show / Cancelled</div><div class="text-4xl font-bold text-amber-600 mt-2">${'${'}noShowCount + cancelCount}</div><div class="text-xs text-gray-400 mt-2">Risk status total</div></div>
                        <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Average Service Load</div><div class="text-4xl font-bold text-violet-600 mt-2" id="avg-load-value">0%</div><div class="text-xs text-gray-400 mt-2">Average utilization rate</div></div>
                    </div>
                    <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
                        <div class="glass p-6 rounded-3xl">
                            <div class="flex items-center justify-between mb-4">
                                <h3 class="text-xl font-bold">Weekly Booking Trend</h3>
                                <span class="text-sm text-gray-500 border border-gray-200 px-3 py-1 rounded-lg bg-gray-50">Last 7 days</span>
                            </div>
                            <div class="h-64 flex items-center justify-center text-gray-400"><canvas id="bookingChart"></canvas></div>
                        </div>
                        <div class="glass p-6 rounded-3xl">
                            <div class="flex items-center justify-between mb-4">
                                <h3 class="text-xl font-bold">Service Utilization</h3>
                                <span class="text-sm text-gray-500 border border-gray-200 px-3 py-1 rounded-lg bg-gray-50">Overall distribution</span>
                            </div>
                            <div class="h-64 flex items-center justify-center text-gray-400"><canvas id="serviceChart"></canvas></div>
                        </div>
                    </div>
                </div>
            `;
            const avgLoad = quota.length ? Math.round((quota.reduce((a,b)=>a + (Number(b.booked || 0)/Math.max(Number(b.capacity || 1),1)),0)/quota.length) * 100) : 0;
            const avgLoadEl = document.getElementById('avg-load-value');
            if (avgLoadEl) avgLoadEl.textContent = avgLoad + '%';
            setTimeout(() => {
                const bookingCtx = document.getElementById('bookingChart');
                const serviceCtx = document.getElementById('serviceChart');
                if (window.Chart && bookingCtx && serviceCtx) {
                    new Chart(bookingCtx, {
                        type: 'line',
                        data: {
                            labels: ['Day 1','Day 2','Day 3','Day 4','Day 5','Day 6','Day 7'],
                            datasets: [{
                                label: 'Bookings',
                                data: [12, 18, 15, 22, 19, 25, 20],
                                borderColor: '#4f46e5',
                                backgroundColor: 'rgba(79,70,229,0.12)',
                                tension: 0.35,
                                fill: true
                            }]
                        },
                        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
                    });
                    new Chart(serviceCtx, {
                        type: 'doughnut',
                        data: {
                            labels: quota.map(x => x.service || x.clinic || 'Service'),
                            datasets: [{
                                data: quota.map(x => Number(x.booked || 0)),
                                backgroundColor: ['#4f46e5','#10b981','#f59e0b','#8b5cf6']
                            }]
                        },
                        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right' } } }
                    });
                }
            }, 50);
        }
        else if (page === 'users') {
            document.getElementById('page-title').textContent = 'User Management';
            document.getElementById('page-subtitle').textContent = 'Doctor and patient account management';
            c.innerHTML = `
                <div class="space-y-8">
                    <div class="glass rounded-3xl p-8">
                        <div class="flex items-center justify-between mb-6 border-b pb-4">
                            <h3 class="text-2xl font-semibold text-gray-800">Doctor Management</h3>
                            <div class="flex items-center gap-3">
                                <button onclick="addUser()" class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition">Add User</button>
                                <span id="doc-count" class="text-sm font-medium px-3 py-2 bg-indigo-50 text-indigo-700 rounded-xl">Total: ${'${'}doctorUsers.length}</span>
                            </div>
                        </div>
                        <div class="mb-6">
                            <input type="text" id="docSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterDoctors()">
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm text-left min-w-[900px]">
                                <thead class="bg-gray-50 text-gray-600 border-b">
                                    <tr>
                                        <th class="py-4 px-4 rounded-tl-xl">Name</th>
                                        <th class="py-4 px-4">Username</th>
                                        <th class="py-4 px-4">Phone</th>
                                        <th class="py-4 px-4">Email</th>
                                        <th class="py-4 px-4">Title</th>
                                        <th class="py-4 px-4">Status</th>
                                        <th class="py-4 px-4 rounded-tr-xl">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="doc-tbody" class="divide-y"></tbody>
                            </table>
                        </div>
                    </div>

                    <div class="glass rounded-3xl p-8">
                        <div class="flex items-center justify-between mb-6 border-b pb-4">
                            <h3 class="text-2xl font-semibold text-gray-800">Patient Management</h3>
                            <span id="pat-count" class="text-sm font-medium px-3 py-1 bg-emerald-50 text-emerald-700 rounded-lg">Total: ${'${'}patientUsers.length}</span>
                        </div>
                        <div class="mb-6">
                            <input type="text" id="patSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterPatients()">
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-sm text-left min-w-[900px]">
                                <thead class="bg-gray-50 text-gray-600 border-b">
                                    <tr>
                                        <th class="py-4 px-4 rounded-tl-xl">Name</th>
                                        <th class="py-4 px-4">Username</th>
                                        <th class="py-4 px-4">Phone</th>
                                        <th class="py-4 px-4">Email</th>
                                        <th class="py-4 px-4">Address</th>
                                        <th class="py-4 px-4">Status</th>
                                        <th class="py-4 px-4 rounded-tr-xl">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="pat-tbody" class="divide-y"></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            `;
            window.filterDoctors = function() {
                const kwd = document.getElementById('docSearchInput').value.trim().toLowerCase();
                const filtered = doctorUsers.filter(u => !kwd || (u.name || '').toLowerCase().includes(kwd) || (u.phone || '').toLowerCase().includes(kwd) || (u.email || '').toLowerCase().includes(kwd));
                document.getElementById('doc-count').textContent = `Total: ${'${'}filtered.length}`;
                document.getElementById('doc-tbody').innerHTML = filtered.length ? filtered.map(u => `
                    <tr class="hover:bg-indigo-50/30 transition">
                        <td class="py-4 px-4 font-bold text-gray-800">${'${'}u.name || '-'}</td>
                        <td class="px-4">${'${'}u.username || '-'}</td>
                        <td class="px-4">${'${'}u.phone || '-'}</td>
                        <td class="px-4">${'${'}u.email || '-'}</td>
                        <td class="px-4 font-medium">${'${'}u.title || '-'}</td>
                        <td class="px-4"><span class="badge ${'${'}u.status === 'active' ? 'badge-success' : 'badge-danger'}">${'${'}u.status || '-'}</span></td>
                        <td class="px-4">
                            <button onclick="deleteUser('${'${'}u.id}', 'doctor')" class="px-3 py-1.5 rounded-lg bg-red-50 text-red-600 font-medium hover:bg-red-100 transition border border-red-100">Delete</button>
                        </td>
                    </tr>
                `).join('') : `<tr><td colspan="7" class="text-center py-8 text-gray-500">No matching records</td></tr>`;
            };
            window.filterPatients = function() {
                const kwd = document.getElementById('patSearchInput').value.trim().toLowerCase();
                const filtered = patientUsers.filter(u => !kwd || (u.name || '').toLowerCase().includes(kwd) || (u.phone || '').toLowerCase().includes(kwd) || (u.email || '').toLowerCase().includes(kwd));
                document.getElementById('pat-count').textContent = `Total: ${'${'}filtered.length}`;
                document.getElementById('pat-tbody').innerHTML = filtered.length ? filtered.map(u => `
                    <tr class="hover:bg-indigo-50/30 transition">
                        <td class="py-4 px-4 font-bold text-gray-800">${'${'}u.name || '-'}</td>
                        <td class="px-4">${'${'}u.username || '-'}</td>
                        <td class="px-4">${'${'}u.phone || '-'}</td>
                        <td class="px-4">${'${'}u.email || '-'}</td>
                        <td class="px-4 text-gray-600 truncate max-w-[200px]" title="${'${'}u.address || ''}">${'${'}u.address || '-'}</td>
                        <td class="px-4"><span class="badge ${'${'}u.status === 'active' ? 'badge-success' : 'badge-danger'}">${'${'}u.status || '-'}</span></td>
                        <td class="px-4">
                            <button onclick="deleteUser('${'${'}u.id}', 'patient')" class="px-3 py-1.5 rounded-lg bg-red-50 text-red-600 font-medium hover:bg-red-100 transition border border-red-100">Delete</button>
                        </td>
                    </tr>
                `).join('') : `<tr><td colspan="7" class="text-center py-8 text-gray-500">No matching records</td></tr>`;
            };
            filterDoctors();
            filterPatients();
        }
        else if (page === 'appointments') {
            document.getElementById('page-title').textContent = 'Appointment Management';
            document.getElementById('page-subtitle').textContent = 'View all appointments and control status';
            c.innerHTML = `
                <div class="glass rounded-3xl p-8">
                    <h3 class="text-2xl font-semibold mb-6 border-b pb-4">Appointment Overview</h3>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm text-left min-w-[1000px]">
                            <thead class="bg-gray-50 text-gray-600 border-b">
                                <tr>
                                    <th class="py-4 px-4 rounded-tl-xl">Date & Time</th>
                                    <th class="py-4 px-4">Ticket No.</th>
                                    <th class="py-4 px-4">Patient Name</th>
                                    <th class="py-4 px-4">Doctor</th>
                                    <th class="py-4 px-4">Department</th>
                                    <th class="py-4 px-4">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                ${'${'}appointments.length ? appointments.map(a => `
                                    <tr class="hover:bg-gray-50 transition">
                                        <td class="py-4 px-4 font-medium">${'${'}a.date || ''} ${'${'}a.time || ''}</td>
                                        <td class="px-4 font-mono text-indigo-600">${'${'}a.regNo || ''}</td>
                                        <td class="px-4 font-bold text-gray-800">${'${'}a.patient || ''}</td>
                                        <td class="px-4">${'${'}a.doctor || ''}</td>
                                        <td class="px-4">${'${'}a.department || ''}</td>
                                        <td class="px-4"><span class="badge ${'${'}a.status==='Completed'?'badge-success':(a.status==='Cancelled'||a.status==='no_show'?'badge-danger':'badge-info')}">${'${'}a.status || ''}</span></td>
                                    </tr>
                                `).join('') : `<tr><td colspan="6" class="text-center py-10 text-gray-500">No appointment records</td></tr>`}
                            </tbody>
                        </table>
                    </div>
                </div>
            `;
        }
        else if (page === 'queue') {
            document.getElementById('page-title').textContent = 'Queue Management';
            document.getElementById('page-subtitle').textContent = 'View and control same-day queue status';
            c.innerHTML = `
                <div class="glass rounded-3xl p-8">
                    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6 border-b pb-4">
                        <div>
                            <h3 class="text-2xl font-semibold text-gray-800">Live Same-day Queue</h3>
                            <p class="text-sm text-gray-500 mt-1 font-medium">Currently ${'${'}queueList.length} patients active in queue</p>
                        </div>
                    </div>
                    <div class="space-y-4">
                        ${'${'}queueList.length ? queueList.map(item => `
                            <div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm hover:shadow-md transition">
                                <div class="flex-1">
                                    <div class="flex items-center gap-3 mb-1">
                                        <span class="font-mono font-bold text-xl text-indigo-600 bg-indigo-50 px-2 py-1 rounded">${'${'}item.ticketNo || ''}</span>
                                        <p class="font-bold text-lg text-gray-800">${'${'}item.patient || ''}</p>
                                    </div>
                                    <p class="text-sm text-gray-600 font-medium">${'${'}item.clinic || ''} • <span class="text-gray-500">${'${'}item.service || ''}</span></p>
                                </div>
                                <div><span class="badge badge-info shadow-sm">${'${'}item.status || ''}</span></div>
                            </div>
                        `).join('') : `
                            <div class="text-center py-16">
                                <i class="fa-solid fa-users-slash text-6xl text-gray-300 mb-4"></i>
                                <p class="text-gray-500 text-lg">No patients in queue</p>
                            </div>
                        `}
                    </div>
                </div>
            `;
        }
        else if (page === 'quota') {
            document.getElementById('page-title').textContent = 'Clinic & Service Settings';
            document.getElementById('page-subtitle').textContent = 'Manage clinics, services, and capacity';
            c.innerHTML = `
                <div class="max-w-5xl mx-auto space-y-8">
                    <div class="glass p-8 rounded-3xl">
                        <h3 class="text-2xl font-bold mb-6 border-b pb-4 text-gray-800">Service Capacity Overview</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            ${'${'}quota.map(item => {
                                const pct = item.capacity ? Math.round((item.booked / item.capacity) * 100) : 0;
                                const isHigh = pct >= 80;
                                return `
                                <div class="p-5 border rounded-2xl bg-white shadow-sm flex flex-col justify-between">
                                    <div class="flex justify-between items-start mb-4">
                                        <div class="font-bold text-lg text-gray-800">${'${'}item.service || ''}</div>
                                        <span class="px-2 py-1 text-xs font-bold rounded ${'${'}isHigh ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'}">${'${'}pct}% Full</span>
                                    </div>
                                    <div>
                                        <div class="w-full bg-gray-200 rounded-full h-2.5 mb-2">
                                            <div class="h-2.5 rounded-full ${'${'}isHigh ? 'bg-red-500' : 'bg-emerald-500'}" style="width: ${'${'}pct}%"></div>
                                        </div>
                                        <div class="text-sm text-gray-500 font-medium">Booked: <b>${'${'}item.booked || 0}</b> / ${'${'}item.capacity || 0}</div>
                                    </div>
                                </div>
                            `}).join('')}
                        </div>
                    </div>
                    <div class="glass p-8 rounded-3xl">
                        <div class="flex items-center justify-between mb-6 border-b pb-4">
                            <h3 class="text-2xl font-bold text-gray-800">Clinic Branches</h3>
                            <button onclick="Swal.fire('Info', 'Add clinic form goes here', 'info')" class="text-sm text-indigo-600 font-medium hover:underline">+ Add New</button>
                        </div>
                        <div class="space-y-4">
                            ${'${'}clinics.map(cn => `
                                <div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center md:justify-between gap-4 shadow-sm hover:shadow-md transition">
                                    <div>
                                        <p class="font-bold text-lg text-gray-800">${'${'}cn.name}</p>
                                        <p class="text-sm text-gray-500 mt-1"><i class="fa-solid fa-location-dot mr-1"></i> ${'${'}cn.location || cn.address || ''}</p>
                                    </div>
                                    <div class="flex items-center gap-3">
                                        <span class="badge ${'${'}cn.active ? 'badge-success' : 'badge-danger'}">${'${'}cn.active ? 'Active' : 'Inactive'}</span>
                                        <button class="p-2 text-gray-400 hover:text-indigo-600 transition"><i class="fa-solid fa-pen-to-square"></i></button>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                </div>
            `;
        }
        else if (page === 'reports') {
            document.getElementById('page-title').textContent = 'Reports & Analytics';
            document.getElementById('page-subtitle').textContent = 'Operational statistics, analytics, and incident records';
            c.innerHTML = `
                <div class="max-w-7xl mx-auto space-y-8">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="glass p-6 rounded-3xl text-center shadow-sm">
                            <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Cancellation Rate</div>
                            <div class="text-5xl font-bold text-red-500 mt-3">8%</div>
                        </div>
                        <div class="glass p-6 rounded-3xl text-center shadow-sm">
                            <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">No-show Rate</div>
                            <div class="text-5xl font-bold text-amber-500 mt-3">6%</div>
                        </div>
                        <div class="glass p-6 rounded-3xl text-center shadow-sm">
                            <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Avg Wait Time</div>
                            <div class="text-5xl font-bold text-indigo-600 mt-3">18 <span class="text-xl">min</span></div>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
                        <div class="glass p-8 rounded-3xl">
                            <h3 class="text-xl font-bold mb-6 text-gray-800">Service Capacity Data</h3>
                            <div class="overflow-x-auto">
                                <table class="w-full text-sm text-left">
                                    <thead class="border-b bg-gray-50">
                                        <tr>
                                            <th class="py-3 px-4 font-semibold text-gray-600 rounded-tl-lg">Service</th>
                                            <th class="py-3 px-4 font-semibold text-gray-600 text-center">Used</th>
                                            <th class="py-3 px-4 font-semibold text-gray-600 text-center">Capacity</th>
                                            <th class="py-3 px-4 font-semibold text-gray-600 text-center rounded-tr-lg">Rate</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-100">
                                        ${'${'}quota.map(x => {
                                            const r = x.capacity ? Math.round((x.booked / x.capacity) * 100) : 0;
                                            return \`<tr class="hover:bg-gray-50">
                                                <td class="py-3 px-4 font-medium text-gray-800">${'${'}x.service || ''}</td>
                                                <td class="px-4 text-center font-bold text-indigo-600">${'${'}x.booked || 0}</td>
                                                <td class="px-4 text-center text-gray-500">${'${'}x.capacity || 0}</td>
                                                <td class="px-4 text-center"><span class="px-2 py-1 rounded text-xs font-bold ${'${'}r>=80?'bg-red-100 text-red-700':'bg-emerald-100 text-emerald-700'}">${'${'}r}%</span></td>
                                            </tr>\`;
                                        }).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="glass p-8 rounded-3xl border border-red-100 shadow-sm bg-red-50/30">
                            <h3 class="text-xl font-bold mb-4 text-red-700"><i class="fa-solid fa-triangle-exclamation mr-2"></i> Incident Records</h3>
                            <div class="p-6 border-2 border-dashed border-red-200 rounded-2xl text-center bg-white">
                                <i class="fa-regular fa-folder-open text-4xl text-red-300 mb-3"></i>
                                <div class="text-gray-500 font-medium">No recent incidents reported.</div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }
        else if (page === 'logs') {
            document.getElementById('page-title').textContent = 'Audit Trail';
            document.getElementById('page-subtitle').textContent = 'System operations and change records';
            c.innerHTML = `
                <div class="glass p-8 rounded-3xl max-w-6xl mx-auto">
                    <div class="flex justify-between items-center mb-6 border-b pb-4">
                        <h3 class="text-2xl font-bold text-gray-800">System Activity Log</h3>
                        <button class="text-sm font-medium text-indigo-600 hover:text-indigo-800 transition"><i class="fa-solid fa-download mr-1"></i> Export Log</button>
                    </div>
                    <div class="space-y-4">
                        ${'${'}logs.length ? logs.map(i => `
                            <div class="p-4 border rounded-2xl bg-white shadow-sm flex items-start gap-4">
                                <div class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 text-gray-500">
                                    <i class="fa-solid fa-desktop"></i>
                                </div>
                                <div>
                                    <p class="font-medium text-gray-800">${'${'}i.action || ''}</p>
                                    <p class="text-sm text-gray-500 mt-1 font-mono">${'${'}i.createdAt || ''}</p>
                                </div>
                            </div>
                        `).join('') : '<div class="text-center py-12 text-gray-500"><i class="fa-solid fa-clipboard-list text-4xl mb-3"></i><p>No activity logs found.</p></div>'}
                    </div>
                </div>
            `;
        }
        else if (page === 'notifications') {
            document.getElementById('page-title').textContent = 'Notifications';
            document.getElementById('page-subtitle').textContent = 'View system notifications and reminders';
            c.innerHTML = `
                <div class="glass rounded-3xl p-8 max-w-5xl mx-auto">
                    <div class="flex items-center justify-between mb-6 border-b pb-4">
                        <h3 class="text-2xl font-bold text-gray-800">Alerts & Notifications</h3>
                        <button onclick="markAllRead()" class="px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-medium rounded-xl transition"><i class="fa-solid fa-check-double mr-1"></i> Mark All as Read</button>
                    </div>
                    <div class="space-y-4">
                        ${'${'}notifications.length ? notifications.map(n => `
                            <div class="p-5 border rounded-2xl bg-white flex items-start gap-4 shadow-sm hover:shadow-md transition cursor-pointer ${'${'}n.read ? 'opacity-70' : ''}" onclick="openNotification(${'${'}n.id})">
                                <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${'${'}n.type === 'success' ? 'bg-emerald-100 text-emerald-700' : n.type === 'warning' ? 'bg-amber-100 text-amber-700' : 'bg-blue-100 text-blue-700'}">
                                    <i class="fa-solid ${'${'}n.type === 'warning' ? 'fa-triangle-exclamation' : 'fa-bell'}"></i>
                                </div>
                                <div class="flex-1">
                                    <div class="flex items-center justify-between gap-4 mb-1">
                                        <p class="font-bold text-lg text-gray-800 flex items-center gap-2">
                                            ${'${'}n.title}
                                            ${'${'}n.read ? '' : '<span class="w-2.5 h-2.5 rounded-full bg-red-500 inline-block shadow-sm shadow-red-200"></span>'}
                                        </p>
                                        <span class="text-xs font-medium text-gray-400 bg-gray-50 px-2 py-1 rounded">${'${'}n.time || ''}</span>
                                    </div>
                                    <p class="text-gray-600">${'${'}n.message || ''}</p>
                                </div>
                            </div>
                        `).join('') : '<div class="text-center py-16 text-gray-500"><i class="fa-regular fa-bell-slash text-5xl mb-4"></i><p class="text-lg">Inbox is empty.</p></div>'}
                    </div>
                </div>
            `;
        }
        else if (page === 'settings') {
            document.getElementById('page-title').textContent = 'System Settings';
            document.getElementById('page-subtitle').textContent = 'Site-wide policies and feature toggles';
            c.innerHTML = `
                <div class="max-w-4xl mx-auto glass p-8 rounded-3xl space-y-8">
                    <h3 class="text-2xl font-bold text-gray-800 border-b pb-4">Global Policies</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <div class="space-y-2">
                            <label class="block text-sm font-bold text-gray-700">Max Active Bookings per Patient</label>
                            <p class="text-xs text-gray-500 mb-2">Limit how many future appointments a single patient can hold.</p>
                            <input id="st-max" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" value="${'${'}settings.max_active_bookings_per_patient || 3}">
                        </div>
                        <div class="space-y-2">
                            <label class="block text-sm font-bold text-gray-700">Cancellation Deadline (Hours)</label>
                            <p class="text-xs text-gray-500 mb-2">How many hours before the appointment can they cancel?</p>
                            <input id="st-cancel" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" value="${'${'}settings.cancel_deadline_hours || 24}">
                        </div>
                    </div>
                    <h3 class="text-2xl font-bold text-gray-800 border-b pb-4 mt-10">Feature Toggles</h3>
                    <div class="space-y-6">
                        <div class="flex items-center gap-4 p-4 border rounded-2xl bg-white shadow-sm">
                            <div class="relative inline-block w-12 h-6 align-middle select-none transition duration-200 ease-in">
                                <input type="checkbox" name="toggle" id="st-queue" class="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 appearance-none cursor-pointer border-gray-300 checked:border-indigo-600 checked:right-0 transition-all duration-200" ${'${'}settings.same_day_queue_enabled === '1' ? 'checked' : ''}/>
                                <label for="st-queue" class="toggle-label block overflow-hidden h-6 rounded-full bg-gray-300 cursor-pointer"></label>
                            </div>
                            <div>
                                <label for="st-queue" class="font-bold text-gray-800 cursor-pointer">Enable Same-day Walk-in Queue</label>
                                <p class="text-sm text-gray-500">Allow patients to join the queue on the day of service.</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 p-4 border rounded-2xl bg-white shadow-sm">
                            <div class="relative inline-block w-12 h-6 align-middle select-none transition duration-200 ease-in">
                                <input type="checkbox" name="toggle" id="st-approval" class="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 appearance-none cursor-pointer border-gray-300 checked:border-indigo-600 checked:right-0 transition-all duration-200" ${'${'}settings.booking_approval_required === '1' ? 'checked' : ''}/>
                                <label for="st-approval" class="toggle-label block overflow-hidden h-6 rounded-full bg-gray-300 cursor-pointer"></label>
                            </div>
                            <div>
                                <label for="st-approval" class="font-bold text-gray-800 cursor-pointer">Require Booking Approval</label>
                                <p class="text-sm text-gray-500">Doctors or staff must manually approve new online bookings.</p>
                            </div>
                        </div>
                    </div>
                    <div class="pt-6 mt-6 border-t flex justify-end">
                        <button onclick="Swal.fire('Info','Settings storage API is not connected yet.','info')" class="px-8 py-3 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold transition shadow-md">Save Global Settings</button>
                    </div>
                </div>
            `;
        }
        else if (page === 'csv') {
            document.getElementById('page-title').textContent = 'CSV Management';
            document.getElementById('page-subtitle').textContent = 'Import and export clinic data securely';
            c.innerHTML = `
                <div class="max-w-4xl mx-auto glass p-10 rounded-3xl text-center">
                    <h3 class="text-3xl font-bold mb-2 text-gray-800">Data Import & Export</h3>
                    <p class="text-gray-500 mb-10">Manage batch data operations using CSV format.</p>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <button onclick="Swal.fire('Info','Export functionality can be connected to a backend API.','info')" class="p-10 bg-white border rounded-3xl hover:border-emerald-500 hover:shadow-xl transition group">
                            <div class="w-20 h-20 mx-auto bg-emerald-50 rounded-full flex items-center justify-center mb-6 group-hover:scale-110 transition">
                                <i class="fa-solid fa-file-export text-emerald-600 text-3xl"></i>
                            </div>
                            <p class="text-xl font-bold text-gray-800 mb-2">Export Data</p>
                            <p class="text-sm text-gray-500">Download appointment records and user data.</p>
                        </button>
                        <button onclick="Swal.fire('Info','Import functionality can be connected to a backend API.','info')" class="p-10 bg-white border rounded-3xl hover:border-indigo-500 hover:shadow-xl transition group">
                            <div class="w-20 h-20 mx-auto bg-indigo-50 rounded-full flex items-center justify-center mb-6 group-hover:scale-110 transition">
                                <i class="fa-solid fa-file-import text-indigo-600 text-3xl"></i>
                            </div>
                            <p class="text-xl font-bold text-gray-800 mb-2">Import CSV</p>
                            <p class="text-sm text-gray-500">Batch create time slots, services, or new staff accounts.</p>
                        </button>
                    </div>
                </div>
            `;
        }
        else if (page === 'profile') {
            document.getElementById('page-title').textContent = 'Profile & Security';
            document.getElementById('page-subtitle').textContent = 'Admin account settings and password management';
            c.innerHTML = `
                <div class="max-w-3xl mx-auto glass rounded-3xl p-8">
                    <h3 class="text-2xl font-bold mb-6 text-gray-800 border-b pb-4"><i class="fa-solid fa-user-shield text-gray-400 mr-2"></i>Account Profile</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="md:col-span-2 flex items-center gap-6 mb-4">
                            <img src="${'${'}avatarJS}" class="w-24 h-24 rounded-full ring-4 ring-indigo-50 object-cover shadow-sm" alt="avatar">
                            <div>
                                <h4 class="text-xl font-bold text-gray-800">${'${'}realNameJS}</h4>
                                <p class="text-sm font-medium text-indigo-600 bg-indigo-50 px-3 py-1 rounded inline-block mt-2">System Administrator</p>
                            </div>
                        </div>
                        <div><label class="block text-sm font-bold text-gray-700 mb-2">Full Name</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="${'${'}realNameJS}" readonly></div>
                        <div><label class="block text-sm font-bold text-gray-700 mb-2">Role Access</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="Full Access" readonly></div>
                        <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-2">Email Address</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="${'${'}email}" readonly></div>
                        <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-2">Phone Number</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="${'${'}phone}" readonly></div>
                    </div>
                    <div class="mt-10 pt-8 border-t border-gray-200">
                        <h3 class="text-2xl font-bold mb-6 text-gray-800"><i class="fa-solid fa-lock text-gray-400 mr-2"></i>Change Password</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="md:col-span-2">
                                <label class="block text-sm font-bold text-gray-700 mb-2">Current Password</label>
                                <input type="password" id="admin-old-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 transition shadow-sm" placeholder="Leave blank if not changing">
                            </div>
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2">New Password</label>
                                <input type="password" id="admin-new-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 transition shadow-sm" placeholder="Enter new password">
                            </div>
                            <div>
                                <label class="block text-sm font-bold text-gray-700 mb-2">Confirm New Password</label>
                                <input type="password" id="admin-conf-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 transition shadow-sm" placeholder="Re-enter new password">
                            </div>
                        </div>
                        <div class="mt-8 flex justify-end">
                            <button onclick="saveAdminProfile()" class="px-8 py-3 bg-indigo-600 text-white font-bold rounded-xl hover:bg-indigo-700 transition shadow-md">Save All Changes</button>
                        </div>
                    </div>
                </div>
            `;
        }

        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                c.style.transition = 'opacity 0.25s ease-out, transform 0.25s cubic-bezier(0.4, 0, 0.2, 1)';
                c.style.opacity = '1';
                c.style.transform = 'translate3d(0, 0, 0)';
            });
        });
    }, 30);
}

window.onload = () => {
    updateDate();
    document.getElementById('menu-btn')?.addEventListener('click', () => { document.getElementById('sidebar').classList.toggle('open'); });
    document.getElementById('close-menu-btn')?.addEventListener('click', () => { document.getElementById('sidebar').classList.remove('open'); });
    updateNotificationCount();
    loadPage('dashboard');
};
</script>
</body>
</html>