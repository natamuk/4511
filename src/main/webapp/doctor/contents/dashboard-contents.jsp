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