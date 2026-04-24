<%-- 
    Document   : dashboard-contents
    Created on : 2026年4月23日, 02:22:23
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class="max-w-7xl mx-auto space-y-8">
    <div class="text-left flex flex-col md:flex-row md:items-end md:justify-between gap-4">
        <div>
            <h1 class="text-3xl md:text-4xl font-bold text-gray-800 mb-2">Welcome, Doctor</h1>
            <p class="text-gray-500 text-base md:text-lg">Clinic Department</p>
        </div>
    </div>

    <!-- Daily Check-in Card -->
    <div class="glass rounded-3xl p-6 bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-100">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div class="flex items-center gap-4">
                <i class="fa-solid fa-fingerprint text-4xl text-blue-600"></i>
                <div>
                    <h3 class="text-xl font-bold text-gray-800">Daily Check-in</h3>
                    <p id="checkin-status-text" class="text-sm text-gray-600 mt-1">Not checked in yet. Click the button below.</p>
                </div>
            </div>
            <button id="doctor-checkin-btn" class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition shadow-md flex items-center gap-2 justify-center">
                <i class="fa-solid fa-check-circle"></i> Check In
            </button>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-2 xl:grid-cols-4 gap-6">
        <div class="home-card glass rounded-3xl p-6 text-center">
            <i class="fa-solid fa-calendar-days text-blue-600 text-4xl mb-4"></i>
            <div class="text-4xl md:text-5xl font-bold text-blue-600">0</div>
            <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Total Booked</p>
        </div>
        <div class="home-card glass rounded-3xl p-6 text-center">
            <i class="fa-solid fa-users-line text-emerald-600 text-4xl mb-4"></i>
            <div class="text-4xl md:text-5xl font-bold text-emerald-600">0</div>
            <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Queue Count</p>
        </div>
        <div class="home-card glass rounded-3xl p-6 text-center">
            <i class="fa-solid fa-clipboard-check text-amber-600 text-4xl mb-4"></i>
            <div class="text-4xl md:text-5xl font-bold text-amber-600">0</div>
            <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Consulting Now</p>
        </div>
        <div class="home-card glass rounded-3xl p-6 text-center">
            <i class="fa-solid fa-check-double text-indigo-600 text-4xl mb-4"></i>
            <div class="text-4xl md:text-5xl font-bold text-indigo-600">0</div>
            <p class="text-sm md:text-lg mt-2 font-medium text-gray-600">Completed</p>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="glass rounded-3xl p-6">
        <h3 class="text-xl font-semibold mb-4">Quick Actions</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <button onclick="show('myAppointments')" class="home-card p-5 rounded-2xl bg-white border text-left">
                <i class="fa-solid fa-user-doctor text-blue-600 text-2xl mb-3"></i>
                <p class="font-semibold">My Appointments</p>
                <p class="text-xs text-gray-500">View schedule</p>
            </button>
            <button onclick="show('appointments')" class="home-card p-5 rounded-2xl bg-white border text-left">
                <i class="fa-solid fa-clipboard-list text-emerald-600 text-2xl mb-3"></i>
                <p class="font-semibold">Appointments</p>
                <p class="text-xs text-gray-500">Manage booking</p>
            </button>
            <button onclick="show('queue')" class="home-card p-5 rounded-2xl bg-white border text-left">
                <i class="fa-solid fa-bullhorn text-indigo-600 text-2xl mb-3"></i>
                <p class="font-semibold">Queue</p>
                <p class="text-xs text-gray-500">Call patients</p>
            </button>
            <button onclick="show('search')" class="home-card p-5 rounded-2xl bg-white border text-left">
                <i class="fa-solid fa-magnifying-glass text-amber-600 text-2xl mb-3"></i>
                <p class="font-semibold">Patient Search</p>
                <p class="text-xs text-gray-500">Find records</p>
            </button>
        </div>
    </div>
</div>

<script>
    document.getElementById('doctor-checkin-btn').addEventListener('click', function() {
        fetch('<%= request.getContextPath() %>/doctor/checkin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=checkin'
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                Swal.fire({
                    icon: 'success',
                    title: 'Checked In',
                    text: 'Check-in time: ' + data.checkinTime,
                    timer: 2000,
                    showConfirmButton: false
                });
                document.getElementById('checkin-status-text').innerHTML = 'Checked in at ' + data.checkinTime;
                document.getElementById('doctor-checkin-btn').disabled = true;
                document.getElementById('doctor-checkin-btn').classList.add('opacity-50', 'cursor-not-allowed');
                document.getElementById('doctor-checkin-btn').innerHTML = '<i class="fa-solid fa-check-circle"></i> Checked In';
            } else {
                if (data.alreadyChecked) {
                    Swal.fire({
                        icon: 'info',
                        title: 'Already Checked In',
                        text: data.message,
                        timer: 2000
                    });
                    document.getElementById('checkin-status-text').innerHTML = 'Checked in at ' + data.checkinTime;
                    document.getElementById('doctor-checkin-btn').disabled = true;
                    document.getElementById('doctor-checkin-btn').classList.add('opacity-50', 'cursor-not-allowed');
                    document.getElementById('doctor-checkin-btn').innerHTML = '<i class="fa-solid fa-check-circle"></i> Checked In';
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Check-in Failed',
                        text: data.message
                    });
                }
            }
        })
        .catch(err => {
            Swal.fire({
                icon: 'error',
                title: 'Network Error',
                text: 'Unable to connect to server'
            });
        });
    });
</script>