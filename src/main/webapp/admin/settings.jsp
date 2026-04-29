<%-- settings.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="/WEB-INF/tlds/current-date" prefix="today" %>

<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh">
    <head>
        <meta charset="UTF-8">
        <title>System Settings - CCHC Admin</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: system-ui, 'Segoe UI', 'Noto Sans TC', sans-serif;
                background: #f0f2f5;
            }
            .app {
                display: flex;
                height: 100vh;
            }
            .sidebar {
                width: 260px;
                background: white;
                border-right: 1px solid #e5e7eb;
                display: flex;
                flex-direction: column;
            }
            .sidebar-header {
                padding: 1.5rem;
                background: linear-gradient(135deg, #4f46e5, #7c3aed);
                color: white;
            }
            .sidebar-nav {
                flex: 1;
                padding: 1rem;
            }
            .nav-item {
                display: flex;
                align-items: center;
                gap: 0.75rem;
                padding: 0.6rem 1rem;
                border-radius: 0.5rem;
                color: #1f2937;
                text-decoration: none;
                margin-bottom: 0.25rem;
            }
            .nav-item:hover {
                background: #f3f4f6;
            }
            .nav-item.active {
                background: #e0e7ff;
                color: #4f46e5;
                font-weight: 600;
            }
            .logout-btn {
                margin-top: auto;
                padding: 1rem;
                border-top: 1px solid #e5e7eb;
                text-align: center;
            }
            .main {
                flex: 1;
                display: flex;
                flex-direction: column;
                overflow-y: auto;
            }
            .header {
                background: white;
                border-bottom: 1px solid #e5e7eb;
                padding: 1rem 2rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .content {
                padding: 2rem;
            }
            .card {
                background: white;
                border-radius: 1rem;
                padding: 2rem;
                max-width: 800px;
                margin: 0 auto;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            }
            .setting-group {
                margin-bottom: 1.5rem;
            }
            label {
                font-weight: 600;
                display: block;
                margin-bottom: 0.5rem;
            }
            input[type="number"] {
                width: 100%;
                padding: 0.6rem;
                border: 1px solid #d1d5db;
                border-radius: 0.5rem;
            }
            .switch {
                position: relative;
                display: inline-block;
                width: 52px;
                height: 28px;
            }
            .switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }
            .slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #ccc;
                border-radius: 28px;
                transition: 0.3s;
            }
            .slider:before {
                position: absolute;
                content: "";
                height: 22px;
                width: 22px;
                left: 3px;
                bottom: 3px;
                background-color: white;
                border-radius: 50%;
                transition: 0.3s;
            }
            input:checked + .slider {
                background-color: #4f46e5;
            }
            input:checked + .slider:before {
                transform: translateX(24px);
            }
            button {
                padding: 0.5rem 1.5rem;
                border-radius: 0.5rem;
                font-weight: 600;
                border: none;
                cursor: pointer;
            }
            .btn-save {
                background: #4f46e5;
                color: white;
            }
            hr {
                margin: 1.5rem 0;
            }
        </style>
    </head>
    <body>
        <div class="app">
            <aside class="w-80 glass bg-white shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
                <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white"><div class="flex items-center gap-3"><i class="fa-solid fa-user-shield text-4xl"></i><div><h1 class="text-2xl font-bold">CCHC</h1><p class="text-sm opacity-90">Admin Console</p></div></div></div>
                <div class="p-6 flex-1 flex flex-col overflow-y-auto">
                    <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8"><img src="https://picsum.photos/200/200?random=99" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover"><div><p class="font-semibold"><%= loginUser.getRealName()%></p><p class="text-indigo-600 text-sm">Full Access</p></div></div>
                    <nav class="space-y-1">
                        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item"><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                        <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item"><i class="fa-solid fa-users w-5"></i><span>User Management</span></a>
                        <a href="${pageContext.request.contextPath}/admin/appointments.jsp" class="nav-item"><i class="fa-solid fa-calendar-check w-5"></i><span>Appointments</span></a>
                        <a href="${pageContext.request.contextPath}/admin/queue.jsp" class="nav-item"><i class="fa-solid fa-list-ol w-5"></i><span>Queue</span></a>
                        <a href="${pageContext.request.contextPath}/admin/quota.jsp" class="nav-item"><i class="fa-solid fa-server w-5"></i><span>Services & Quota</span></a>
                        <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"><i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span></a>
                        <a href="${pageContext.request.contextPath}/admin/logs.jsp" class="nav-item"><i class="fa-solid fa-clipboard-list w-5"></i><span>Audit Logs</span></a>
                        <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                        <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item active"><i class="fa-solid fa-sliders w-5"></i><span>Settings</span></a>
                        <a href="${pageContext.request.contextPath}/admin/csv.jsp" class="nav-item"><i class="fa-solid fa-file-csv w-5"></i><span>CSV Import/Export</span></a>
                        <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                    </nav>
                    <div class="mt-auto pt-6 border-t border-white/40"><a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a></div>
                </div>
            </aside>
                
                
            <div class="main">
                <header class="header"><h2 class="text-2xl font-semibold">System Settings</h2><today:today/></header>
                <div class="content">
                    <div class="card">
                        <h3 class="text-xl font-bold mb-4">Global Policies</h3>
                        <div class="setting-group"><label>Max Active Bookings per Patient</label><input type="number" id="st-max" value="3"><p class="text-xs text-gray-500">Limit how many future appointments a single patient can hold.</p></div>
                        <div class="setting-group"><label>Cancellation Deadline (Hours)</label><input type="number" id="st-cancel" value="24"><p class="text-xs text-gray-500">How many hours before the appointment can they cancel?</p></div>
                        <hr>
                        <h3 class="text-xl font-bold mb-4">Feature Toggles</h3>
                        <div class="setting-group flex items-center gap-4"><label class="switch"><input type="checkbox" id="st-queue"><span class="slider"></span></label><div><label class="font-bold">Enable Same-day Walk-in Queue</label><p class="text-sm text-gray-500">Allow patients to join the queue on the day of service.</p></div></div>
                        <div id="walkin-clinics-section" style="display:none; margin-top:1rem; padding:1rem; background:#f9fafb; border-radius:0.75rem;"><h4 class="font-bold mb-2">Select clinics that allow walk-in queue</h4><div id="clinics-list" class="grid grid-cols-1 md:grid-cols-2 gap-2"></div><p class="text-xs text-gray-400 mt-2">Patients will be able to join queue for selected clinics on the same day.</p></div>
                        <div class="setting-group flex items-center gap-4 mt-4"><label class="switch"><input type="checkbox" id="st-approval"><span class="slider"></span></label><div><label class="font-bold">Require Booking Approval</label><p class="text-sm text-gray-500">Doctors or staff must manually approve new online bookings.</p></div></div>
                        <div class="flex justify-end mt-8"><button id="save-settings-btn" class="btn-save">Save Global Settings</button></div>
                    </div>
                </div>
            </div>
        </div>
        <script>
    const contextPath = '<%= request.getContextPath()%>';
    let allClinics = [];
    let selectedClinicIds = new Set();

    function loadSettings() {
        fetch(contextPath + '/admin/settingsData', {credentials: 'same-origin'})
                .then(res => res.json())
                .then(data => {
                    const settings = data.settings || {};
                    document.getElementById('st-max').value = settings.max_active_bookings_per_patient || '3';
                    document.getElementById('st-cancel').value = settings.cancel_deadline_hours || '24';
                    const queueCheck = document.getElementById('st-queue');
                    queueCheck.checked = settings.same_day_queue_enabled === '1';
                    document.getElementById('st-approval').checked = settings.booking_approval_required === '1';
                    document.getElementById('walkin-clinics-section').style.display = queueCheck.checked ? 'block' : 'none';
                    allClinics = data.clinics || [];
                    renderClinicCheckboxes();
                    const enabledStr = settings.walkin_enabled_clinics || '';
                    selectedClinicIds.clear();
                    enabledStr.split(',').forEach(idStr => {
                        let id = parseInt(idStr.trim());
                        if (!isNaN(id))
                            selectedClinicIds.add(id);
                    });
                    updateCheckboxStates();
                }).catch(err => Swal.fire('Error', 'Cannot load settings', 'error'));
    }

    function renderClinicCheckboxes() {
        const container = document.getElementById('clinics-list');
        if (!container)
            return;
        if (!allClinics.length) {
            container.innerHTML = '<p class="text-gray-500">No active clinics found.</p>';
            return;
        }
        let html = '';
        allClinics.forEach(clinic => {
            html += `<label class="flex items-center gap-3 p-2 rounded-lg hover:bg-white transition">
            <input type="checkbox" class="clinic-checkbox" value="\${clinic.id}">
            <span class="text-gray-700">\${escapeHtml(clinic.name)}</span>
        </label>`;
        });
        container.innerHTML = html;
        document.querySelectorAll('.clinic-checkbox').forEach(cb => {
            cb.addEventListener('change', function () {
                let id = parseInt(this.value);
                if (this.checked)
                    selectedClinicIds.add(id);
                else
                    selectedClinicIds.delete(id);
            });
        });
    }

    function updateCheckboxStates() {
        document.querySelectorAll('.clinic-checkbox').forEach(cb => {
            let id = parseInt(cb.value);
            cb.checked = selectedClinicIds.has(id);
        });
    }

    function escapeHtml(str) {
        if (!str)
            return '';
        return str.replace(/[&<>]/g, function (m) {
            if (m === '&')
                return '&amp;';
            if (m === '<')
                return '&lt;';
            if (m === '>')
                return '&gt;';
            return m;
        });
    }

    function saveSettings() {
        const maxActive = document.getElementById('st-max').value;
        const cancelHours = document.getElementById('st-cancel').value;
        const queueEnabled = document.getElementById('st-queue').checked ? '1' : '0';
        const approvalRequired = document.getElementById('st-approval').checked ? '1' : '0';
        const selectedClinics = Array.from(selectedClinicIds).join(',');
        const formData = new URLSearchParams();
        formData.append('max_active_bookings_per_patient', maxActive);
        formData.append('cancel_deadline_hours', cancelHours);
        formData.append('same_day_queue_enabled', queueEnabled);
        formData.append('booking_approval_required', approvalRequired);
        formData.append('walkin_enabled_clinics', selectedClinics);
        fetch(contextPath + '/admin/settings/save', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: formData,
            credentials: 'same-origin'
        })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        Swal.fire('Saved', data.message, 'success');
                        loadSettings();
                    } else {
                        Swal.fire('Error', data.message || 'Save failed', 'error');
                    }
                })
                .catch(err => Swal.fire('Error', 'Network error', 'error'));
    }

    document.getElementById('st-queue').addEventListener('change', function (e) {
        document.getElementById('walkin-clinics-section').style.display = e.target.checked ? 'block' : 'none';
    });
    document.getElementById('save-settings-btn').addEventListener('click', saveSettings);
    loadSettings();
    document.getElementById('current-date').innerText = new Date().toLocaleDateString('zh-CN');
        </script>
    </body>
</html>