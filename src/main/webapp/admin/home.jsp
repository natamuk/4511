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
<html lang="zh-TW">
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
        .glass { background: rgba(255, 255, 255, 0.95); border: 1px solid rgba(255, 255, 255, 0.6); box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); }
        .nav-item { transition: background-color 0.2s ease, transform 0.2s ease, color 0.2s ease; cursor: pointer; }
        .nav-item:hover { transform: translateX(8px); background: rgba(99,102,241,0.1); }
        .nav-item.active { background: rgba(99,102,241,0.14); color: #4f46e5; font-weight: 700; }
        .card { transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .card:hover { transform: translateY(-4px); box-shadow: 0 15px 30px rgba(0,0,0,0.08); }
        .badge { display: inline-flex; align-items: center; gap: .35rem; padding: .35rem .7rem; border-radius: 999px; font-size: .75rem; font-weight: 700; white-space: nowrap; }
        .badge-success { background:#dcfce7; color:#166534; }
        .badge-warning { background:#fef3c7; color:#92400e; }
        .badge-danger { background:#fee2e2; color:#b91c1c; }
        .badge-info { background:#dbeafe; color:#1d4ed8; }
        #main-content { opacity: 0; transform: translate3d(0, 10px, 0); will-change: opacity, transform; contain: layout paint; }
        #sidebar { width: 320px; }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
    <aside id="sidebar" class="glass shadow-2xl flex flex-col border-r border-white/50 z-40 fixed h-full left-0 top-0">
        <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <i class="fa-solid fa-user-shield text-4xl"></i>
                    <div>
                        <h1 class="text-2xl font-bold">CCHC</h1>
                        <p class="text-sm opacity-90">Admin Console</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="p-6 flex-1 flex flex-col overflow-y-auto pl-10 pr-6">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img id="sidebar-avatar" src="<%= (avatar != null && !avatar.isEmpty()) ? avatar : "https://ui-avatars.com/api/?name=Admin&background=4f46e5&color=fff&size=200" %>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
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

    <div class="flex-1 flex flex-col min-w-0 ml-[320px]">
        <header class="glass border-b px-8 py-4 flex justify-between items-center z-10 relative">
            <div>
                <h2 id="page-title" class="text-2xl font-semibold">Dashboard</h2>
                <p id="page-subtitle" class="text-sm text-gray-500 mt-1">Overview and administration</p>
            </div>
            <div class="flex items-center gap-3">
                <button onclick="refreshCurrentPage()" class="p-2 hover:bg-gray-100 rounded-xl transition" title="Refresh">
                    <i class="fa-solid fa-rotate-right text-gray-700"></i>
                </button>
                <button onclick="loadPage('notifications')" class="relative p-2 hover:bg-gray-100 rounded-xl transition" title="Notifications">
                    <i class="fa-solid fa-bell text-xl text-gray-700"></i>
                    <span id="notif-count" class="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] font-bold w-5 h-5 flex items-center justify-center rounded-full hidden">0</span>
                </button>
                <span id="current-date" class="text-sm text-gray-500 font-medium inline-block"></span>
            </div>
        </header>
        <div class="flex-1 overflow-auto p-6" id="main-content"></div>
    </div>
</div>

<script>
// ====================== 狀態與數據初始化 ======================
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
const avatarJS = <%= new com.google.gson.Gson().toJson(avatar != null && !avatar.isEmpty() ? avatar : "https://ui-avatars.com/api/?name=Admin&background=4f46e5&color=fff&size=200") %> || "";
const state = { activePage: null };

// ====================== 基礎共用函數 ======================
function refreshCurrentPage() {
    if (state.activePage) renderPage(state.activePage);
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

async function ajaxOperation(url, params, successMessage, refreshPage = true) {
    try {
        const resp = await fetch('<%= request.getContextPath() %>' + url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(params)
        });
        const data = await parseResponseSafe(resp, '操作失敗');

        if (data.success) {
            Swal.fire({ icon: 'success', title: '成功', text: successMessage, timer: 1600, showConfirmButton: false });
            if (refreshPage) refreshCurrentPage();
        } else {
            Swal.fire('失敗', data.message || '操作失敗', 'error');
        }
    } catch (err) {
        Swal.fire('錯誤', err.message || '伺服器錯誤', 'error');
    }
}

function updateDate() {
    const el = document.getElementById('current-date');
    if (el) el.textContent = new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
}

function setActiveNav(page) {
    document.querySelectorAll('.nav-item').forEach(el => el.classList.toggle('active', el.dataset.page === page));
    state.activePage = page;
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
            sidebarBadge.className = 'ml-auto bg-red-500 text-white text-[10px] font-bold w-5 h-5 flex items-center justify-center rounded-full';
        } else {
            sidebarBadge.className = 'hidden';
        }
    }
}

// ====================== 業務邏輯與操作函數 ======================
function logout() {
    Swal.fire({
        title: 'Confirm logout?', text: 'You will leave the admin console', icon: 'warning',
        showCancelButton: true, confirmButtonText: 'Logout', cancelButtonText: 'Cancel'
    }).then(r => {
        if (r.isConfirmed) window.location.href = '<%= request.getContextPath() %>/logout';
    });
}

async function markAllRead() {
    const result = await Swal.fire({ title: '全部標為已讀？', icon: 'question', showCancelButton: true, confirmButtonText: '確認' });
    if (!result.isConfirmed) return;
    try {
        const resp = await fetch('<%= request.getContextPath() %>/admin/notifications/mark-all-read', { method: 'POST' });
        const data = await parseResponseSafe(resp, '標記失敗');
        if (data.success) {
            notifications.forEach(n => n.read = true);
            updateNotificationCount();
            if (state.activePage === 'notifications') loadPage('notifications');
            Swal.fire('完成', '所有通知已標為已讀', 'success');
        }
    } catch (err) { Swal.fire('錯誤', err.message, 'error'); }
}

function saveAdminProfile() {
    const newPwd = document.getElementById('admin-new-pwd')?.value || '';
    const confPwd = document.getElementById('admin-conf-pwd')?.value || '';
    if (newPwd && newPwd !== confPwd) return Swal.fire({ icon: 'error', title: 'Password Mismatch', text: 'New password and confirmation do not match!' });
    fetch('<%= request.getContextPath() %>/admin/update-profile', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ oldPwd: document.getElementById('admin-old-pwd')?.value || '', newPwd: newPwd })
    })
    .then(resp => parseResponseSafe(resp, 'Failed to update profile'))
    .then(res => {
        if (res.success) Swal.fire({ icon: 'success', title: 'Profile Updated', text: 'Security settings have been saved successfully.', timer: 2000, showConfirmButton: false });
        else Swal.fire('Error', res.message || 'Failed to update profile', 'error');
    }).catch(err => Swal.fire('Error', err.message || 'Server communication error', 'error'));
}

function saveGlobalSettings() {
    const maxBookings = document.getElementById('st-max')?.value;
    const cancelDeadline = document.getElementById('st-cancel')?.value;
    if (!maxBookings || !cancelDeadline) return Swal.fire('錯誤', '請先填寫所有設定欄位', 'error');
    fetch('<%= request.getContextPath() %>/admin/settings/update', {
        method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ max_active_bookings_per_patient: maxBookings, cancel_deadline_hours: cancelDeadline })
    })
    .then(resp => parseResponseSafe(resp, '儲存設定失敗'))
    .then(res => {
        if (res.success) Swal.fire({ icon: 'success', title: 'Settings Saved', text: '全局設定已成功儲存。', timer: 2000, showConfirmButton: false });
        else Swal.fire('Error', res.message || '儲存失敗', 'error');
    }).catch(err => Swal.fire('Error', err.message || 'Server communication error', 'error'));
}

