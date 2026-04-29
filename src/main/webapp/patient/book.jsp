<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%@ page import="java.util.*, com.google.gson.Gson" %>
<%
    String ctx = request.getContextPath();
    List<Map<String, Object>> clinics = (List<Map<String, Object>>) request.getAttribute("clinics");
    if (clinics == null) {
        clinics = new ArrayList<>();
    }
    Gson gson = new Gson();
    String clinicsJson = gson.toJson(clinics);
    String realName = (String) session.getAttribute("realName");
    if (realName == null) {
        realName = "Patient";
    }
    String avatar = "https://picsum.photos/200/200?random=1";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Book Appointment</title>
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
            .clinic-card {
                transition: transform 0.2s ease-out, box-shadow 0.2s ease-out;
            }
            .clinic-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 10px 25px rgba(0,0,0,0.08);
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
            .slot-btn:hover:not(.active):not(.disabled) {
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
            .slot-btn.disabled {
                opacity: 0.5;
                cursor: not-allowed;
                background: #f3f4f6;
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
                            <p class="font-semibold"><%= realName%></p>
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
                        <h2 class="text-2xl font-semibold">Book Appointment</h2>
                        <p class="text-sm text-gray-500 mt-1">Choose clinic, date & time slot</p>
                    </div>
                    <span id="current-date" class="text-sm text-gray-500 font-medium"></span>
                </header>
                <div class="flex-1 overflow-auto p-8">
                    <div class="max-w-7xl mx-auto">
                        <h2 class="text-3xl font-bold mb-2">Book Appointment</h2>
                        <p class="text-gray-600 mb-10">Select clinic, date and an available time slot</p>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8" id="clinicBox"></div>
                    </div>
                </div>
            </div>
        </div>
        <script>
    var contextPath = '<%= ctx%>';
    var clinicsData = <%= clinicsJson%>;

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/[&<>]/g, function (m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        });
    }

    async function loadSlotsForClinic(clinicId, date, slotsContainerId) {
        if (!date) return;
        const container = document.getElementById(slotsContainerId);
        container.innerHTML = '<div class="p-4 text-center text-gray-500">Loading slots...</div>';
        try {
            const response = await fetch(`${contextPath}/patient/slot-availability?clinicId=${clinicId}&date=${date}`);
            if (!response.ok) throw new Error('Failed to load slots');
            const slots = await response.json();
            renderSlotsForClinic(slots, container, clinicId, date);
        } catch (err) {
            console.error(err);
            container.innerHTML = '<div class="p-4 text-center text-red-500">Failed to load time slots.</div>';
        }
    }

    function renderSlotsForClinic(slots, container, clinicId, date) {
        let morning = '', afternoon = '', evening = '';
        const today = new Date().toISOString().slice(0, 10);
        const isToday = (date === today);
        const now = new Date();
        const currentHour = now.getHours();
        const currentMinute = now.getMinutes();

        for (let s of slots) {
            let disabled = (s.available <= 0);
            if (isToday && !disabled) {
                const [hour, minute] = s.slotTime.split(':').map(Number);
                if (hour < currentHour || (hour === currentHour && minute <= currentMinute)) {
                    disabled = true;
                }
            }
            const btn = `<button type="button" class="slot-btn ${disabled ? 'disabled' : ''}" data-slot-time="${escapeHtml(s.slotTime)}" ${disabled ? 'disabled' : ''}>
                            <div class="slot-time">${escapeHtml(s.slotTime)}</div>
                            <div class="slot-capacity">Available: ${s.available} / ${s.capacity}</div>
                         </button>`;
            if (s.period === 'morning') morning += btn;
            else if (s.period === 'afternoon') afternoon += btn;
            else if (s.period === 'evening') evening += btn;
        }

        const html = `
            <details class="slot-group mt-6">
                <summary>Morning</summary>
                <div class="slot-grid">${morning || '<div class="text-gray-400 p-2">No morning slots</div>'}</div>
            </details>
            <details class="slot-group mt-3">
                <summary>Afternoon</summary>
                <div class="slot-grid">${afternoon || '<div class="text-gray-400 p-2">No afternoon slots</div>'}</div>
            </details>
            <details class="slot-group mt-3">
                <summary>Evening</summary>
                <div class="slot-grid">${evening || '<div class="text-gray-400 p-2">No evening slots</div>'}</div>
            </details>
        `;
        container.innerHTML = html;

        container.querySelectorAll('.slot-btn:not(.disabled)').forEach(btn => {
            btn.addEventListener('click', function (e) {
                const grid = this.closest('.slot-grid');
                grid.querySelectorAll('.slot-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
            });
        });
    }

    function renderClinicList() {
        const clinicBox = document.getElementById('clinicBox');
        clinicBox.innerHTML = '';
        if (!clinicsData.length) {
            clinicBox.innerHTML = '<div class="text-red-500">No clinics available</div>';
            return;
        }

        for (let clinic of clinicsData) {
            const clinicId = clinic.id;
            const uniqueSlotsId = `slots-${clinicId}`;
            const card = document.createElement('div');
            card.className = 'clinic-card glass rounded-3xl overflow-hidden border flex flex-col shadow-sm';
            card.setAttribute('data-clinic-id', clinicId);
            card.innerHTML = `
                <div class="clinic-topbar bg-gradient-to-r from-blue-500 to-indigo-500" style="height:8px;"></div>
                <div class="p-8 flex flex-col" style="height: calc(100% - 8px);">
                    <div style="min-height: 90px;">
                        <div class="clinic-name font-bold text-xl">${escapeHtml(clinic.name)}</div>
                        <div class="clinic-location text-gray-500 text-sm mt-1"><i class="fa-solid fa-location-dot mr-1"></i>${escapeHtml(clinic.location)}</div>
                    </div>
                    <div class="clinic-description text-gray-600 text-sm mt-2">${escapeHtml(clinic.description)}</div>
                    <div class="mt-6">
                        <label class="block text-sm font-bold text-gray-700 mb-2">Select Date</label>
                        <input type="date" class="date-picker w-full p-3 border border-gray-300 rounded-xl bg-white outline-none focus:ring-2 focus:ring-blue-500 transition shadow-sm">
                    </div>
                    <div id="${uniqueSlotsId}" class="slots-area mt-2">
                        <div class="text-center text-gray-400 py-4">Please select a date first</div>
                    </div>
                    <div class="clinic-footer mt-auto pt-4">
                        <button class="confirm-btn w-full py-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-2xl font-bold shadow-md transition transform hover:-translate-y-1">
                            Confirm & Book Now
                        </button>
                    </div>
                </div>
            `;
            clinicBox.appendChild(card);

            const dateInput = card.querySelector('.date-picker');
            const slotsContainer = card.querySelector(`#${uniqueSlotsId}`);
            dateInput.addEventListener('change', function () {
                const selectedDate = this.value;
                if (selectedDate) {
                    loadSlotsForClinic(clinicId, selectedDate, uniqueSlotsId);
                } else {
                    slotsContainer.innerHTML = '<div class="text-center text-gray-400 py-4">Please select a date first</div>';
                }
            });
            const today = new Date().toISOString().slice(0, 10);
            dateInput.value = today;
            loadSlotsForClinic(clinicId, today, uniqueSlotsId);
        }

        document.querySelectorAll('.confirm-btn').forEach(btn => {
            btn.addEventListener('click', async function (e) {
                const card = this.closest('.clinic-card');
                const clinicId = card.dataset.clinicId;
                const dateInput = card.querySelector('.date-picker');
                const regDate = dateInput.value;
                const activeSlot = card.querySelector('.slot-btn.active');
                const slotTime = activeSlot ? activeSlot.dataset.slotTime : null;

                if (!regDate) {
                    Swal.fire('Missing Date', 'Please select a date', 'warning');
                    return;
                }
                if (!slotTime) {
                    Swal.fire('Missing Time', 'Please choose an available time slot', 'warning');
                    return;
                }
                const today = new Date().toISOString().slice(0, 10);
                if (regDate < today) {
                    Swal.fire('Invalid Date', 'Cannot book past date', 'error');
                    return;
                }

                try {
                    const response = await fetch(contextPath + '/patient/book', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: `clinicId=${clinicId}&regDate=${regDate}&slotTime=${slotTime}`
                    });
                    const result = await response.json();
                    if (result.success) {
                        Swal.fire('Success', result.message, 'success').then(() => {
                            window.location.href = contextPath + '/patient/dashboard';
                        });
                    } else {
                        Swal.fire('Booking Failed', result.message, 'error');
                        loadSlotsForClinic(clinicId, regDate, card.querySelector('.slots-area').id);
                    }
                } catch (err) {
                    Swal.fire('Error', 'Network or server error: ' + err.message, 'error');
                }
            });
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        renderClinicList();
        document.getElementById('current-date').textContent = new Date().toLocaleDateString('en-US', {
            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
        });
    });

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