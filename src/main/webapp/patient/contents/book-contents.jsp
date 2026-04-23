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
        let clinicBox = document.getElementById('clinicBox');
        clinicBox.innerHTML = '';

        const clinics = window.PATIENT_DATA?.clinics || [];
        const clinicSlots = window.PATIENT_DATA?.clinicSlots || {};

        if (!clinics || clinics.length === 0) {
            clinicBox.innerHTML = "<div class='text-red-500'>No clinics available</div>";
            return;
        }

        for (let i = 0; i < clinics.length; i++) {
            let clinic = clinics[i];
            let slots = clinicSlots[clinic.id] || [];

            let morning = "";
            let afternoon = "";
            let evening = "";

            for (let j = 0; j < slots.length; j++) {
                let s = slots[j];
                let btn = `
                <button class="slot-btn">
                    <div class="slot-time">${s.slotTime}</div>
                </button>
            `;

                if (s.period === "morning")
                    morning += btn;
                if (s.period === "afternoon")
                    afternoon += btn;
                if (s.period === "evening")
                    evening += btn;
            }

            let card = `
        <div class="clinic-card glass rounded-3xl overflow-hidden border flex flex-col shadow-sm" style="height: 100%;">
            <div class="clinic-topbar bg-gradient-to-r from-blue-500 to-indigo-500" style="height: 8px;"></div>
            <div class="p-8 flex flex-col" style="height: calc(100% - 8px);">
                
                <div style="min-height: 90px;">
                    <div class="clinic-name">${clinic.clinic_name}</div>
                    <div class="clinic-location">
                        <i class="fa-solid fa-location-dot mr-1"></i>${clinic.location}
                    </div>
                </div>

                <div class="clinic-description" style="min-height: 60px; margin-top: 8px;">${clinic.description}</div>

                <div class="mt-6" style="min-height: 85px;">
                    <label class="block text-sm font-bold text-gray-700 mb-2">Select Date</label>
                    <input type="date" class="w-full p-3 border border-gray-300 rounded-xl bg-white outline-none focus:ring-2 focus:ring-blue-500 transition shadow-sm">
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
                    <button class="w-full py-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-2xl font-bold shadow-md transition transform hover:-translate-y-1">
                        Confirm & Book Now
                    </button>
                </div>
            </div>
        </div>`;

            clinicBox.innerHTML += card;
        }
    }

    renderClinicList();
</script>