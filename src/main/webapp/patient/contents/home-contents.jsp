<%-- 
    Document   : home-contents
    Created on : 2026年4月22日, 21:09:12
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div id="home-dynamic-content" class="max-w-6xl mx-auto space-y-10">
    <div class="text-left">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-800 mb-2" id="welcome-name">Welcome back, Patient</h1>
        <p class="text-gray-500 text-lg" id="today-date"></p>
    </div>
    <div id="home-cards"></div>
    <div id="quick-services"></div>
    <div id="home-notifications"></div>
</div>

<script>
    const profile = window.parent ? (window.parent.patientProfile || {}) : (window.patientProfile || {});
    const appointments = window.appointmentsData || [];
    const queue = window.queueData || [];
    const notifications = window.notifications || [];
    const realName = profile.realName || 'Patient';

    document.getElementById('welcome-name').innerText = 'Welcome back, ' + realName;
    const today = new Date();
    document.getElementById('today-date').innerText = 'Today is ' + today.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });

    function escapeHtml(str) {
        if (!str) return '';
        return String(str).replace(/[&<>]/g, function(m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        });
    }

    const nextAppointment = appointments.length > 0 ? appointments[0] : null;
    let nextApptHtml = 'No appointments yet';
    if (nextAppointment) {
        let dateStr = nextAppointment.date || '';
        let slot = nextAppointment.timeSlot;
        let slotStr = slot === 1 ? 'Morning' : (slot === 2 ? 'Afternoon' : (slot === 3 ? 'Evening' : ''));
        nextApptHtml = dateStr + (slotStr ? ' ' + slotStr : '');
    }

    const queueNo = queue.length > 0 ? (queue[0].queueNo || 'N/A') : 'N/A';

    const latestNotification = notifications.length > 0 ? notifications[0] : null;
    const notifTitle = latestNotification ? (latestNotification.title || 'Notification') : 'No new notifications';
    const notifMsg = latestNotification ? (latestNotification.message || '') : '';
    const truncatedMsg = notifMsg.length > 60 ? notifMsg.substring(0,60) + '...' : notifMsg;

    const cardsHtml = `
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
            <div class="absolute top-0 right-0 w-24 h-24 bg-blue-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
            <div class="relative">
                <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-calendar-check text-blue-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Next Appointment</h3></div>
                <p class="text-2xl font-bold text-gray-800 mt-2 mb-2">${escapeHtml(nextApptHtml)}</p>
                <p onclick="loadPage('my')" class="text-blue-600 font-medium cursor-pointer hover:underline">Manage Appointments</p>
            </div>
        </div>
        <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
            <div class="absolute top-0 right-0 w-24 h-24 bg-emerald-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
            <div class="relative">
                <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-users-line text-emerald-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Current Queue</h3></div>
                <p class="text-4xl font-bold text-emerald-600 mt-2 mb-2">${escapeHtml(queueNo)}</p>
                <p onclick="loadPage('queue')" class="text-gray-500 cursor-pointer hover:underline">View Live Queue</p>
            </div>
        </div>
        <div class="home-card glass rounded-3xl p-8 border border-white/70 relative overflow-hidden">
            <div class="absolute top-0 right-0 w-24 h-24 bg-purple-100 rounded-full -mr-8 -mt-8 opacity-50"></div>
            <div class="relative">
                <div class="flex items-center gap-3 mb-4"><i class="fa-solid fa-bell text-purple-600 text-2xl"></i><h3 class="text-lg font-semibold text-gray-700">Latest Notification</h3></div>
                <div class="space-y-3 mt-2 text-base">
                    <p class="text-emerald-600 font-medium">✓ ${escapeHtml(notifTitle)}</p>
                    <p class="text-gray-600">${escapeHtml(truncatedMsg)}</p>
                </div>
            </div>
        </div>
    </div>`;
    document.getElementById('home-cards').innerHTML = cardsHtml;

    document.getElementById('quick-services').innerHTML = `
    <div><h2 class="text-2xl font-bold mb-6 text-gray-800">Quick Services</h2>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
        <div onclick="loadPage('book')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-calendar-plus text-blue-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Book Appointment</p></div>
        <div onclick="loadPage('queue')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-ticket text-emerald-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Join Queue</p></div>
        <div onclick="loadPage('my')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-list-check text-purple-600 text-3xl mb-3"></i><p class="font-semibold mt-2">My Appointments</p></div>
        <div onclick="loadPage('profile')" class="quick-btn glass rounded-2xl p-6 text-center cursor-pointer"><i class="fa-solid fa-user-shield text-amber-600 text-3xl mb-3"></i><p class="font-semibold mt-2">Security</p></div>
    </div></div>`;

    let notifHtml = '';
    if (notifications.length === 0) {
        notifHtml = '<div class="text-center py-8 text-gray-500"><i class="fa-regular fa-bell-slash text-4xl mb-3"></i><p>No notifications yet</p></div>';
    } else {
        const latestThree = notifications.slice(0,3);
        latestThree.forEach(n => {
            const type = n.type || 'info';
            const typeClass = type === 'success' ? 'bg-green-100 text-green-700' : (type === 'warning' ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700');
            let timeStr = '';
            if (n.time) {
                try { timeStr = new Date(n.time).toLocaleString(); } catch(e) { timeStr = n.time; }
            }
            notifHtml += `<div class="p-4 border rounded-2xl bg-white flex items-start gap-4 shadow-sm">
                <div class="w-10 h-10 rounded-full ${typeClass} flex items-center justify-center flex-shrink-0"><i class="fa-solid fa-bell"></i></div>
                <div class="flex-1">
                    <div class="flex items-center justify-between gap-4 flex-wrap"><p class="font-semibold text-gray-800">${escapeHtml(n.title || '')}</p><span class="text-xs text-gray-400 whitespace-nowrap">${escapeHtml(timeStr)}</span></div>
                    <p class="text-gray-600 mt-1">${escapeHtml(n.message || '')}</p>
                </div>
            </div>`;
        });
    }
    document.getElementById('home-notifications').innerHTML = `<div class="glass rounded-3xl p-8"><div class="flex items-center justify-between mb-4"><h2 class="text-2xl font-bold text-gray-800">Notifications</h2><button onclick="loadPage('notifications')" class="text-sm text-blue-600 font-medium hover:underline">View All</button></div><div class="space-y-4">${notifHtml}</div></div>`;
</script>