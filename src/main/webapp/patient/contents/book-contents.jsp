<%-- 
    Document   : book-contents
    Created on : 2026年4月22日, 22:05:44
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class="max-w-7xl mx-auto">
    <h2 class="text-3xl font-bold mb-2">Book Appointment</h2>
    <p class="text-gray-600 mb-10">Choose clinic & time slot</p>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8" id="clinicBox"></div>
</div>

<script>
    function renderClinicList() {
        const clinicBox = document.getElementById('clinicBox');
        clinicBox.innerHTML = '';

        const clinics = window.PATIENT_DATA?.clinics || [];
        const clinicSlots = window.PATIENT_DATA?.clinicSlots || {};

        if (!clinics.length) {
            clinicBox.innerHTML = '<div class="text-red-500">No clinics available</div>';
            return;
        }

        for (let i = 0; i < clinics.length; i++) {
            const clinic = clinics[i];
            const slots = clinicSlots[clinic.id] || [];

            let morning = '', afternoon = '', evening = '';
            for (let j = 0; j < slots.length; j++) {
                const s = slots[j];
                const btn = `<button type="button" class="slot-btn" data-slot-time="${escapeHtml(s.slotTime)}">
                                <div class="slot-time">${escapeHtml(s.slotTime)}</div>
                                <div class="slot-capacity">Capacity: ${s.capacity}</div>
                             </button>`;
                if (s.period === 'morning') morning += btn;
                else if (s.period === 'afternoon') afternoon += btn;
                else if (s.period === 'evening') evening += btn;
            }

            const card = `
                <div class="clinic-card glass rounded-3xl overflow-hidden border flex flex-col shadow-sm" data-clinic-id="${clinic.id}">
                    <div class="clinic-topbar bg-gradient-to-r from-blue-500 to-indigo-500"></div>
                    <div class="p-8 flex flex-col" style="height: calc(100% - 8px);">
                        <div style="min-height: 90px;">
                            <div class="clinic-name">${escapeHtml(clinic.name)}</div>
                            <div class="clinic-location"><i class="fa-solid fa-location-dot mr-1"></i>${escapeHtml(clinic.location)}</div>
                        </div>
                        <div class="clinic-description" style="min-height: 60px; margin-top: 8px;">${escapeHtml(clinic.description)}</div>

                        <div class="mt-6" style="min-height: 85px;">
                            <label class="block text-sm font-bold text-gray-700 mb-2">Select Date</label>
                            <input type="date" class="date-picker w-full p-3 border border-gray-300 rounded-xl bg-white outline-none focus:ring-2 focus:ring-blue-500 transition shadow-sm">
                        </div>

                        <details class="slot-group mt-6">
                            <summary>Morning</summary>
                            <div class="slot-grid">${morning}</div>
                        </details>
                        <details class="slot-group mt-3">
                            <summary>Afternoon</summary>
                            <div class="slot-grid">${afternoon}</div>
                        </details>
                        <details class="slot-group mt-3">
                            <summary>Evening</summary>
                            <div class="slot-grid">${evening}</div>
                        </details>

                        <div class="clinic-footer mt-auto">
                            <button class="confirm-btn w-full py-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-2xl font-bold shadow-md transition transform hover:-translate-y-1">
                                Confirm & Book Now
                            </button>
                        </div>
                    </div>
                </div>
            `;
            clinicBox.innerHTML += card;
        }

        document.querySelectorAll('.slot-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const grid = this.closest('.slot-grid');
                if (grid) {
                    grid.querySelectorAll('.slot-btn').forEach(b => b.classList.remove('active'));
                }
                this.classList.add('active');
            });
        });

        document.querySelectorAll('.confirm-btn').forEach(btn => {
            btn.addEventListener('click', async function () {
                const card = this.closest('.clinic-card');
                const clinicId = card.dataset.clinicId;
                const dateInput = card.querySelector('.date-picker');
                const regDate = dateInput.value;
                const activeSlot = card.querySelector('.slot-btn.active');
                const slotTime = activeSlot ? activeSlot.dataset.slotTime : null;

                if (!regDate) {
                    Swal.fire('Missing Date', 'Please select a date first', 'warning');
                    return;
                }
                if (!slotTime) {
                    Swal.fire('Missing Time', 'Please choose a time slot', 'warning');
                    return;
                }

                const today = new Date().toISOString().slice(0, 10);
                if (regDate < today) {
                    Swal.fire('Invalid Date', 'You cannot book a past date', 'error');
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
                    }
                } catch (err) {
                    console.error('Fetch error:', err);
                    Swal.fire('Error', 'Network or server error: ' + err.message, 'error');
                }
            });
        });
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/[&<>]/g, function (m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        });
    }

    renderClinicList();
</script>