// ====================== 重構後獨立的操作函數 ======================

window.addUser = function() {
    Swal.fire({
        title: '建立新用戶',
        html: `
            <div class="space-y-3 mt-4 text-left">
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">帳號類型</label>
                    <select id="swal-type" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500">
                        <option value="patient">患者 (Patient)</option>
                        <option value="doctor">醫生 / 職員 (Doctor / Staff)</option>
                        <option value="admin">系統管理員 (Admin)</option>
                    </select>
                </div>
                <div><label class="block text-sm font-bold text-gray-700 mb-1">真實姓名 *</label><input id="swal-name" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="請輸入姓名"></div>
                <div><label class="block text-sm font-bold text-gray-700 mb-1">登入帳號 *</label><input id="swal-user" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="請輸入 Username"></div>
                <div><label class="block text-sm font-bold text-gray-700 mb-1">登入密碼 *</label><input type="password" id="swal-pass" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="請設定密碼"></div>
            </div>
        `,
        showCancelButton: true, confirmButtonText: '立即建立',
        preConfirm: () => ({
            type: document.getElementById('swal-type').value,
            name: document.getElementById('swal-name').value.trim(),
            user: document.getElementById('swal-user').value.trim(),
            pass: document.getElementById('swal-pass').value
        })
    }).then(r => {
        if (!r.isConfirmed) return;
        const data = r.value;
        if (!data.name || !data.user || !data.pass) return Swal.fire('錯誤', '姓名、帳號、密碼為必填欄位', 'error');
        fetch('<%= request.getContextPath() %>/admin/user/create', {
            method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({ type: data.type, realName: data.name, username: data.user, password: data.pass })
        })
        .then(resp => parseResponseSafe(resp, '建立失敗'))
        .then(res => {
            if (res.success) Swal.fire('成功', '用戶已建立！', 'success').then(() => refreshCurrentPage());
            else Swal.fire('失敗', res.message || '建立失敗', 'error');
        }).catch(err => Swal.fire('錯誤', err.message, 'error'));
    });
};

