<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("staffProfile");
    String realName = (profile != null && profile.get("realName") != null) ? profile.get("realName").toString() : "Doctor";
    String title = (profile != null && profile.get("title") != null) ? profile.get("title").toString() : "Physician";
    String dept = (profile != null && profile.get("departmentName") != null) ? profile.get("departmentName").toString() : "General";
    String clinicName = (profile != null && profile.get("clinicName") != null) ? profile.get("clinicName").toString() : title;
    String avatar = (profile != null && profile.get("avatar") != null) ? profile.get("avatar").toString() : "https://picsum.photos/200";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><title>Doctor - Report Issue</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        * { box-sizing: border-box; }
        body {
            font-family: 'Noto Sans TC', sans-serif;
            background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%);
        }
        .glass {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid rgba(255, 255, 255, 0.6);
            backdrop-filter: blur(4px);
        }
        .nav-item {
            transition: background-color 0.15s ease, transform 0.15s ease;
            cursor: pointer;
        }
        .nav-item:hover { transform: translateX(8px); background: rgba(14,165,233,0.1); }
        .nav-item.active { background: rgba(14,165,233,0.14); color: #0369a1; font-weight: 700; }
        .card {
            background: white; border-radius: 1rem; padding: 2rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            max-width: 600px; margin: 2rem auto;
        }
        button { transition: all 0.15s ease; }
        .btn-primary {
            background-color: #3b82f6; color: white; padding: 0.5rem 1rem;
            border: none; border-radius: 0.5rem; cursor: pointer;
        }
        .btn-primary:hover { background-color: #2563eb; }
        input, select, textarea {
            border: 1px solid #d1d5db;
            border-radius: 0.5rem;
            padding: 0.5rem;
            width: 100%;
        }
        label { font-weight: 500; display: block; margin-bottom: 0.25rem; }
    </style>
</head>
<body class="min-h-screen">
<div class="flex h-screen overflow-hidden relative">
    <!-- 左侧导航栏（与原有结构完全相同，active 为 Issues） -->
    <div class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 z-40 fixed h-full">
        <div class="p-6 bg-gradient-to-r from-sky-700 to-blue-700">
            <div class="flex items-center gap-3">
                <i class="fa-solid fa-user-doctor text-4xl text-white"></i>
                <div><h1 class="text-2xl font-bold text-white">CCHC</h1><p class="text-sm text-white/90">Doctor Dashboard</p></div>
            </div>
        </div>
        <div class="p-6 flex-1 flex flex-col overflow-y-auto">
            <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8">
                <img src="<%= avatar %>" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" alt="avatar">
                <div><p class="font-semibold"><%= realName %></p><p class="text-sky-600 text-sm"><%= clinicName %></p></div>
            </div>
            <nav class="flex flex-col gap-1">
                <a href="<%= ctx %>/doctor/dashboard" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                <a href="<%= ctx %>/doctor/appointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-calendar-days w-5"></i><span>Appointments</span></a>
                <a href="<%= ctx %>/doctor/checkin" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-clipboard-check w-5"></i><span>Consultation</span></a>
                <a href="<%= ctx %>/doctor/queue" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-users-line w-5"></i><span>Queue</span></a>
                <a href="<%= ctx %>/doctor/myAppointments" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-doctor w-5"></i><span>My Schedule</span></a>
                <a href="<%= ctx %>/doctor/search" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-magnifying-glass w-5"></i><span>Patient Search</span></a>
                <a href="<%= ctx %>/doctor/issues" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl active"><i class="fa-solid fa-triangle-exclamation w-5"></i><span>Issues</span></a>
                <a href="<%= ctx %>/doctor/notifications" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-bell w-5"></i><span>Alerts</span></a>
                <a href="<%= ctx %>/doctor/profile" class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
            </nav>
            <div class="mt-auto pt-6 border-t border-white/40">
                <a href="<%= ctx %>/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a>
            </div>
        </div>
    </div>

    <!-- 右侧内容区：仅显示报告表单，无历史列表 -->
    <div class="flex-1 flex flex-col min-w-0 ml-80">
        <div class="flex-1 overflow-auto p-4 md:p-8 flex items-center justify-center">
            <div class="card w-full max-w-lg">
                <div class="text-center mb-6">
                    <i class="fa-solid fa-flag-checkered text-5xl text-blue-500 mb-3"></i>
                    <h2 class="text-2xl font-bold">Report Operational Issue</h2>
                    <p class="text-gray-500 text-sm mt-1">Use this form to report doctor absence, service pause, or other clinic issues</p>
                </div>
                <form id="reportForm">
                    <div class="mb-4">
                        <label>Issue Type <span class="text-red-500">*</span></label>
                        <select id="issueType" required>
                            <option value="Doctor Absent">👨‍⚕️ Doctor not available</option>
                            <option value="Service Pause">⏸️ Service pause</option>
                            <option value="Equipment Failure">🛠️ Equipment failure</option>
                            <option value="Clinic Issue">🏥 Clinic operational issue</option>
                            <option value="Other">📝 Other</option>
                        </select>
                    </div>
                    <div class="mb-5">
                        <label>Detail Description <span class="text-red-500">*</span></label>
                        <textarea id="detail" rows="4" class="w-full" placeholder="Please describe the issue in detail..."></textarea>
                    </div>
                    <button type="button" onclick="submitReport()" class="btn-primary w-full py-2 text-lg">Submit Report</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    async function submitReport() {
        const issueType = document.getElementById('issueType').value;
        const detail = document.getElementById('detail').value.trim();
        if (!detail) {
            Swal.fire('Error', 'Please describe the issue', 'error');
            return;
        }
        Swal.fire({ title: 'Submitting...', allowOutsideClick: false, didOpen: () => Swal.showLoading() });
        const formData = new URLSearchParams();
        formData.append('issueType', issueType);
        formData.append('detail', detail);
        try {
            const response = await fetch('<%= ctx %>/doctor/issue', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            });
            const data = await response.json();
            if (data.success) {
                Swal.fire({
                    icon: 'success',
                    title: 'Reported',
                    text: 'The issue has been recorded. It will appear in Alerts.',
                    confirmButtonText: 'OK'
                }).then(() => {
                    document.getElementById('detail').value = '';
                });
            } else {
                Swal.fire('Error', data.message || 'Submission failed', 'error');
            }
        } catch (err) {
            Swal.fire('Network Error', err.message, 'error');
        }
    }
</script>
</body>
</html>