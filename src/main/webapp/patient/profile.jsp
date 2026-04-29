<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("patientProfile");
    if (profile == null) {
        profile = new HashMap<>();
    }
    String realName = profile.get("realName") != null ? profile.get("realName").toString() : "";
    String phone = profile.get("phone") != null ? profile.get("phone").toString() : "";
    String email = profile.get("email") != null ? profile.get("email").toString() : "";
    String address = profile.get("address") != null ? profile.get("address").toString() : "";
    String avatar = profile.get("avatar") != null ? profile.get("avatar").toString() : "https://picsum.photos/200/200?random=1";
    String ctx = request.getContextPath();
    String sessionName = (String) session.getAttribute("realName");
    if (sessionName == null)
        sessionName = "Patient";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Profile</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
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
                            <p class="font-semibold"><%= sessionName%></p>
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
                        <h2 class="text-2xl font-semibold">Profile</h2>
                        <p class="text-sm text-gray-500 mt-1">Account</p>
                    </div>
                    <span id="current-date" class="text-sm text-gray-500 font-medium"></span>
                </header>
                <div class="flex-1 overflow-auto p-8">
                    <div class="max-w-4xl mx-auto space-y-6">
                        <div class="glass rounded-3xl p-8">
                            <h3 class="text-2xl font-semibold mb-6 border-b pb-3">Personal Information</h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <div class="md:col-span-2">
                                    <label class="text-sm text-gray-700 font-semibold mb-2 flex items-center gap-2">Profile Avatar <span class="text-red-500 text-xs font-normal bg-red-50 px-2 py-1 rounded-md">JPG/PNG only</span></label>
                                    <input id="avatar-upload" type="file" accept="image/jpeg, image/png" class="w-full p-3 border rounded-xl bg-white cursor-pointer hover:bg-gray-50 transition">
                                </div>
                                <div class="md:col-span-2 flex items-center gap-4 mb-2">
                                    <img id="avatar-preview" src="<%= avatar%>" class="w-20 h-20 rounded-2xl object-cover ring-4 ring-gray-100 shadow-sm" alt="avatar preview">
                                    <p class="text-sm text-gray-500">Image previews immediately after selection.</p>
                                </div>
                                <div><label class="block text-sm text-gray-700 font-medium mb-1">Full Name</label><input id="pf-name" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= realName%>"></div>
                                <div><label class="block text-sm text-gray-700 font-medium mb-1">Phone Number</label><input id="pf-phone" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= phone%>"></div>
                                <div><label class="block text-sm text-gray-700 font-medium mb-1">Email Address</label><input id="pf-email" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= email%>"></div>
                                <div><label class="block text-sm text-gray-700 font-medium mb-1">Home Address</label><input id="pf-address" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= address%>"></div>
                            </div>
                        </div>
                        <div class="glass rounded-3xl p-8">
                            <h3 class="text-2xl font-semibold mb-6 border-b pb-3 text-gray-800"><i class="fa-solid fa-lock text-gray-400 mr-2"></i>Change Password</h3>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <div class="md:col-span-2"><label class="block text-sm text-gray-700 font-medium mb-1">Current Password</label><input type="password" id="pf-old-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Leave blank if not changing"></div>
                                <div><label class="block text-sm text-gray-700 font-medium mb-1">New Password</label><input type="password" id="pf-new-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Enter new password"></div>
                                <div><label class="block text-sm text-gray-700 font-medium mb-1">Confirm New Password</label><input type="password" id="pf-conf-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Re-enter new password"></div>
                            </div>
                        </div>
                        <div class="flex gap-4 pt-2">
                            <button onclick="saveProfile()" class="px-8 py-3 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 shadow-sm transition">Save All Changes</button>
                            <a href="<%= ctx%>/patient/dashboard" class="px-8 py-3 bg-gray-200 text-gray-700 font-medium rounded-xl hover:bg-gray-300 transition">Cancel</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            document.getElementById('current-date').textContent = new Date().toLocaleDateString('en-US', {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'});
            function saveProfile() {
                let formData = new FormData();
                formData.append("name", document.getElementById('pf-name').value);
                formData.append("phone", document.getElementById('pf-phone').value);
                formData.append("email", document.getElementById('pf-email').value);
                formData.append("address", document.getElementById('pf-address').value);
                let oldPwd = document.getElementById('pf-old-pwd').value;
                let newPwd = document.getElementById('pf-new-pwd').value;
                let confirmPwd = document.getElementById('pf-conf-pwd').value;
                if (newPwd && newPwd !== confirmPwd) {
                    Swal.fire('Error', 'New passwords do not match', 'error');
                    return;
                }
                if (newPwd)
                    formData.append("newPwd", newPwd);
                if (oldPwd)
                    formData.append("oldPwd", oldPwd);
                let avatarFile = document.getElementById('avatar-upload').files[0];
                if (avatarFile) {
                    let reader = new FileReader();
                    reader.onload = function (e) {
                        formData.append("avatar", e.target.result);
                        submitProfile(formData);
                    };
                    reader.readAsDataURL(avatarFile);
                } else {
                    submitProfile(formData);
                }
            }
            function submitProfile(formData) {
                fetch('<%= ctx%>/patient/update-profile', {
                    method: 'POST',
                    body: formData
                }).then(res => res.json()).then(data => {
                    if (data.success) {
                        Swal.fire('Success', data.message, 'success').then(() => location.reload());
                    } else {
                        Swal.fire('Error', data.message, 'error');
                    }
                }).catch(() => Swal.fire('Error', 'Network error', 'error'));
            }
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