window.editUser = function(id, type) {
    const list = type === 'doctor' ? doctorUsers : patientUsers;
    const user = list.find(u => String(u.id) === String(id)) || {};
    Swal.fire({
        title: type === 'doctor' ? '編輯醫生資料' : '編輯患者資料',
        html: `
            <div class="space-y-4 mt-4 text-left">
                <div><label class="block text-sm font-bold text-gray-700 mb-1">真實姓名</label><input id="edit-realName" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" value="\${user.name || ''}"></div>
                <div><label class="block text-sm font-bold text-gray-700 mb-1">聯絡電話</label><input id="edit-phone" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" value="\${user.phone || ''}"></div>
                <div><label class="block text-sm font-bold text-gray-700 mb-1">電子信箱</label><input id="edit-email" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" value="\${user.email || ''}"></div>
                \${type === 'doctor' ? `<div><label class="block text-sm font-bold text-gray-700 mb-1">職稱 (Title)</label><input id="edit-title" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" value="\${user.title || ''}"></div>` : ''}
            </div>
        `,
        showCancelButton: true, confirmButtonText: '儲存修改',
        preConfirm: () => ({
            realName: document.getElementById('edit-realName').value.trim(),
            phone: document.getElementById('edit-phone').value.trim(),
            email: document.getElementById('edit-email').value.trim(),
            title: type === 'doctor' ? document.getElementById('edit-title').value.trim() : null
        })
    }).then(result => {
        if (result.isConfirmed) {
            const data = result.value;
            ajaxOperation('/admin/user/update', { id: id, type: type, realName: data.realName, phone: data.phone, email: data.email, title: data.title || '' }, '用戶資料已成功更新！');
        }
    });
};

window.deleteUser = function(id, type) {
    Swal.fire({
        title: 'Delete User?', text: "This will disable the user account.", icon: 'warning',
        showCancelButton: true, confirmButtonColor: '#ef4444', confirmButtonText: 'Yes, delete it!'
    }).then((result) => {
        if (!result.isConfirmed) return;
        ajaxOperation('/admin/user/manage', { id: id, type: type, action: 'disable' }, 'User has been disabled.');
    });
};

window.disableClinic = function(id) {
    Swal.fire({
        title: '確認停用診所？', text: '停用後此分院將無法接受預約。', icon: 'warning',
        showCancelButton: true, confirmButtonColor: '#ef4444', confirmButtonText: '確認停用', cancelButtonText: '取消'
    }).then(result => {
        if (!result.isConfirmed) return;
        ajaxOperation('/admin/clinic/manage', { action: 'disable', id: id }, 'Clinic has been disabled.', true);
    });
};

window.addClinic = function() {
    Swal.fire({
        title: '新增診所分院',
        html: `
            <div class="space-y-3 mt-4 text-left">
                <div><label class="block text-sm font-bold text-gray-700 mb-1">診所名稱 *</label><input id="clinic-name" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="請輸入診所名稱"></div>
                <div><label class="block text-sm font-bold text-gray-700 mb-1">地址 *</label><input id="clinic-addr" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="請輸入診所地址"></div>
            </div>
        `,
        showCancelButton: true, confirmButtonText: '立即建立', cancelButtonText: '取消',
        preConfirm: () => ({
            name: document.getElementById('clinic-name').value.trim(),
            address: document.getElementById('clinic-addr').value.trim()
        })
    }).then(r => {
        if (!r.isConfirmed) return;
        if (!r.value.name || !r.value.address) return Swal.fire('錯誤', '診所名稱與地址為必填欄位', 'error');
        ajaxOperation('/admin/clinic/create', { name: r.value.name, address: r.value.address }, '診所已成功建立！', true);
    });
};

window.reassignDoctor = function(appointmentId) {
    const availableDoctors = doctorUsers.filter(d => d.status === 'active');
    if (!availableDoctors.length) return Swal.fire('提示', '目前無可用的醫生資料，請先新增醫生帳號。', 'info');

    const options = availableDoctors.map(d => `<option value="\${d.id}">\${d.name} (\${d.title || 'Doctor'})</option>`).join('');
    Swal.fire({
        title: '重新指派醫生',
        html: `<div class="text-left mt-4"><label class="block text-sm font-bold text-gray-700 mb-2">選擇新醫生</label><select id="reassign-doctor" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500">\${options}</select></div>`,
        showCancelButton: true, confirmButtonText: '確認指派', cancelButtonText: '取消',
        preConfirm: () => document.getElementById('reassign-doctor').value
    }).then(r => {
        if (r.isConfirmed && r.value) {
            ajaxOperation('/admin/appointment/reassign', { appointmentId: appointmentId, doctorId: r.value }, '醫生已成功重新指派。', true);
        }
    });
};

window.editQuota = function(id, currentCapacity) {
    Swal.fire({
        title: '修改配額容量',
        html: `
            <div class="text-left mt-4 space-y-2">
                <label class="block text-sm font-bold text-gray-700">新的最大容量</label>
                <input id="qt-cap" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500" placeholder="請輸入容量數字" value="\${currentCapacity}">
            </div>
        `,
        showCancelButton: true,
        confirmButtonText: '確認儲存',
        preConfirm: () => document.getElementById('qt-cap').value
    }).then(r => {
        if (r.isConfirmed) {
            ajaxOperation('/admin/quota/update', { id: id, capacity: r.value }, '配額容量已成功更新');
        }
    });
};

window.updateAppointmentStatus = function(id, selectElement) {
    const newStatus = selectElement.value;
    if (!newStatus) return;
    Swal.fire({
        title: '確認更改狀態？',
        text: `確定要將這筆預約狀態更改為 "\${newStatus}" 嗎？`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: '確認更改',
        cancelButtonText: '取消'
    }).then(r => {
        if (r.isConfirmed) {
            ajaxOperation('/admin/appointment/update', { id: id, status: newStatus }, '預約狀態已更新', true);
        } else {
            refreshCurrentPage();
        }
    });
};

