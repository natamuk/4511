<%-- 
    Document   : home
    Created on : 2026年3月31日, 22:17:53
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
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
            #main-content {
                opacity: 0;
                transform: translateY(10px);
                transition: opacity 0.2s ease, transform 0.2s ease;
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
                        <img id="sidebar-avatar" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover" src="https://picsum.photos/200/200?random=1" alt="avatar">
                        <div>
                            <p class="font-semibold" id="sidebar-name">Patient</p>
                            <p class="text-emerald-600 text-sm">Patient</p>
                        </div>
                    </div>
                    <nav class="space-y-1" id="nav"></nav>
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
                        <h2 id="page-title" class="text-2xl font-semibold">Home</h2>
                        <p class="text-sm text-gray-500 mt-1" id="page-subtitle"></p>
                    </div>
                    <span id="current-date" class="text-sm text-gray-500 font-medium"></span>
                </header>
                <div class="flex-1 overflow-auto p-8" id="main-content"></div>
            </div>
        </div>

        <script>
    var contextPath = '<%= request.getContextPath()%>';
    window.PATIENT_DATA = {
        clinics: <%= request.getAttribute("clinicsJson") != null ? request.getAttribute("clinicsJson") : "[]"%>,
        clinicSlots: <%= request.getAttribute("clinicSlotsJson") != null ? request.getAttribute("clinicSlotsJson") : "{}"%>
    };
    window.appointmentsData = <%= request.getAttribute("appointmentsJson") != null ? request.getAttribute("appointmentsJson") : "[]"%>;
    window.notifications = <%= request.getAttribute("notificationsJson") != null ? request.getAttribute("notificationsJson") : "[]" %>;
    window.sameDayQueueEnabled = <%= request.getAttribute("sameDayQueueEnabled") != null ? request.getAttribute("sameDayQueueEnabled") : false%>;
    window.availableWalkinClinics = <%= request.getAttribute("availableWalkinClinicsJson") != null ? request.getAttribute("availableWalkinClinicsJson") : "[]"%>;

    let currentPage = '';
    let isRenderingPage = false;

    function updateDate() {
        document.getElementById('current-date').textContent = new Date().toLocaleDateString('en-US', {
            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
        });
    }

    function loadSidebar() {
        document.getElementById('nav').innerHTML = `
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="home"><i class="fa-solid fa-house w-5"></i><span>Home</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="book"><i class="fa-solid fa-calendar-check w-5"></i><span>Book Appointment</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="calendar"><i class="fa-solid fa-calendar w-5"></i><span>Appointment Calendar</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="my"><i class="fa-solid fa-list w-5"></i><span>My Appointments</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="queue"><i class="fa-solid fa-users-line w-5"></i><span>Join Queue</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="notifications"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="profile"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="favorites"><i class="fa-solid fa-star w-5"></i><span>Favorite Clinics</span></div>
            <div class="nav-item flex items-center gap-3 px-5 py-3 rounded-2xl" data-page="record"><i class="fa-solid fa-file-medical w-5"></i><span>Medical History</span></div>
        `;
        document.getElementById('nav').addEventListener('click', e => {
            const item = e.target.closest('.nav-item');
            if (item)
                loadPage(item.dataset.page);
        });
    }

    function loadPage(page) {
        if (isRenderingPage)
            return;
        isRenderingPage = true;
        currentPage = page;

        document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
        document.querySelector(`.nav-item[data-page="${page}"]`).classList.add('active');

        const titles = {home: "Home", book: "Book Appointment", calendar: "Appointment Calendar", my: "My Appointments", queue: "Join Queue", notifications: "Notifications", profile: "Profile", favorites: "Favorite Clinics", record: "Medical History"};
        const subs = {home: "Clinic overview for today", book: "Choose clinic & time slot", calendar: "View schedule", my: "Manage bookings", queue: "Walk-in waiting", notifications: "Alerts", profile: "Account", favorites: "Saved", record: "History"};
        document.getElementById('page-title').innerText = titles[page];
        document.getElementById('page-subtitle').innerText = subs[page];

        const container = document.getElementById('main-content');
        container.style.opacity = '0';
        setTimeout(() => {
            const url = page === 'my' ? 'contents/my-appointments-contents.jsp' : 'contents/' + page + '-contents.jsp';
            const xhr = new XMLHttpRequest();
            xhr.open('GET', url, true);
            xhr.onload = () => {
                if (xhr.status === 200) {
                    container.innerHTML = xhr.responseText;
                    const scripts = container.querySelectorAll('script');
                    scripts.forEach(oldScript => {
                        const newScript = document.createElement('script');
                        newScript.textContent = oldScript.textContent;
                        document.body.appendChild(newScript).remove();
                    });
                    if (page === 'my' && typeof renderMyAppointments === 'function') {
                        renderMyAppointments();
                    }
                } else {
                    container.innerHTML = '<div class="text-red-500 p-10 text-center">Content not found</div>';
                }
                container.style.opacity = '1';
                isRenderingPage = false;
            };
            xhr.send();
        }, 50);
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
                window.location.href = contextPath + "/login.jsp";
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