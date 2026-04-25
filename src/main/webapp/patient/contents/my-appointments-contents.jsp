<%-- 
    Document   : my-appointments-contents
    Created on : 2026年4月22日, 22:06:00
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class="max-w-5xl mx-auto space-y-6">
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6">
            <h3 class="text-2xl font-semibold">My Appointments</h3>
            <button onclick="loadPage('book')" class="px-4 py-2 bg-blue-600 text-white rounded-xl shadow-sm hover:bg-blue-700 transition">New Booking</button>
        </div>
        <div id="my-appointments-list" class="space-y-4"></div>
    </div>
</div>

<script>
    function renderMyAppointments() {
        const container = document.getElementById('my-appointments-list');
        const appointments = window.appointmentsData || [];
        
        if (!appointments.length) {
            container.innerHTML = '<div class="text-center py-16 text-gray-500"><i class="fa-regular fa-calendar-xmark text-5xl mb-4"></i><p class="text-lg">No records found</p></div>';
            return;
        }
        
        let html = '';
        for (const item of appointments) {
            const status = item.status || '';
            let statusClass = '';
            if (status === 'Booked') statusClass = 'bg-blue-50 text-blue-700 border-blue-200';
            else if (status === 'Completed') statusClass = 'bg-green-50 text-green-700 border-green-200';
            else statusClass = 'bg-red-50 text-red-700 border-red-200';
            
            let timeSlotDisplay = item.timeSlot || '';
            if (timeSlotDisplay === 1) timeSlotDisplay = 'Morning';
            else if (timeSlotDisplay === 2) timeSlotDisplay = 'Afternoon';
            else if (timeSlotDisplay === 3) timeSlotDisplay = 'Evening';
            
            html += `
                <div class="p-6 border rounded-3xl bg-white flex flex-col md:flex-row md:items-center md:justify-between gap-6 shadow-sm hover:shadow-md transition">
                    <div class="flex-1">
                        <div class="flex items-center gap-3 mb-2">
                            <h4 class="font-bold text-xl text-gray-800">${escapeHtml(item.clinicName || item.departmentName || 'Clinic')}</h4>
                            <span class="px-3 py-1 rounded-full text-xs font-bold border ${statusClass}">${escapeHtml(status)}</span>
                        </div>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-gray-600 mt-3">
                            <p><i class="fa-regular fa-calendar text-gray-400 w-5"></i> <b>Date:</b> ${escapeHtml(item.date || '')}</p>
                            <p><i class="fa-regular fa-clock text-gray-400 w-5"></i> <b>Time:</b> ${escapeHtml(timeSlotDisplay)}</p>
                            <p><i class="fa-solid fa-user-doctor text-gray-400 w-5"></i> <b>Doctor:</b> ${escapeHtml(item.doctorName || 'Not Assigned')}</p>
                            <p><i class="fa-solid fa-ticket text-gray-400 w-5"></i> <b>Queue No:</b> ${escapeHtml(item.queueNo || '-')}</p>
                        </div>
                    </div>
                    <div class="flex flex-col sm:flex-row gap-3 md:w-auto w-full pt-4 md:pt-0 border-t md:border-t-0 border-gray-100">
                        <button class="flex-1 px-4 py-2.5 rounded-xl bg-blue-50 hover:bg-blue-100 text-blue-700 font-medium transition" onclick="showAppointmentQR('${item.regNo || item.id}')">
                            <i class="fa-solid fa-qrcode"></i> QR
                        </button>
                        ${status === 'Booked' ? `
                            <button class="flex-1 px-4 py-2.5 rounded-xl bg-amber-50 hover:bg-amber-100 text-amber-700 font-medium transition" onclick="rescheduleAppointment(${item.id})">
                                <i class="fa-regular fa-pen-to-square"></i> Reschedule
                            </button>
                            <button class="flex-1 px-4 py-2.5 rounded-xl bg-red-50 hover:bg-red-100 text-red-600 font-medium transition" onclick="cancelAppointment(${item.id})">
                                <i class="fa-solid fa-xmark"></i> Cancel
                            </button>
                        ` : ''}
                    </div>
                </div>
            `;
        }
        container.innerHTML = html;
    }
    
    function escapeHtml(str) {
        if (!str) return '';
        return String(str).replace(/[&<>]/g, function(m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        });
    }
    
    function showAppointmentQR(regNo) {
        Swal.fire({
            title: 'Check-in QR Code',
            text: 'Show this QR code at the reception',
            html: `<div class="flex flex-col items-center"><canvas id="qrCanvas" class="mt-2 border p-2 rounded"></canvas><p class="font-mono mt-3">${regNo}</p></div>`,
            didOpen: () => {
                QRCode.toCanvas(document.getElementById('qrCanvas'), regNo, { width: 200, margin: 1 });
            }
        });
    }
    
    async function cancelAppointment(registrationId) {
        const confirm = await Swal.fire({
            title: 'Cancel appointment?',
            text: 'This action cannot be undone.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Yes, cancel it',
            cancelButtonText: 'No, keep it'
        });
        if (!confirm.isConfirmed) return;
        
        try {
            const resp = await fetch(contextPath + '/patient/cancel-booking', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `registrationId=${registrationId}`
            });
            const result = await resp.json();
            if (result.success) {
                Swal.fire('Cancelled', 'Your appointment has been cancelled.', 'success').then(() => {
                    window.location.reload();
                });
            } else {
                Swal.fire('Error', result.message, 'error');
            }
        } catch (err) {
            Swal.fire('Error', 'Network error', 'error');
        }
    }
    
    function rescheduleAppointment(registrationId) {
        Swal.fire('Info', 'Reschedule feature will be implemented soon.', 'info');
    }
    
    renderMyAppointments();
</script>