// ====================== 頁面渲染模組 (Page Renderers) ======================
function renderDashboard(c) {
    document.getElementById('page-title').textContent = 'Dashboard';
    document.getElementById('page-subtitle').textContent = 'Overview and live status';
    const noShowCount = appointments.filter(x => (x.status || '').toLowerCase() === 'no_show').length;
    const cancelCount = appointments.filter(x => (x.status || '').toLowerCase() === 'cancelled').length;
    
    c.innerHTML = `
        <div class="max-w-7xl mx-auto space-y-8">
            <div class="flex items-end justify-between gap-4">
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
                <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Total Appointments</div><div class="text-4xl font-bold text-indigo-600 mt-2">\${appointments.length}</div><div class="text-xs text-gray-400 mt-2">All appointment records</div></div>
                <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">Queue Waiting</div><div class="text-4xl font-bold text-emerald-600 mt-2">\${queueList.length}</div><div class="text-xs text-gray-400 mt-2">Same-day queue patients</div></div>
                <div class="card glass p-6 rounded-3xl"><div class="text-sm text-gray-500 font-medium">No-show / Cancelled</div><div class="text-4xl font-bold text-amber-600 mt-2">\${noShowCount + cancelCount}</div><div class="text-xs text-gray-400 mt-2">Risk status total</div></div>
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
            const last7Days = [];
            const last7Labels = [];
            for (let i = 6; i >= 0; i--) {
                const d = new Date();
                d.setDate(d.getDate() - i);
                const yyyy = d.getFullYear();
                const mm = String(d.getMonth() + 1).padStart(2, '0');
                const dd = String(d.getDate()).padStart(2, '0');
                const dateStr = yyyy + '-' + mm + '-' + dd;
                last7Labels.push(mm + '/' + dd);
                last7Days.push(appointments.filter(a => (a.date || '').startsWith(dateStr)).length);
            }
            new Chart(bookingCtx, {
                type: 'line',
                data: {
                    labels: last7Labels,
                    datasets: [{ label: 'Bookings', data: last7Days, borderColor: '#4f46e5', backgroundColor: 'rgba(79,70,229,0.12)', tension: 0.35, fill: true, pointRadius: 4, pointBackgroundColor: '#4f46e5' }]
                },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } }
            });

            const serviceLabels = quota.map(x => x.service || x.clinic || 'Service');
            const serviceData = quota.map(x => Number(x.booked || 0));
            new Chart(serviceCtx, {
                type: 'doughnut',
                data: {
                    labels: serviceLabels.length ? serviceLabels : ['尚無配額資料'],
                    datasets: [{ data: serviceData.length ? serviceData : [1], backgroundColor: ['#4f46e5','#10b981','#f59e0b','#8b5cf6','#ef4444','#06b6d4'] }]
                },
                options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right' } } }
            });
        }
    }, 50);
}

function renderUsers(c) {
    document.getElementById('page-title').textContent = 'User Management';
    document.getElementById('page-subtitle').textContent = 'Doctor and patient account management';
    c.innerHTML = `
        <div class="space-y-8">
            <div class="glass rounded-3xl p-8">
                <div class="flex items-center justify-between mb-6 border-b pb-4">
                    <h3 class="text-2xl font-semibold text-gray-800">Doctor Management</h3>
                    <div class="flex items-center gap-3">
                        <button onclick="addUser()" class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition">Add User</button>
                        <span id="doc-count" class="text-sm font-medium px-3 py-2 bg-indigo-50 text-indigo-700 rounded-xl">Total: \${doctorUsers.length}</span>
                    </div>
                </div>
                <div class="mb-6"><input type="text" id="docSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterDoctors()"></div>
                <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left min-w-[900px]">
                        <thead class="bg-gray-50 text-gray-600 border-b">
                            <tr><th class="py-4 px-4 rounded-tl-xl">Name</th><th class="py-4 px-4">Username</th><th class="py-4 px-4">Phone</th><th class="py-4 px-4">Email</th><th class="py-4 px-4">Title</th><th class="py-4 px-4">Status</th><th class="py-4 px-4 rounded-tr-xl">Action</th></tr>
                        </thead>
                        <tbody id="doc-tbody" class="divide-y"></tbody>
                    </table>
                </div>
            </div>

            <div class="glass rounded-3xl p-8">
                <div class="flex items-center justify-between mb-6 border-b pb-4">
                    <h3 class="text-2xl font-semibold text-gray-800">Patient Management</h3>
                    <span id="pat-count" class="text-sm font-medium px-3 py-1 bg-emerald-50 text-emerald-700 rounded-lg">Total: \${patientUsers.length}</span>
                </div>
                <div class="mb-6"><input type="text" id="patSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterPatients()"></div>
                 <div class="overflow-x-auto">
                    <table class="w-full text-sm text-left min-w-[900px]">
                        <thead class="bg-gray-50 text-gray-600 border-b">
                            <tr><th class="py-4 px-4 rounded-tl-xl">Name</th><th class="py-4 px-4">Username</th><th class="py-4 px-4">Phone</th><th class="py-4 px-4">Email</th><th class="py-4 px-4">Address</th><th class="py-4 px-4">Status</th><th class="py-4 px-4 rounded-tr-xl">Action</th></tr>
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
        document.getElementById('doc-count').textContent = `Total: \${filtered.length}`;
        document.getElementById('doc-tbody').innerHTML = filtered.length ? filtered.map(u => `
            <tr class="hover:bg-indigo-50/30 transition">
                <td class="py-4 px-4 font-bold text-gray-800">\${u.name || '-'}</td>
                <td class="px-4">\${u.username || '-'}</td><td class="px-4">\${u.phone || '-'}</td>
                <td class="px-4">\${u.email || '-'}</td><td class="px-4 font-medium">\${u.title || '-'}</td>
                <td class="px-4"><span class="badge \${u.status === 'active' ? 'badge-success' : 'badge-danger'}">\${u.status || '-'}</span></td>
                <td class="px-4">
                    <button onclick="editUser('\${u.id}', 'doctor')" class="px-3 py-1 bg-blue-100 text-blue-700 rounded-xl mr-2">編輯</button>
                    <button onclick="deleteUser('\${u.id}', 'doctor')" class="px-3 py-1 bg-red-50 text-red-600 rounded-xl">停用</button>
                </td>
            </tr>
        `).join('') : `<tr><td colspan="7" class="text-center py-8 text-gray-500">No matching records</td></tr>`;
    };

    window.filterPatients = function() {
        const kwd = document.getElementById('patSearchInput').value.trim().toLowerCase();
        const filtered = patientUsers.filter(u => !kwd || (u.name || '').toLowerCase().includes(kwd) || (u.phone || '').toLowerCase().includes(kwd) || (u.email || '').toLowerCase().includes(kwd));
        document.getElementById('pat-count').textContent = `Total: \${filtered.length}`;
        document.getElementById('pat-tbody').innerHTML = filtered.length ? filtered.map(u => `
            <tr class="hover:bg-indigo-50/30 transition">
                <td class="py-4 px-4 font-bold text-gray-800">\${u.name || '-'}</td>
                <td class="px-4">\${u.username || '-'}</td><td class="px-4">\${u.phone || '-'}</td>
                <td class="px-4">\${u.email || '-'}</td><td class="px-4 text-gray-600 truncate max-w-[200px]" title="\${u.address || ''}">\${u.address || '-'}</td>
                <td class="px-4"><span class="badge \${u.status === 'active' ? 'badge-success' : 'badge-danger'}">\${u.status || '-'}</span></td>
                <td class="px-4">
                    <button onclick="editUser('\${u.id}', 'patient')" class="px-3 py-1 bg-blue-100 text-blue-700 rounded-xl mr-2">編輯</button>
                    <button onclick="deleteUser('\${u.id}', 'patient')" class="px-3 py-1 bg-red-50 text-red-600 rounded-xl">停用</button>
                </td>
            </tr>
        `).join('') : `<tr><td colspan="7" class="text-center py-8 text-gray-500">No matching records</td></tr>`;
    };

    filterDoctors(); filterPatients();
}

