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
        .glass { background: rgba(255,255,255,0.95); border:1px solid rgba(255,255,255,0.6); box-shadow:0 4px 6px -1px rgba(0,0,0,0.05); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); }
        .nav-item { transition: background-color .2s, transform .2s, color .2s; cursor:pointer; }
        .nav-item:hover { transform: translateX(8px); background: rgba(99,102,241,0.1); }
        .nav-item.active { background: rgba(99,102,241,0.14); color:#4f46e5; font-weight:700; }
        .card:hover { transform: translateY(-4px); box-shadow:0 15px 30px rgba(0,0,0,0.08); }
        .badge { display:inline-flex; align-items:center; gap:.35rem; padding:.35rem .7rem; border-radius:999px; font-size:.75rem; font-weight:700; white-space:nowrap; }
        .badge-success { background:#dcfce7; color:#166534; } .badge-warning { background:#fef3c7; color:#92400e; } .badge-danger { background:#fee2e2; color:#b91c1c; } .badge-info { background:#dbeafe; color:#1d4ed8; }
        #main-content { opacity:0; transform: translate3d(0,10px,0); will-change: opacity, transform; contain:layout paint; }
        @media (max-width:768px) { #sidebar { transform: translateX(-100%); transition: transform .3s; } #sidebar.open { transform: translateX(0); } }
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
                <img id="sidebar-avatar" src="<%= (avatar != null && !avatar.isEmpty()) ? avatar : "https://picsum.photos/200/200?random=99"%>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                <div>
                    <p class="font-semibold" id="sidebar-name"><%= realName%></p>
                    <p class="text-indigo-600 text-sm">Full Access</p>
                    <p class="text-xs text-gray-500 mt-1">Head Office Management Center</p>
                </div>
            </div>

            <nav class="space-y-1" id="nav">
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('dashboard')">
                    <i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('users')">
                    <i class="fa-solid fa-users w-5"></i><span>User Management</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('appointments')">
                    <i class="fa-solid fa-calendar-check w-5"></i><span>Appointments</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('queue')">
                    <i class="fa-solid fa-list-ol w-5"></i><span>Queue</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('quota')">
                    <i class="fa-solid fa-server w-5"></i><span>Services & Quota</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('reports')">
                    <i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('logs')">
                    <i class="fa-solid fa-clipboard-list w-5"></i><span>Audit Logs</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('notifications')">
                    <i class="fa-solid fa-bell w-5"></i><span>Notifications</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('settings')">
                    <i class="fa-solid fa-sliders w-5"></i><span>Settings</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('csv')">
                    <i class="fa-solid fa-file-csv w-5"></i><span>CSV Import/Export</span>
                </button>
                <button class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" onclick="loadPage('profile')">
                    <i class="fa-solid fa-user-gear w-5"></i><span>Profile</span>
                </button>
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
                <button onclick="refreshPage()" class="p-2 hover:bg-gray-100 rounded-xl transition" title="Refresh">
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
    const appointments = <%= new com.google.gson.Gson().toJson(appointments)%> || [];
    const queueList = <%= new com.google.gson.Gson().toJson(queueList)%> || [];
    const notifications = <%= new com.google.gson.Gson().toJson(notifications)%> || [];
    const issues = <%= new com.google.gson.Gson().toJson(issues)%> || [];
    const logs = <%= new com.google.gson.Gson().toJson(logs)%> || [];
    const doctorUsers = <%= new com.google.gson.Gson().toJson(doctorUsers)%> || [];
    const patientUsers = <%= new com.google.gson.Gson().toJson(patientUsers)%> || [];
    const clinics = <%= new com.google.gson.Gson().toJson(clinics)%> || [];
    const quota = <%= new com.google.gson.Gson().toJson(quota)%> || [];
    const settings = <%= new com.google.gson.Gson().toJson(settings)%> || {};

    const email = "<%= email%>";
    const phone = "<%= phone%>";
    const realNameJS = "<%= realName%>";
    const avatarJS = "<%= (avatar != null && !avatar.isEmpty()) ? avatar : "https://picsum.photos/200/200?random=99"%>";

    const state = {activePage: null};
    const CONTEXT_PATH = '<%= request.getContextPath() %>';

    function updateDate() {
        const el = document.getElementById('current-date');
        if (el) el.textContent = new Date().toLocaleDateString('en-US', {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'});
    }

    function setActiveNav(page) {
        document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
        document.querySelectorAll(`.nav-item`).forEach(b => {
            const onclick = b.getAttribute('onclick') || '';
            if (onclick.includes(`loadPage('${page}')`)) b.classList.add('active');
        });
        state.activePage = page;
        if (window.innerWidth <= 768) document.getElementById('sidebar').classList.remove('open');
    }

    function logout() {
        Swal.fire({title: 'Confirm logout?', icon: 'warning', showCancelButton: true}).then(r => {
            if (r.isConfirmed) window.location.href = CONTEXT_PATH + '/logout';
        });
    }

    function refreshPage() {
        if (state.activePage) loadPage(state.activePage);
    }

    function loadPage(page) {
        console.log('loadPage called with page=', page);
        if (!page || typeof page !== 'string') {
            console.warn('loadPage: invalid page value, aborting.');
            return;
        }
        page = page.trim();
        if (page === '') {
            console.warn('loadPage: empty page string, aborting.');
            return;
        }

        state.activePage = page;
        const c = document.getElementById('main-content');
        c.style.opacity = '0';

        const base = CONTEXT_PATH + '/admin/contents/';
        const url = base + encodeURIComponent(page) + '-contents.jsp';
        console.log('Fetching content URL:', url);

        fetch(url, { credentials: 'same-origin' })
            .then(res => {
                if (!res.ok) throw new Error('HTTP ' + res.status);
                return res.text();
            })
            .then(html => {
                c.innerHTML = html;
                c.style.opacity = '1';
                const titles = {
                    dashboard: 'Dashboard', users: 'User Management', appointments: 'Appointments',
                    queue: 'Queue', quota: 'Services & Quota', reports: 'Reports', logs: 'Audit Logs',
                    notifications: 'Notifications', settings: 'System Settings', csv: 'CSV Tools', profile: 'Profile'
                };
                const subtitles = {
                    dashboard: 'Overview and live status', users: 'Doctor and patient accounts',
                    appointments: 'All appointment records', queue: 'Current patient queue',
                    quota: 'Clinic capacity & services', reports: 'Analytics & reports',
                    logs: 'System activity records', notifications: 'Alerts & messages',
                    settings: 'Global system policies', csv: 'Data import/export', profile: 'Account & security'
                };
                document.getElementById('page-title').textContent = titles[page] || 'Page';
                document.getElementById('page-subtitle').textContent = subtitles[page] || '';
                setActiveNav(page);
            })
            .catch(err => {
                console.error('Failed loading page content:', err);
                c.innerHTML = '<div class="p-8 text-center text-red-500">Failed to load content (' + err.message + ').</div>';
                c.style.opacity = '1';
            });
    }

    window.onload = () => {
        updateDate();
        const menuBtn = document.getElementById('menu-btn');
        const closeMenuBtn = document.getElementById('close-menu-btn');
        const sidebarEl = document.getElementById('sidebar');

        if (menuBtn) {
            menuBtn.onclick = () => {
                sidebarEl.classList.toggle('open');
            };
        }
        if (closeMenuBtn) {
            closeMenuBtn.onclick = () => sidebarEl.classList.remove('open');
        }

        loadPage('dashboard');
    };
</script>
</body>
</html>