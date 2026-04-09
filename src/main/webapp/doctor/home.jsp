<%-- 
    Document   : home
    Created on : 2026年3月31日, 22:17:49
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" import="java.util.*, com.mycompany.system.model.LoginUser" %>
<%
    Object userObj = session.getAttribute("loginUser");
    if (userObj == null || !"doctor".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    LoginUser loginUser = (LoginUser) userObj;

    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("staffProfile");
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    List<Map<String, Object>> queueList = (List<Map<String, Object>>) request.getAttribute("queueList");
    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");
    List<Map<String, Object>> issues = (List<Map<String, Object>>) request.getAttribute("issues");
    List<Map<String, Object>> consultations = (List<Map<String, Object>>) request.getAttribute("consultations");
    List<Map<String, Object>> searchResults = (List<Map<String, Object>>) request.getAttribute("searchResults");
    List<Map<String, Object>> recordResults = (List<Map<String, Object>>) request.getAttribute("recordResults");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");

    if (profile == null) profile = new HashMap<>();
    if (appointments == null) appointments = new ArrayList<>();
    if (queueList == null) queueList = new ArrayList<>();
    if (notifications == null) notifications = new ArrayList<>();
    if (issues == null) issues = new ArrayList<>();
    if (consultations == null) consultations = new ArrayList<>();
    if (searchResults == null) searchResults = new ArrayList<>();
    if (recordResults == null) recordResults = new ArrayList<>();
    if (stats == null) stats = new HashMap<>();

    String doctorName = loginUser.getRealName();
    String doctorTitle = profile.get("title") != null ? String.valueOf(profile.get("title")) : "Doctor";
    String departmentName = profile.get("departmentName") != null ? String.valueOf(profile.get("departmentName")) : "Clinic";
    String doctorAvatar = profile.get("avatar") != null && !String.valueOf(profile.get("avatar")).isEmpty()
            ? String.valueOf(profile.get("avatar"))
            : "https://picsum.photos/200/200?random=2";
    String todayStr = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

    int waitingCount = 0;
    for (Map<String, Object> q : queueList) {
        Object st = q.get("statusCode");
        int code = st instanceof Number ? ((Number) st).intValue() : 0;
        if (code == 1 || code == 3) waitingCount++;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Doctor Dashboard - CCHC Community Clinic System</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
            /* 優化: 強制硬件加速，防止重新繪製導致的卡頓 */
            transform: translateZ(0);
        }

        .nav-item { 
            transition: background-color 0.15s ease, transform 0.15s ease, color 0.15s ease; 
            cursor: pointer; 
            /* 優化: 提前宣告變化並開啟GPU加速 */
            will-change: transform, background-color;
            transform: translateZ(0);
        }
        .nav-item:hover { 
            transform: translate3d(8px, 0, 0); 
            background: rgba(14,165,233,0.1); 
        }
        .nav-item.active { background: rgba(14,165,233,0.14); color: #0369a1; font-weight: 700; }

        .home-card { 
            transition: transform 0.15s ease, box-shadow 0.15s ease; 
            /* 優化: 提前宣告變化並開啟GPU加速 */
            will-change: transform, box-shadow;
            transform: translateZ(0);
        }
        .home-card:hover { 
            transform: translate3d(0, -4px, 0); 
            box-shadow: 0 15px 30px rgba(0,0,0,0.08); 
        }

        .status-badge {
            display: inline-flex; align-items: center; gap: .35rem; padding: .35rem .75rem;
            border-radius: 9999px; font-size: .75rem; font-weight: 700; white-space: nowrap;
        }
        .status-pending { background:#fef3c7; color:#92400e; }
        .status-approved { background:#dbeafe; color:#1d4ed8; }
        .status-arrived { background:#dcfce7; color:#166534; }
        .status-no-show { background:#fee2e2; color:#b91c1c; }
        .status-completed { background:#e9d5ff; color:#6b21a8; }
        .status-cancelled { background:#e5e7eb; color:#374151; }

        #main-content {
            opacity: 0;
            transform: translate3d(0, 10px, 0);
            will-change: opacity, transform;
            contain: layout paint;
        }

        .queue-card {
            transition: transform 0.15s ease, box-shadow 0.15s ease;
            /* 優化: 提前宣告變化並開啟GPU加速 */
            will-change: transform, box-shadow;
            transform: translateZ(0);
        }
        .queue-card:hover {
            transform: translate3d(0, -3px, 0);
            box-shadow: 0 12px 24px rgba(0,0,0,0.06);
        }

        /* 按鈕優化 */
        button {
            will-change: transform, background-color;
            transform: translateZ(0);
            transition: all 0.15s ease;
        }

        @media (max-width: 768px) {
            #sidebar { transform: translate3d(-100%, 0, 0); transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1); will-change: transform; }
            #sidebar.open { transform: translate3d(0, 0, 0); }
        }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
    <button id="menu-btn" class="md:hidden absolute top-4 left-4 z-50 p-2 glass rounded-xl shadow-sm text-gray-700">
        <i class="fa-solid fa-bars"></i>
    </button>

    <div id="sidebar" class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 z-40 fixed md:relative h-full">
        <div class="p-6 bg-gradient-to-r from-sky-700 to-blue-700 text-white">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <i class="fa-solid fa-user-doctor text-4xl"></i>
                    <div>
                        <h1 class="text-2xl font-bold">CCHC</h1>
                        <p class="text-sm opacity-90">Doctor Dashboard</p>
                    </div>
                </div>
                <button id="close-menu-btn" class="md:hidden text-white/80 hover:text-white"><i class="fa-solid fa-xmark text-xl"></i></button>
            </div>
        </div>

        <div class="p-6 flex-1 flex flex-col overflow-y-auto">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img id="sidebar-avatar" src="<%= doctorAvatar %>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                <div>
                    <p class="font-semibold" id="sidebar-name"><%= doctorName %></p>
                    <p class="text-sky-600 text-sm" id="sidebar-role"><%= doctorTitle %></p>
                    <p class="text-xs text-gray-500 mt-1" id="sidebar-clinic"><%= departmentName %></p>
                </div>
            </div>

            <nav class="space-y-1" id="nav"></nav>

            <div class="mt-auto pt-6 border-t border-white/40">
                <button onclick="logout()" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    <span>Logout</span>
                </button>
            </div>
        </div>
    </div>

    <div class="flex-1 flex flex-col min-w-0">
        <header class="glass border-b px-8 py-4 flex justify-between items-center z-10 relative">
            <div class="pl-10 md:pl-0">
                <h2 id="page-title" class="text-2xl font-semibold">Dashboard</h2>
                <p class="text-sm text-gray-500 mt-1" id="page-subtitle">Today’s clinic overview</p>
            </div>
            <div class="flex items-center gap-3">
                <button onclick="loadPage(state.activePage || 'dashboard')" class="p-2 hover:bg-gray-100 rounded-xl transition" title="Refresh">
                    <i class="fa-solid fa-rotate-right text-gray-700"></i>
                </button>
                <span id="current-date" class="text-sm text-gray-500 font-medium hidden md:inline-block"></span>
            </div>
        </header>

        <div class="flex-1 overflow-auto p-4 md:p-8" id="main-content"></div>
    </div>
</div>

<script>
const DATA = {
    appointments: <%= new com.google.gson.Gson().toJson(appointments) %>,
    queueList: <%= new com.google.gson.Gson().toJson(queueList) %>,
    notifications: <%= new com.google.gson.Gson().toJson(notifications) %>,
    issues: <%= new com.google.gson.Gson().toJson(issues) %>,
    consultations: <%= new com.google.gson.Gson().toJson(consultations) %>,
    searchResults: <%= new com.google.gson.Gson().toJson(searchResults) %>,
    recordResults: <%= new com.google.gson.Gson().toJson(recordResults) %>,
    profile: <%= new com.google.gson.Gson().toJson(profile) %>
};

const state = { activePage: null };

function updateDate() {
    const el = document.getElementById('current-date');
    if (el) {
        el.textContent = new Date().toLocaleDateString('en-US', {
            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
        });
    }
}

function logout() {
    Swal.fire({
        title: 'Confirm logout?',
        text: 'You will leave the doctor dashboard.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Logout',
        cancelButtonText: 'Cancel'
    }).then(r => {
        if (r.isConfirmed) window.location.href = '<%= request.getContextPath() %>/logout';
    });
}

function appointmentStatusBadge(status) {
    const map = {
        1: ['Pending Approval', 'status-pending'],
        2: ['Cancelled', 'status-cancelled'],
        3: ['Approved/Called', 'status-approved'],
        4: ['Consulting', 'status-arrived'],
        5: ['Completed', 'status-completed'],
        6: ['Transferred/No-show', 'status-no-show']
    };
    const v = map[status] || ['Booked', 'status-pending'];
    return `<span class="status-badge ${v[1]}">${v[0]}</span>`;
}

function queueStatusBadge(status) {
    const map = {
        1: ['Waiting', 'status-pending'],
        3: ['Called', 'status-approved'],
        4: ['Consulting', 'status-arrived'],
        5: ['Completed', 'status-completed']
    };
    if (status === 'skipped') return `<span class="status-badge status-no-show">Skipped</span>`;
    const v = map[status] || ['Waiting', 'status-pending'];
    return `<span class="status-badge ${v[1]}">${v[0]}</span>`;
}

function setActiveNav(page) {
    document.querySelectorAll('.nav-item').forEach(el => el.classList.toggle('active', el.dataset.page === page));
    state.activePage = page;
    if (window.innerWidth <= 768) document.getElementById('sidebar').classList.remove('open');
}

function loadSidebar() {
    const unreadCount = DATA.notifications.filter(n => !n.read).length;
    const badgeHtml = unreadCount > 0 ? `<span class="bg-red-500 text-white text-[10px] w-5 h-5 flex items-center justify-center rounded-full ml-auto">${unreadCount}</span>` : '';
    document.getElementById('nav').innerHTML = `
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="dashboard"><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="myAppointments"><i class="fa-solid fa-user-doctor w-5"></i><span>My Appointments</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="appointments"><i class="fa-solid fa-calendar-days w-5"></i><span>All Appointments</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="queue"><i class="fa-solid fa-users-line w-5"></i><span>Queue Management</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="checkin"><i class="fa-solid fa-clipboard-check w-5"></i><span>Consultation</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="search"><i class="fa-solid fa-magnifying-glass w-5"></i><span>Patient Search</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="issues"><i class="fa-solid fa-triangle-exclamation w-5"></i><span>Issue Reporting</span></div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="notifications"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span>${badgeHtml}</div>
        <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="profile"><i class="fa-solid fa-user-gear w-5"></i><span>Profile & Security</span></div>
    `;
    document.getElementById('nav').onclick = (e) => {
        const item = e.target.closest('.nav-item');
        if (!item) return;
        loadPage(item.dataset.page);
    };
}

function apiRequest(url, params, successMsg) {
    return fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(params)
    })
    .then(resp => resp.json().catch(() => ({ success: false, message: 'Server error' })))
    .then(result => {
        if (!result.success) throw new Error(result.message || 'Operation failed');
        return result;
    })
    .then(() => {
        Swal.fire('Success', successMsg, 'success').then(() => {
            loadPage(state.activePage || 'dashboard');
        });
    })
    .catch(err => Swal.fire('Error', err.message || 'Operation failed', 'error'));
}

function approveAppointment(id) {
    Swal.fire({
        title: 'Approve Appointment?',
        text: "This booking will be confirmed.",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#059669',
        confirmButtonText: 'Approve'
    }).then((result) => {
        if (result.isConfirmed) {
            apiRequest('<%= request.getContextPath() %>/doctor/action', { action: 'approve', id: id }, 'Appointment approved.');
        }
    });
}

function rejectAppointment(id) {
    Swal.fire({
        title: 'Reject Appointment',
        input: 'text',
        inputLabel: 'Reason for rejection',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ef4444',
        confirmButtonText: 'Reject',
        preConfirm: (reason) => {
            if (!reason) Swal.showValidationMessage('Please provide a reason');
            return reason;
        }
    }).then((result) => {
        if (result.isConfirmed) {
            apiRequest('<%= request.getContextPath() %>/doctor/action', { action: 'reject', id: id, reason: result.value }, 'Appointment rejected.');
        }
    });
}

function queueAction(id, status) {
    const targetStatus = status === 'skipped' ? 6 : status;
    const actionName = status === 'skipped' ? 'skip' : 'update';
    apiRequest('<%= request.getContextPath() %>/doctor/action', { action: actionName, id: id, status: targetStatus }, 'Status updated successfully.');
}

function setAppointmentStatus(id, status) {
    queueAction(id, status);
}

function callNext() {
    Swal.fire({
        title: 'Call Next Patient?',
        text: "This will call the next waiting patient.",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#059669',
        confirmButtonText: 'Yes, call next'
    }).then((result) => {
        if (result.isConfirmed) {
            apiRequest('<%= request.getContextPath() %>/doctor/action', { action: 'callNext' }, 'Next patient called.');
        }
    });
}

function openDiagnosisModal(id, patientName) {
    Swal.fire({
        title: `Medical Record - ${patientName}`,
        html: `
            <div class="text-left space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Diagnosis</label>
                    <input type="text" id="swal-diagnosis" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="e.g. Viral URI">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Treatment / Prescription</label>
                    <textarea id="swal-treatment" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 h-24" placeholder="Medications, rest advice..."></textarea>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Medical Advice</label>
                    <textarea id="swal-advice" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 h-16" placeholder="Drink water, sleep..."></textarea>
                </div>
            </div>
        `,
        showCancelButton: true,
        confirmButtonText: 'Save & Complete',
        confirmButtonColor: '#4f46e5',
        preConfirm: () => ({
            diagnosis: document.getElementById('swal-diagnosis').value,
            prescription: document.getElementById('swal-treatment').value,
            advice: document.getElementById('swal-advice').value
        })
    }).then((result) => {
        if (result.isConfirmed) {
            apiRequest('<%= request.getContextPath() %>/doctor/consultation', {
                regId: id,
                diagnosis: result.value.diagnosis,
                prescription: result.value.prescription,
                advice: result.value.advice
            }, 'Medical record saved and consultation completed.');
        }
    });
}

function reportNewIssue() {
    Swal.fire({
        title: 'Report Issue',
        input: 'textarea',
        inputPlaceholder: 'System error, equipment down...',
        showCancelButton: true,
        confirmButtonText: 'Submit',
        confirmButtonColor: '#ef4444'
    }).then((result) => {
        if (result.isConfirmed && result.value) {
            apiRequest('<%= request.getContextPath() %>/doctor/issue', { detail: result.value }, 'Issue reported to administration.');
        }
    });
}

function saveDoctorProfile() {
    const newPwd = document.getElementById('doc-new-pwd')?.value;
    const confPwd = document.getElementById('doc-conf-pwd')?.value;
    const oldPwd = document.getElementById('doc-old-pwd')?.value || '';

    if (newPwd && newPwd !== confPwd) {
        Swal.fire('Error', 'New passwords do not match!', 'error');
        return;
    }

    fetch('<%= request.getContextPath() %>/doctor/update-profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            oldPwd: oldPwd,
            newPwd: newPwd || ''
        })
    })
    .then(resp => resp.json().catch(() => ({ success: false, message: 'Server error' })))
    .then(result => {
        if (!result.success) throw new Error(result.message || 'Failed to update profile');
        Swal.fire('Success', 'Profile settings updated successfully.', 'success');
    })
    .catch(err => Swal.fire('Error', err.message || 'Failed to update profile', 'error'));
}

function openAppointmentSummary() {
    const app = DATA.appointments;
    Swal.fire({
        title: 'Today\'s Summary',
        html: `
            <div class="text-left space-y-2 mt-4">
                <div class="flex justify-between pb-2 border-b"><span>Total Booked:</span> <span class="font-bold">${app.length}</span></div>
                <div class="flex justify-between pb-2 border-b"><span>Waiting:</span> <span class="font-bold text-amber-600">${app.filter(a => a.statusCode === 1).length}</span></div>
                <div class="flex justify-between pb-2 border-b"><span>Consulting:</span> <span class="font-bold text-blue-600">${app.filter(a => a.statusCode === 4).length}</span></div>
                <div class="flex justify-between"><span>Completed:</span> <span class="font-bold text-emerald-600">${app.filter(a => a.statusCode === 5).length}</span></div>
            </div>
        `,
        confirmButtonText: 'Close'
    });
}

function openAppointmentHistory(patientName) {
    const records = (DATA.recordResults || []).filter(r =>
        String(r.patient || r.patientName || '').includes(patientName)
    );

    Swal.fire({
        title: `${patientName}'s History`,
        html: `
            <div class="text-left max-h-80 overflow-y-auto mt-4 space-y-3 pr-2">
                ${records.length ? records.map(r => `
                    <div class="p-3 bg-gray-50 border rounded-xl">
                        <p class="font-semibold text-sm">${r.consultationTime || r.date || '-'} ｜ ${r.departmentName || r.service || 'Consultation'}</p>
                        <p class="text-sm text-gray-600 mt-1">
                            Diagnosis: ${r.diagnosis || 'None'}<br>
                            Advice: ${r.medicalAdvice || r.advice || 'None'}
                        </p>
                    </div>
                `).join('') : '<div class="py-6 text-center text-gray-500">No history found.</div>'}
            </div>
        `,
        confirmButtonText: 'Close'
    });
}

function performSearch() {
    const key = document.getElementById('search-key')?.value || '';
    if (!key.trim()) {
        Swal.fire('Warning', 'Please enter search keyword.', 'warning');
        return;
    }
    window.location.href = '?keyword=' + encodeURIComponent(key);
}

function loadPage(page) {
    if (state.activePage === page) return;
    setActiveNav(page);

    const c = document.getElementById('main-content');
    c.style.transition = 'none';
    c.style.opacity = '0';
    c.style.transform = 'translate3d(0, 10px, 0)';

    const app = DATA.appointments;
    const q = DATA.queueList;
    const issues = DATA.issues;
    const waitingCount = q.filter(x => x.statusCode === 1 || x.statusCode === 3).length;
    const eta = waitingCount * 8;

    if (page === 'dashboard') {
        document.getElementById('page-title').textContent = 'Dashboard';
        document.getElementById('page-subtitle').textContent = 'Today’s clinic overview';
        c.innerHTML = `
            <div class="max-w-7xl mx-auto space-y-8">
                <div class="text-left flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                    <div>
                        <h1 class="text-3xl md:text-4xl font-bold text-gray-800 mb-2">Welcome, <%= doctorName %></h1>
                        <p class="text-gray-500 text-base md:text-lg"><%= departmentName %> ｜ <%= todayStr %></p>
                    </div>
                    <div class="flex gap-3 flex-wrap">
                        <button onclick="openAppointmentSummary()" class="px-4 py-2 rounded-xl bg-emerald-600 text-white font-medium hover:bg-emerald-700 transition">Today Summary</button>
                        <button onclick="loadPage('myAppointments')" class="px-4 py-2 rounded-xl bg-blue-600 text-white font-medium hover:bg-blue-700 transition">My Appointments</button>
                    </div>
                </div>

                <div class="grid grid-cols-2 xl:grid-cols-4 gap-6">
                    <div class="home-card glass rounded-3xl p-6 text-center">
                        <i class="fa-solid fa-calendar-days text-blue-600 text-4xl mb-4"></i>
                        <div class="text-4xl md:text-5xl font-bold text-blue-600">${app.length}</div>
                        <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Total Booked</p>
                    </div>
                    <div class="home-card glass rounded-3xl p-6 text-center">
                        <i class="fa-solid fa-users-line text-emerald-600 text-4xl mb-4"></i>
                        <div class="text-4xl md:text-5xl font-bold text-emerald-600">${q.length}</div>
                        <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Queue Count</p>
                    </div>
                    <div class="home-card glass rounded-3xl p-6 text-center">
                        <i class="fa-solid fa-clipboard-check text-amber-600 text-4xl mb-4"></i>
                        <div class="text-4xl md:text-5xl font-bold text-amber-600">${app.filter(x => x.statusCode === 4).length}</div>
                        <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Consulting Now</p>
                    </div>
                    <div class="home-card glass rounded-3xl p-6 text-center">
                        <i class="fa-solid fa-check-double text-indigo-600 text-4xl mb-4"></i>
                        <div class="text-4xl md:text-5xl font-bold text-indigo-600">${app.filter(x => x.statusCode === 5).length}</div>
                        <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Completed</p>
                    </div>
                </div>

                <div class="glass rounded-3xl p-6">
                    <h3 class="text-xl font-semibold mb-4">Quick Actions</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        <button onclick="loadPage('myAppointments')" class="home-card p-5 rounded-2xl bg-white border text-left flex flex-col justify-center">
                            <i class="fa-solid fa-user-doctor text-blue-600 text-2xl mb-3"></i>
                            <p class="font-semibold text-gray-800">My Appointments</p>
                            <p class="text-xs text-gray-500 mt-1">View your schedule</p>
                        </button>
                        <button onclick="loadPage('appointments')" class="home-card p-5 rounded-2xl bg-white border text-left flex flex-col justify-center">
                            <i class="fa-solid fa-clipboard-list text-emerald-600 text-2xl mb-3"></i>
                            <p class="font-semibold text-gray-800">Approve Booking</p>
                            <p class="text-xs text-gray-500 mt-1">Review appointment requests</p>
                        </button>
                        <button onclick="loadPage('queue')" class="home-card p-5 rounded-2xl bg-white border text-left flex flex-col justify-center">
                            <i class="fa-solid fa-bullhorn text-indigo-600 text-2xl mb-3"></i>
                            <p class="font-semibold text-gray-800">Call / Skip Patient</p>
                            <p class="text-xs text-gray-500 mt-1">Manage waiting list</p>
                        </button>
                        <button onclick="loadPage('search')" class="home-card p-5 rounded-2xl bg-white border text-left flex flex-col justify-center">
                            <i class="fa-solid fa-magnifying-glass text-amber-600 text-2xl mb-3"></i>
                            <p class="font-semibold text-gray-800">Patient Search</p>
                            <p class="text-xs text-gray-500 mt-1">Find history records</p>
                        </button>
                    </div>
                </div>
            </div>
        `;
    }
    else if (page === 'myAppointments') {
        document.getElementById('page-title').textContent = 'My Appointments';
        document.getElementById('page-subtitle').textContent = 'Patients assigned to you';
        const myList = app.filter(x => x.statusCode !== 2);
        c.innerHTML = `
            <div class="glass rounded-3xl p-6">
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
                    <h3 class="text-2xl font-semibold">My Consultation List</h3>
                </div>
                <div class="space-y-3">
                    ${myList.length ? myList.map(item => `
                        <div class="queue-card p-5 border rounded-2xl bg-white flex flex-col lg:flex-row lg:items-center justify-between gap-4 shadow-sm">
                            <div>
                                <div class="flex items-center gap-3 mb-1">
                                    <p class="font-bold text-lg text-gray-800">${item.patient}</p>
                                    ${appointmentStatusBadge(item.statusCode)}
                                </div>
                                <p class="text-sm text-gray-600 font-medium">${item.service || '-'} ｜ ${item.date} ${item.time || ''}</p>
                                <p class="text-xs text-gray-400 mt-2">Ticket: ${item.ticketNo || '-'} &nbsp; Phone: ${item.phone || '-'}</p>
                            </div>
                            <div class="flex gap-2 flex-wrap lg:justify-end">
                                <button onclick="setAppointmentStatus(${item.id}, 3)" class="px-4 py-2 text-sm font-medium bg-blue-50 text-blue-700 hover:bg-blue-100 rounded-xl transition">Call</button>
                                <button onclick="openDiagnosisModal(${item.id}, '${item.patient}')" class="px-4 py-2 text-sm font-medium bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-xl transition">Consult</button>
                                <button onclick="openAppointmentHistory('${item.patient}')" class="px-4 py-2 text-sm font-medium bg-gray-50 text-gray-700 hover:bg-gray-100 rounded-xl transition">History</button>
                            </div>
                        </div>
                    `).join('') : '<div class="py-12 text-center text-gray-500"><i class="fa-regular fa-calendar-xmark text-4xl mb-3"></i><p>No assigned appointments found.</p></div>'}
                </div>
            </div>
        `;
    }
    else if (page === 'appointments') {
        document.getElementById('page-title').textContent = 'All Appointments';
        document.getElementById('page-subtitle').textContent = 'Approve or Reject Bookings';
        c.innerHTML = `
            <div class="glass rounded-3xl p-6">
                <h3 class="text-2xl font-semibold mb-6">Appointment Management</h3>
                <div class="overflow-x-auto">
                    <table class="w-full text-sm min-w-[900px] text-left">
                        <thead class="border-b bg-gray-50 text-gray-600">
                            <tr>
                                <th class="py-4 px-4 rounded-tl-xl">Date & Time</th>
                                <th class="py-4 px-4">Ticket No.</th>
                                <th class="py-4 px-4">Patient Name</th>
                                <th class="py-4 px-4">Service</th>
                                <th class="py-4 px-4">Status</th>
                                <th class="py-4 px-4 rounded-tr-xl text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            ${app.length ? app.map(a => `
                                <tr class="hover:bg-gray-50/50 transition">
                                    <td class="py-4 px-4 font-medium">${a.date} ${a.time || ''}</td>
                                    <td class="px-4 text-gray-500">${a.ticketNo || a.regNo || '-'}</td>
                                    <td class="px-4 font-bold text-gray-800">${a.patient || '-'}</td>
                                    <td class="px-4 text-gray-600">${a.service || a.departmentName || '-'}</td>
                                    <td class="px-4">${appointmentStatusBadge(a.statusCode)}</td>
                                    <td class="px-4 text-center">
                                        ${a.statusCode === 1 ? `
                                            <button onclick="approveAppointment(${a.id})" class="px-3 py-1.5 mr-1 bg-green-50 text-green-700 font-medium rounded-lg hover:bg-green-100 transition border border-green-200"><i class="fa-solid fa-check mr-1"></i>Approve</button>
                                            <button onclick="rejectAppointment(${a.id})" class="px-3 py-1.5 bg-red-50 text-red-700 font-medium rounded-lg hover:bg-red-100 transition border border-red-200"><i class="fa-solid fa-xmark mr-1"></i>Reject</button>
                                        ` : '<span class="text-gray-400 text-xs font-medium">Processed</span>'}
                                    </td>
                                </tr>
                            `).join('') : `<tr><td colspan="6" class="text-center py-10 text-gray-500">No appointment records found.</td></tr>`}
                        </tbody>
                    </table>
                </div>
            </div>
        `;
    }
    else if (page === 'queue') {
        document.getElementById('page-title').textContent = 'Queue Management';
        document.getElementById('page-subtitle').textContent = 'Manage live patient flow';
        c.innerHTML = `
            <div class="glass rounded-3xl p-6">
                <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6">
                    <h3 class="text-2xl font-semibold">Live Queue</h3>
                    <div class="flex items-center gap-3 w-full md:w-auto">
                        <span class="px-4 py-2 rounded-xl bg-blue-50 text-blue-700 text-sm font-medium hidden md:inline-block">ETA: ${eta} mins</span>
                        <button onclick="callNext()" class="flex-1 md:flex-none px-6 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-medium transition shadow-sm">Call Next</button>
                    </div>
                </div>
                <div class="space-y-3">
                    ${q.length ? q.map(item => `
                        <div class="queue-card p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm">
                            <div>
                                <div class="flex items-center gap-3">
                                    <span class="font-mono font-bold text-lg text-indigo-600">${item.queueNo || '-'}</span>
                                    <p class="font-bold text-gray-800">${item.patient || '-'}</p>
                                    ${queueStatusBadge(item.statusCode)}
                                </div>
                                <p class="text-sm text-gray-500 mt-1">${item.service || '-'} ｜ Phone: ${item.phone || '-'}</p>
                            </div>
                            <div class="flex items-center gap-2 flex-wrap">
                                <button onclick="queueAction(${item.id}, 3)" class="px-4 py-2 text-sm font-medium bg-blue-50 text-blue-700 hover:bg-blue-100 rounded-xl transition shadow-sm">Call</button>
                                <button onclick="queueAction(${item.id}, 4)" class="px-4 py-2 text-sm font-medium bg-indigo-50 text-indigo-700 hover:bg-indigo-100 rounded-xl transition shadow-sm">Consulting</button>
                                <button onclick="queueAction(${item.id}, 5)" class="px-4 py-2 text-sm font-medium bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-xl transition shadow-sm">Complete</button>
                                <button onclick="queueAction(${item.id}, 'skipped')" class="px-4 py-2 text-sm font-medium bg-red-50 text-red-600 hover:bg-red-100 border border-red-100 rounded-xl transition shadow-sm">Skip (No Show)</button>
                            </div>
                        </div>
                    `).join('') : '<div class="text-center py-12 text-gray-500"><i class="fa-solid fa-users-slash text-4xl mb-3"></i><p>Queue is empty.</p></div>'}
                </div>
            </div>
        `;
    }
    else if (page === 'checkin') {
        document.getElementById('page-title').textContent = 'Consultation';
        document.getElementById('page-subtitle').textContent = 'Write and manage medical records';
        c.innerHTML = `
            <div class="glass rounded-3xl p-6">
                <h3 class="text-2xl font-semibold mb-6">Pending Consultations</h3>
                <div class="space-y-3">
                    ${app.filter(a => a.statusCode === 3 || a.statusCode === 4).length ? app.filter(a => a.statusCode === 3 || a.statusCode === 4).map(a => `
                        <div class="queue-card p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm">
                            <div>
                                <p class="font-bold text-lg text-gray-800">${a.patient}</p>
                                <p class="text-sm text-gray-500">${a.service} ｜ ${a.ticketNo || '-'}</p>
                            </div>
                            <div class="flex gap-2">
                                <button onclick="openDiagnosisModal(${a.id}, '${a.patient}')" class="px-5 py-2 text-sm font-medium bg-indigo-600 text-white hover:bg-indigo-700 rounded-xl transition shadow-sm">Write Record</button>
                            </div>
                        </div>
                    `).join('') : '<div class="py-10 text-center text-gray-500">No patients are currently called or in consultation.</div>'}
                </div>
            </div>
        `;
    }
    else if (page === 'search') {
        document.getElementById('page-title').textContent = 'Patient Search';
        document.getElementById('page-subtitle').textContent = 'Lookup patient records';
        c.innerHTML = `
            <div class="glass rounded-3xl p-6 max-w-4xl">
                <h3 class="text-2xl font-bold mb-6">Patient Lookup</h3>
                <div class="flex flex-col md:flex-row gap-3 mb-6">
                    <input id="search-key" placeholder="Enter name, phone, or ticket no..." class="flex-1 p-3 border rounded-xl outline-none focus:ring-2 focus:ring-sky-500 transition">
                    <button class="px-6 py-3 bg-sky-600 hover:bg-sky-700 text-white font-medium rounded-xl transition" onclick="performSearch()">Search</button>
                </div>
                <div class="space-y-3">
                    ${DATA.searchResults.length ? DATA.searchResults.map(r => `
                        <div class="p-4 border rounded-2xl bg-white shadow-sm">
                            <p class="font-bold text-gray-800">${r.patient || r.name || '-'}</p>
                            <p class="text-sm text-gray-600 mt-1">${r.phone || ''}</p>
                            <p class="text-xs text-gray-400 mt-2">${r.note || ''}</p>
                        </div>
                    `).join('') : '<div class="p-8 border-2 border-dashed rounded-2xl text-center text-gray-400"><i class="fa-solid fa-magnifying-glass text-3xl mb-2"></i><p>Enter details above to search records.</p></div>'}
                </div>
            </div>
        `;
    }
    else if (page === 'issues') {
        document.getElementById('page-title').textContent = 'Issue Reporting';
        document.getElementById('page-subtitle').textContent = 'Report operational issues';
        c.innerHTML = `
            <div class="glass rounded-3xl p-6">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="text-2xl font-semibold">Reported Issues</h3>
                    <button onclick="reportNewIssue()" class="px-4 py-2 bg-red-50 text-red-600 font-medium rounded-xl hover:bg-red-100 transition border border-red-200">Report New</button>
                </div>
                <div class="space-y-3">
                    ${issues.length ? issues.map(i => `
                        <div class="p-4 border rounded-2xl bg-white border-l-4 shadow-sm ${i.status === 'Resolved' ? 'border-l-emerald-500' : 'border-l-red-500'}">
                            <div class="flex justify-between items-start mb-1">
                                <p class="font-bold text-gray-800">${i.type || 'Issue'}</p>
                                <span class="text-xs px-2 py-1 rounded bg-gray-100 font-medium border border-gray-200">${i.status || 'Pending'}</span>
                            </div>
                            <p class="text-sm text-gray-600 mb-2">${i.detail || '-'}</p>
                            <p class="text-xs text-gray-400"><i class="fa-regular fa-clock"></i> ${i.createdAt || ''}</p>
                        </div>
                    `).join('') : '<p class="text-center py-10 text-gray-500">No issues reported.</p>'}
                </div>
            </div>
        `;
    }
    else if (page === 'notifications') {
        document.getElementById('page-title').textContent = 'Notifications';
        document.getElementById('page-subtitle').textContent = 'System and clinic alerts';
        c.innerHTML = `
            <div class="glass rounded-3xl p-6 max-w-4xl">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="text-2xl font-semibold">Recent Alerts</h3>
                    <button class="text-sm text-blue-600 hover:underline font-medium" onclick="Swal.fire('Marked', 'All marked as read', 'success')">Mark all as read</button>
                </div>
                <div class="space-y-3">
                    ${DATA.notifications.length ? DATA.notifications.map(n => `
                        <div class="p-4 border rounded-2xl bg-white flex gap-4 items-start shadow-sm ${n.read ? 'opacity-70' : ''}">
                            <div class="mt-1 w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${n.type === 'warning' ? 'bg-yellow-100 text-yellow-600' : n.type === 'success' ? 'bg-emerald-100 text-emerald-600' : 'bg-blue-100 text-blue-600'}">
                                <i class="fa-solid ${n.type === 'warning' ? 'fa-triangle-exclamation' : 'fa-bell'}"></i>
                            </div>
                            <div>
                                <p class="font-semibold text-gray-800">${n.title || 'Notice'}</p>
                                <p class="text-sm text-gray-600 mt-1">${n.msg || n.message || '-'}</p>
                                <p class="text-xs text-gray-400 mt-2">${n.time || ''}</p>
                            </div>
                        </div>
                    `).join('') : '<div class="py-10 text-center text-gray-500">No notifications.</div>'}
                </div>
            </div>
        `;
    }
    else if (page === 'profile') {
        document.getElementById('page-title').textContent = 'Profile & Security';
        document.getElementById('page-subtitle').textContent = 'Your account details and password';
        c.innerHTML = `
            <div class="max-w-3xl mx-auto glass rounded-3xl p-8">
                <div class="flex items-center gap-6 mb-8 pb-8 border-b">
                    <img src="<%= doctorAvatar %>" class="w-24 h-24 rounded-full ring-4 ring-sky-50 object-cover shadow-sm" alt="avatar">
                    <div>
                        <h3 class="text-2xl font-bold text-gray-800"><%= doctorName %></h3>
                        <p class="text-sky-600 font-medium mt-1"><%= doctorTitle %> ｜ <%= departmentName %></p>
                    </div>
                </div>
                <h4 class="text-lg font-bold text-gray-800 mb-4"><i class="fa-solid fa-address-card text-gray-400 mr-2"></i> Basic Information</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div><label class="block text-sm font-medium text-gray-600 mb-1">Full Name</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-700 outline-none" value="<%= doctorName %>" readonly></div>
                    <div><label class="block text-sm font-medium text-gray-600 mb-1">Title</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-700 outline-none" value="<%= doctorTitle %>" readonly></div>
                    <div class="md:col-span-2"><label class="block text-sm font-medium text-gray-600 mb-1">Department</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-700 outline-none" value="<%= departmentName %>" readonly></div>
                </div>
                <div class="mt-10 pt-8 border-t border-gray-200">
                    <h4 class="text-lg font-bold text-gray-800 mb-6"><i class="fa-solid fa-lock text-gray-400 mr-2"></i> Change Password</h4>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-600 mb-1">Current Password</label>
                            <input type="password" id="doc-old-pwd" class="w-full p-3 border rounded-xl bg-white focus:ring-2 focus:ring-sky-500 outline-none transition shadow-sm" placeholder="Leave blank if not changing">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600 mb-1">New Password</label>
                            <input type="password" id="doc-new-pwd" class="w-full p-3 border rounded-xl bg-white focus:ring-2 focus:ring-sky-500 outline-none transition shadow-sm" placeholder="Enter new password">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-600 mb-1">Confirm New Password</label>
                            <input type="password" id="doc-conf-pwd" class="w-full p-3 border rounded-xl bg-white focus:ring-2 focus:ring-sky-500 outline-none transition shadow-sm" placeholder="Re-enter new password">
                        </div>
                    </div>
                </div>
                <div class="mt-8 pt-4 flex justify-end gap-3">
                    <button onclick="saveDoctorProfile()" class="px-8 py-3 bg-sky-600 text-white rounded-xl font-bold hover:bg-sky-700 transition shadow-md">Save Changes</button>
                </div>
            </div>
        `;
    }

    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            c.style.transition = 'opacity 0.2s ease-out, transform 0.2s ease-out';
            c.style.opacity = '1';
            c.style.transform = 'translate3d(0, 0, 0)';
        });
    });
}

document.getElementById('menu-btn').addEventListener('click', function() {
    document.getElementById('sidebar').classList.add('open');
});
document.getElementById('close-menu-btn').addEventListener('click', function() {
    document.getElementById('sidebar').classList.remove('open');
});

window.onload = () => {
    updateDate();
    loadSidebar();
    loadPage('dashboard');
};
</script>
</body>
</html>