function renderQuota(c) {
    document.getElementById('page-title').textContent = '診所設定';
    document.getElementById('page-subtitle').textContent = '診所、服務、營業時間、配額管理';
    const clinicsHtml = clinics.map(cn => {
        const statusBadge = cn.active ? 'badge-success' : 'badge-danger';
        const statusText = cn.active ? '營業中' : '已停用';
        return `
            <div class="flex justify-between items-center p-5 bg-white rounded-2xl border hover:shadow-sm transition">
                <div>
                    <p class="font-bold text-lg text-gray-800">\${cn.name}</p>
                    <p class="text-sm text-gray-500 mt-1"><i class="fa-solid fa-location-dot mr-1 text-gray-400"></i> \${cn.location || cn.address || '無地址'}</p>
                </div>
                <div>
                    <span class="badge \${statusBadge}">\${statusText}</span>
                    <button onclick="disableClinic('\${cn.id}')" class="ml-3 px-3 py-1 bg-red-50 text-red-600 font-medium rounded-xl hover:bg-red-100 transition">停用</button>
                </div>
            </div>
        `;
    }).join('');
    
    const quotaHtml = quota.map(q => {
        const capacity = q.capacity || 0;
        const booked = q.booked || 0;
        const rate = capacity > 0 ? Math.round((booked / capacity) * 100) : 0;
        const rateStyle = rate >= 80 ? 'bg-red-100 text-red-700' : 'bg-emerald-100 text-emerald-700';
        return `
            <tr class="hover:bg-gray-50 transition">
                <td class="py-4 px-6 font-medium text-gray-800">\${q.service}</td>
                <td class="py-4 px-6 text-center font-bold text-indigo-600">\${booked}</td>
                <td class="py-4 px-6 text-center text-gray-600">\${capacity}</td>
                <td class="py-4 px-6 text-center"><span class="px-3 py-1 rounded-full text-xs font-bold \${rateStyle}">\${rate}%</span></td>
                <td class="py-4 px-6 text-center">
                    <button onclick="editQuota('\${q.id}', '\${capacity}')" class="text-indigo-600 font-medium hover:text-indigo-800 px-3 py-1 bg-indigo-50 rounded-xl transition">修改</button>
                </td>
            </tr>
        `;
    }).join('');

    c.innerHTML = `
        <div class="max-w-7xl mx-auto space-y-8">
            <div class="glass p-8 rounded-3xl">
                <div class="flex justify-between items-center mb-6 pb-4 border-b">
                    <h3 class="text-2xl font-bold text-gray-800">診所分院</h3>
                    <button onclick="addClinic()" class="px-5 py-2 bg-indigo-600 text-white rounded-xl text-sm font-medium hover:bg-indigo-700 transition"><i class="fa-solid fa-plus mr-1"></i> 新增診所</button>
                </div>
                <div class="space-y-4">\${clinicsHtml || '<div class="text-center py-6 text-gray-500">尚無診所資料</div>'}</div>
            </div>
            <div class="glass p-8 rounded-3xl">
                <h3 class="text-2xl font-bold mb-6 pb-4 border-b text-gray-800">服務配額與營業時間</h3>
                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead>
                            <tr class="bg-gray-50 text-gray-600 border-b">
                                <th class="py-4 px-6 text-left rounded-tl-xl">服務項目</th>
                                <th class="py-4 px-6 text-center">已預約</th><th class="py-4 px-6 text-center">最大容量</th>
                                <th class="py-4 px-6 text-center">使用率</th><th class="py-4 px-6 text-center rounded-tr-xl">操作</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">\${quotaHtml || '<tr><td colspan="5" class="text-center py-8 text-gray-500">尚無配額資料</td></tr>'}</tbody>
                    </table>
                </div>
            </div>
        </div>
    `;
}

function renderAppointments(c) {
    document.getElementById('page-title').textContent = 'Appointment Management';
    document.getElementById('page-subtitle').textContent = 'View all appointments and control status';
    
    c.innerHTML = `
        <div class="glass rounded-3xl p-8">
            <h3 class="text-2xl font-semibold mb-6 border-b pb-4">Appointment Overview</h3>
            <div class="overflow-x-auto">
                <table class="w-full text-sm text-left min-w-[1000px]">
                    <thead class="bg-gray-50 text-gray-600 border-b">
                        <tr>
                            <th class="py-4 px-4 rounded-tl-xl">Date & Time</th><th class="py-4 px-4">Ticket No.</th>
                            <th class="py-4 px-4">Patient Name</th><th class="py-4 px-4">Doctor</th>
                            <th class="py-4 px-4">Department</th><th class="py-4 px-4">Status</th><th class="py-4 px-4">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        \${appointments.length ? appointments.map(a => {
                            const badgeStyle = a.status === 'Completed' ? 'badge-success' : (a.status === 'Cancelled' || a.status === 'no_show' ? 'badge-danger' : 'badge-info');
                            return \`<tr class="hover:bg-gray-50 transition">
                                <td class="py-4 px-4 font-medium">\${a.date || ''} \${a.time || ''}</td>
                                <td class="px-4 font-mono text-indigo-600">\${a.regNo || ''}</td>
                                <td class="px-4 font-bold text-gray-800">\${a.patient || ''}</td>
                                <td class="px-4">\${a.doctor || ''}</td><td class="px-4">\${a.department || ''}</td>
                                <td class="px-4"><span class="badge \${badgeStyle}">\${a.status || ''}</span></td>
                                <td class="px-4 flex gap-2">
                                    <select onchange="updateAppointmentStatus('\${a.id}', this)" class="px-2 py-1 border rounded outline-none focus:ring-1 focus:ring-indigo-500">
                                        <option value="" \${!a.status ? 'selected' : ''}>--更改狀態--</option>
                                        <option value="Confirmed" \${a.status === 'Confirmed' ? 'selected' : ''}>Confirmed</option>
                                        <option value="Completed" \${a.status === 'Completed' ? 'selected' : ''}>Completed</option>
                                        <option value="Cancelled" \${a.status === 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                                        <option value="no_show" \${a.status === 'no_show' ? 'selected' : ''}>No-show</option>
                                    </select>
                                    <button onclick="reassignDoctor('\${a.id}')" class="px-3 py-1 bg-white border rounded hover:bg-gray-50 transition">Reassign</button>
                                </td>
                            </tr>\`;
                        }).join('') : \`<tr><td colspan="7" class="text-center py-10 text-gray-500">No appointment records</td></tr>\`}
                    </tbody>
                </table>
            </div>
        </div>
    `;
}

function renderQueue(c) {
    document.getElementById('page-title').textContent = 'Queue Management';
    document.getElementById('page-subtitle').textContent = 'View and control same-day queue status';
    c.innerHTML = `
        <div class="glass rounded-3xl p-8">
            <div class="flex items-center justify-between gap-4 mb-6 border-b pb-4">
                <div>
                    <h3 class="text-2xl font-semibold text-gray-800">Live Same-day Queue</h3>
                    <p class="text-sm text-gray-500 mt-1 font-medium">Currently \${queueList.length} patients active in queue</p>
                </div>
            </div>
            <div class="space-y-4">
                \${queueList.length ? queueList.map(item => \`
                    <div class="p-5 border rounded-2xl bg-white flex items-center justify-between gap-4 shadow-sm hover:shadow-md transition">
                        <div class="flex-1">
                            <div class="flex items-center gap-3 mb-1">
                                <span class="font-mono font-bold text-xl text-indigo-600 bg-indigo-50 px-2 py-1 rounded">\${item.ticketNo || ''}</span>
                                <p class="font-bold text-lg text-gray-800">\${item.patient || ''}</p>
                            </div>
                            <p class="text-sm text-gray-600 font-medium">\${item.clinic || ''} • <span class="text-gray-500">\${item.service || ''}</span></p>
                        </div>
                        <div><span class="badge badge-info shadow-sm">\${item.status || ''}</span></div>
                    </div>
                \`).join('') : \`
                    <div class="text-center py-16">
                        <i class="fa-solid fa-users-slash text-6xl text-gray-300 mb-4"></i>
                        <p class="text-gray-500 text-lg">No patients in queue</p>
                    </div>
                \`}
            </div>
        </div>
    `;
}

function renderReports(c) {
    document.getElementById('page-title').textContent = 'Reports & Analytics';
    document.getElementById('page-subtitle').textContent = 'Operational statistics, analytics, and incident records';
    const totalAppts = appointments.length;
    const cancelCount = appointments.filter(a => (a.status || '').toLowerCase() === 'cancelled').length;
    const noShowCount = appointments.filter(a => (a.status || '').toLowerCase() === 'no_show').length;
    const cancelRate = totalAppts > 0 ? Math.round((cancelCount / totalAppts) * 100) : 0;
    const noShowRate = totalAppts > 0 ? Math.round((noShowCount / totalAppts) * 100) : 0;
    const waitTimes = appointments.filter(a => a.waitMinutes && !isNaN(Number(a.waitMinutes))).map(a => Number(a.waitMinutes));
    const avgWait = waitTimes.length > 0 ? Math.round(waitTimes.reduce((s, v) => s + v, 0) / waitTimes.length) : null;
    
    c.innerHTML = `
        <div class="max-w-7xl mx-auto space-y-8">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="glass p-6 rounded-3xl text-center shadow-sm">
                    <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Cancellation Rate</div>
                    <div class="text-5xl font-bold text-red-500 mt-3">\${cancelRate}%</div>
                    <div class="text-xs text-gray-400 mt-2">\${cancelCount} / \${totalAppts} appointments</div>
                </div>
                <div class="glass p-6 rounded-3xl text-center shadow-sm">
                    <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">No-show Rate</div>
                    <div class="text-5xl font-bold text-amber-500 mt-3">\${noShowRate}%</div>
                    <div class="text-xs text-gray-400 mt-2">\${noShowCount} / \${totalAppts} appointments</div>
                </div>
                <div class="glass p-6 rounded-3xl text-center shadow-sm">
                    <div class="text-sm font-medium text-gray-500 uppercase tracking-wider">Avg Wait Time</div>
                    <div class="text-5xl font-bold text-indigo-600 mt-3">\${avgWait !== null ? avgWait + ' <span class="text-xl">min</span>' : 'N/A'}</div>
                    <div class="text-xs text-gray-400 mt-2">\${waitTimes.length > 0 ? 'Based on ' + waitTimes.length + ' records' : 'No wait time data available'}</div>
                </div>
            </div>
            <div class="grid grid-cols-1 xl:grid-cols-2 gap-8">
                <div class="glass p-8 rounded-3xl">
                    <h3 class="text-xl font-bold mb-6 text-gray-800">Service Capacity Data</h3>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm text-left">
                            <thead class="border-b bg-gray-50">
                                <tr>
                                    <th class="py-3 px-4 font-semibold text-gray-600 rounded-tl-lg">Service</th><th class="py-3 px-4 font-semibold text-gray-600 text-center">Used</th>
                                    <th class="py-3 px-4 font-semibold text-gray-600 text-center">Capacity</th><th class="py-3 px-4 font-semibold text-gray-600 text-center rounded-tr-lg">Rate</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                \${quota.map(x => {
                                    const r = x.capacity ? Math.round((x.booked / x.capacity) * 100) : 0;
                                    return \`<tr class="hover:bg-gray-50">
                                        <td class="py-3 px-4 font-medium text-gray-800">\${x.service || ''}</td>
                                        <td class="px-4 text-center font-bold text-indigo-600">\${x.booked || 0}</td>
                                        <td class="px-4 text-center text-gray-500">\${x.capacity || 0}</td>
                                        <td class="px-4 text-center"><span class="px-2 py-1 rounded text-xs font-bold \${r>=80?'bg-red-100 text-red-700':'bg-emerald-100 text-emerald-700'}">\${r}%</span></td>
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

function renderLogs(c) {
    document.getElementById('page-title').textContent = 'Audit Trail';
    document.getElementById('page-subtitle').textContent = 'System operations and change records';
    c.innerHTML = `
        <div class="glass p-8 rounded-3xl max-w-6xl mx-auto">
            <div class="flex justify-between items-center mb-6 border-b pb-4">
                <h3 class="text-2xl font-bold text-gray-800">System Activity Log</h3>
                <button onclick="window.location.href='<%= request.getContextPath() %>/admin/logs/export'" class="text-sm font-medium text-indigo-600 hover:text-indigo-800 transition"><i class="fa-solid fa-download mr-1"></i> Export Log</button>
            </div>
            <div class="space-y-4">
                \${logs.length ? logs.map(i => \`
                    <div class="p-4 border rounded-2xl bg-white shadow-sm flex items-start gap-4">
                        <div class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 text-gray-500">
                            <i class="fa-solid fa-desktop"></i>
                        </div>
                        <div>
                            <p class="font-medium text-gray-800">\${i.action || ''}</p>
                            <p class="text-sm text-gray-500 mt-1 font-mono">\${i.createdAt || ''}</p>
                        </div>
                    </div>
                \`).join('') : '<div class="text-center py-12 text-gray-500"><i class="fa-solid fa-clipboard-list text-4xl mb-3"></i><p>No activity logs found.</p></div>'}
            </div>
        </div>
    `;
}

function renderNotifications(c) {
    document.getElementById('page-title').textContent = 'Notifications';
    document.getElementById('page-subtitle').textContent = 'View system notifications and reminders';
    c.innerHTML = `
        <div class="glass rounded-3xl p-8 max-w-5xl mx-auto">
            <div class="flex items-center justify-between mb-6 border-b pb-4">
                <h3 class="text-2xl font-bold text-gray-800">Alerts & Notifications</h3>
                <button onclick="markAllRead()" class="px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 font-medium rounded-xl transition"><i class="fa-solid fa-check-double mr-1"></i> Mark All as Read</button>
            </div>
            <div class="space-y-4">
                \${notifications.length ? notifications.map(n => \`
                    <div class="p-5 border rounded-2xl bg-white flex items-start gap-4 shadow-sm hover:shadow-md transition cursor-pointer \${n.read ? 'opacity-70' : ''}">
                        <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 \${n.type === 'success' ? 'bg-emerald-100 text-emerald-700' : n.type === 'warning' ? 'bg-amber-100 text-amber-700' : 'bg-blue-100 text-blue-700'}">
                            <i class="fa-solid \${n.type === 'warning' ? 'fa-triangle-exclamation' : 'fa-bell'}"></i>
                        </div>
                        <div class="flex-1">
                            <div class="flex items-center justify-between gap-4 mb-1">
                                <p class="font-bold text-lg text-gray-800 flex items-center gap-2">
                                    \${n.title}
                                    \${n.read ? '' : '<span class="w-2.5 h-2.5 rounded-full bg-red-500 inline-block shadow-sm shadow-red-200"></span>'}
                                </p>
                                <span class="text-xs font-medium text-gray-400 bg-gray-50 px-2 py-1 rounded">\${n.time || ''}</span>
                            </div>
                            <p class="text-gray-600">\${n.message || ''}</p>
                        </div>
                    </div>
                \`).join('') : '<div class="text-center py-16 text-gray-500"><i class="fa-regular fa-bell-slash text-5xl mb-4"></i><p class="text-lg">Inbox is empty.</p></div>'}
            </div>
        </div>
    `;
}

function renderSettings(c) {
    document.getElementById('page-title').textContent = 'System Settings';
    document.getElementById('page-subtitle').textContent = 'Site-wide policies and feature toggles';
    c.innerHTML = `
        <div class="max-w-4xl mx-auto glass p-8 rounded-3xl space-y-8">
            <h3 class="text-2xl font-bold text-gray-800 border-b pb-4">Global Policies</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div class="space-y-2">
                    <label class="block text-sm font-bold text-gray-700">Max Active Bookings per Patient</label>
                    <p class="text-xs text-gray-500 mb-2">Limit how many future appointments a single patient can hold.</p>
                    <input id="st-max" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" value="\${settings.max_active_bookings_per_patient || 3}">
                </div>
                <div class="space-y-2">
                    <label class="block text-sm font-bold text-gray-700">Cancellation Deadline (Hours)</label>
                    <p class="text-xs text-gray-500 mb-2">How many hours before the appointment can they cancel?</p>
                    <input id="st-cancel" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" value="\${settings.cancel_deadline_hours || 24}">
                </div>
            </div>
            <h3 class="text-2xl font-bold text-gray-800 border-b pb-4 mt-10">Feature Toggles</h3>
            <div class="space-y-6">
                <div class="flex items-center gap-4 p-4 border rounded-2xl bg-white shadow-sm">
                    <div>
                        <label class="font-bold text-gray-800 cursor-pointer">Enable Same-day Walk-in Queue</label>
                        <p class="text-sm text-gray-500">Allow patients to join the queue on the day of service.</p>
                    </div>
                </div>
            </div>
            <div class="pt-6 mt-6 border-t flex justify-end">
                <button onclick="saveGlobalSettings()" class="px-8 py-3 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold transition shadow-md">Save Global Settings</button>
            </div>
        </div>
    `;
}

function renderCsv(c) {
    document.getElementById('page-title').textContent = 'CSV Management';
    document.getElementById('page-subtitle').textContent = 'Import and export clinic data securely';
    c.innerHTML = `
        <div class="max-w-4xl mx-auto glass p-10 rounded-3xl text-center">
            <h3 class="text-3xl font-bold mb-2 text-gray-800">Data Import & Export</h3>
            <p class="text-gray-500 mb-10">Manage batch data operations using CSV format.</p>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <button onclick="window.location.href='<%= request.getContextPath() %>/admin/csv/export'" class="p-10 bg-white border rounded-3xl hover:border-emerald-500 hover:shadow-xl transition group">
                    <div class="w-20 h-20 mx-auto bg-emerald-50 rounded-full flex items-center justify-center mb-6 group-hover:scale-110 transition"><i class="fa-solid fa-file-export text-emerald-600 text-3xl"></i></div>
                    <p class="text-xl font-bold text-gray-800 mb-2">Export Data</p>
                    <p class="text-sm text-gray-500">Download appointment records and user data.</p>
                </button>
                <button onclick="document.getElementById('csv-import-input').click()" class="p-10 bg-white border rounded-3xl hover:border-indigo-500 hover:shadow-xl transition group">
                    <div class="w-20 h-20 mx-auto bg-indigo-50 rounded-full flex items-center justify-center mb-6 group-hover:scale-110 transition"><i class="fa-solid fa-file-import text-indigo-600 text-3xl"></i></div>
                    <p class="text-xl font-bold text-gray-800 mb-2">Import CSV</p>
                    <p class="text-sm text-gray-500">Batch create time slots, services, or new staff accounts.</p>
                </button>
            </div>
            <input type="file" id="csv-import-input" accept=".csv" class="hidden" onchange="handleCsvImport(this)">
        </div>
    `;
}

function handleCsvImport(input) {
    const file = input.files[0];
    if (!file) return;
    const formData = new FormData();
    formData.append('file', file);
    fetch('<%= request.getContextPath() %>/admin/csv/import', { method: 'POST', body: formData })
        .then(resp => parseResponseSafe(resp, 'CSV 匯入失敗'))
        .then(res => {
            if (res.success) Swal.fire({ icon: 'success', title: 'Import Successful', text: res.message || 'CSV 資料已成功匯入。', timer: 2500, showConfirmButton: false });
            else Swal.fire('失敗', res.message || 'CSV 匯入失敗', 'error');
        }).catch(err => Swal.fire('錯誤', err.message || '伺服器錯誤', 'error'));
    input.value = '';
}

function renderProfile(c) {
    document.getElementById('page-title').textContent = 'Profile & Security';
    document.getElementById('page-subtitle').textContent = 'Admin account settings and password management';
    c.innerHTML = `
        <div class="max-w-3xl mx-auto glass rounded-3xl p-8">
            <h3 class="text-2xl font-bold mb-6 text-gray-800 border-b pb-4"><i class="fa-solid fa-user-shield text-gray-400 mr-2"></i>Account Profile</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="md:col-span-2 flex items-center gap-6 mb-4">
                    <img src="\${avatarJS}" class="w-24 h-24 rounded-full ring-4 ring-indigo-50 object-cover shadow-sm" alt="avatar">
                    <div>
                        <h4 class="text-xl font-bold text-gray-800">\${realNameJS}</h4>
                        <p class="text-sm font-medium text-indigo-600 bg-indigo-50 px-3 py-1 rounded inline-block mt-2">System Administrator</p>
                    </div>
                </div>
                <div><label class="block text-sm font-bold text-gray-700 mb-2">Full Name</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="\${realNameJS}" readonly></div>
                <div><label class="block text-sm font-bold text-gray-700 mb-2">Role Access</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="Full Access" readonly></div>
                <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-2">Email Address</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="\${email}" readonly></div>
                <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-2">Phone Number</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="\${phone}" readonly></div>
            </div>
            <div class="mt-10 pt-8 border-t border-gray-200">
                <h3 class="text-2xl font-bold mb-6 text-gray-800"><i class="fa-solid fa-lock text-gray-400 mr-2"></i>Change Password</h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-2">Current Password</label><input type="password" id="admin-old-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" placeholder="Leave blank if not changing"></div>
                    <div><label class="block text-sm font-bold text-gray-700 mb-2">New Password</label><input type="password" id="admin-new-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" placeholder="Enter new password"></div>
                    <div><label class="block text-sm font-bold text-gray-700 mb-2">Confirm New Password</label><input type="password" id="admin-conf-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" placeholder="Re-enter new password"></div>
                </div>
                <div class="mt-8 flex justify-end"><button onclick="saveAdminProfile()" class="px-8 py-3 bg-indigo-600 text-white font-bold rounded-xl hover:bg-indigo-700 shadow-md">Save All Changes</button></div>
            </div>
        </div>
    `;
}

// ====================== 路由配置與生命週期 ======================
const pageRenderers = {
    'dashboard': renderDashboard, 'users': renderUsers, 'appointments': renderAppointments,
    'queue': renderQueue, 'quota': renderQuota, 'reports': renderReports,
    'logs': renderLogs, 'notifications': renderNotifications, 'settings': renderSettings,
    'csv': renderCsv, 'profile': renderProfile
};

function renderPage(page) {
    const c = document.getElementById('main-content');
    c.style.transition = 'none';
    c.style.opacity = '0';
    c.style.transform = 'translate3d(0, 10px, 0)';

    setTimeout(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' });

        const renderer = pageRenderers[page];
        if (renderer) renderer(c);
        else c.innerHTML = '<div class="p-10 text-center text-gray-500 text-xl">此頁面尚在開發中 (Page not found)</div>';

        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                c.style.transition = 'opacity 0.25s ease-out, transform 0.25s cubic-bezier(0.4, 0, 0.2, 1)';
                c.style.opacity = '1';
                c.style.transform = 'translate3d(0, 0, 0)';
            });
        });
    }, 30);
}

function loadPage(page) {
    if (state.activePage === page) return; 
    setActiveNav(page);
    renderPage(page);
}

window.onload = () => {
    updateDate();
    setInterval(updateDate, 60000); 
    updateNotificationCount();
    loadPage('dashboard');
};
</script>
</body>
</html>