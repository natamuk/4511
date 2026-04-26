<%-- 
    Document   : settings-contents
    Created on : 2026年4月23日, 23:47:27
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class="max-w-4xl mx-auto glass p-8 rounded-3xl space-y-8">
    <h3 class="text-2xl font-bold text-gray-800 border-b pb-4">Global Policies</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="space-y-2">
            <label class="block text-sm font-bold text-gray-700 mb-2">Max Active Bookings per Patient</label>
            <p class="text-xs text-gray-500 mb-2">Limit how many future appointments a single patient can hold.</p>
            <input id="st-max" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
        </div>
        <div class="space-y-2">
            <label class="block text-sm font-bold text-gray-700 mb-2">Cancellation Deadline (Hours)</label>
            <p class="text-xs text-gray-500 mb-2">How many hours before the appointment can they cancel?</p>
            <input id="st-cancel" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
        </div>
    </div>
    <h3 class="text-2xl font-bold text-gray-800 border-b pb-4 mt-10">Feature Toggles</h3>
    
    <div class="flex items-center gap-4 p-4 border rounded-2xl bg-white shadow-sm">
        <label class="switch">
            <input type="checkbox" id="st-queue">
            <span class="slider"></span>
        </label>
        <div>
            <label class="font-bold text-gray-800 cursor-pointer">Enable Same-day Walk-in Queue</label>
            <p class="text-sm text-gray-500">Allow patients to join the queue on the day of service.</p>
        </div>
    </div>
    
    <div id="walkin-clinics-section" class="mt-4 p-4 border rounded-2xl bg-gray-50" style="display:none;">
        <h4 class="font-bold text-gray-700 mb-2">Select clinics that allow walk-in queue</h4>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3" id="clinics-list"></div>
        <p class="text-xs text-gray-400 mt-2">Patients will be able to join queue for selected clinics on the same day.</p>
    </div>
    
    <div class="flex items-center gap-4 p-4 border rounded-2xl bg-white shadow-sm">
        <label class="switch">
            <input type="checkbox" id="st-approval">
            <span class="slider"></span>
        </label>
        <div>
            <label class="font-bold text-gray-800 cursor-pointer">Require Booking Approval</label>
            <p class="text-sm text-gray-500">Doctors or staff must manually approve new online bookings.</p>
        </div>
    </div>
    
    <div class="pt-6 mt-6 border-t flex justify-end">
        <button id="save-settings-btn" class="px-8 py-3 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold transition shadow-md">Save Global Settings</button>
    </div>
</div>

<style>
    .switch {
        position: relative;
        display: inline-block;
        width: 52px;
        height: 28px;
    }
    .switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    .slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #ccc;
        transition: 0.3s;
        border-radius: 28px;
    }
    .slider:before {
        position: absolute;
        content: "";
        height: 22px;
        width: 22px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: 0.3s;
        border-radius: 50%;
    }
    input:checked + .slider {
        background-color: #4f46e5;
    }
    input:checked + .slider:before {
        transform: translateX(24px);
    }
</style>

<script>
    (function() {
        // 使用 home.jsp 中定義的全域變數 CONTEXT_PATH
        const contextPath = (typeof CONTEXT_PATH !== 'undefined' && CONTEXT_PATH) ? CONTEXT_PATH : '';
        console.log('Settings page using contextPath:', contextPath);

        let allClinics = [];
        let selectedClinicIds = new Set();

        function loadSettings() {
            fetch(contextPath + '/admin/settingsData', { credentials: 'same-origin' })
                .then(res => {
                    if (!res.ok) throw new Error('HTTP ' + res.status);
                    return res.json();
                })
                .then(data => {
                    const settings = data.settings || {};
                    document.getElementById('st-max').value = settings.max_active_bookings_per_patient || '3';
                    document.getElementById('st-cancel').value = settings.cancel_deadline_hours || '24';
                    document.getElementById('st-queue').checked = settings.same_day_queue_enabled === '1';
                    document.getElementById('st-approval').checked = settings.booking_approval_required === '1';
                    
                    const section = document.getElementById('walkin-clinics-section');
                    if (section) section.style.display = settings.same_day_queue_enabled === '1' ? 'block' : 'none';
                    
                    // 注意：API 返回的診所欄位名稱是 "name" 和 "id"
                    allClinics = data.clinics || [];
                    renderClinicCheckboxes();
                    
                    const enabledStr = settings.walkin_enabled_clinics || '';
                    selectedClinicIds.clear();
                    enabledStr.split(',').forEach(idStr => {
                        const id = parseInt(idStr.trim());
                        if (!isNaN(id)) selectedClinicIds.add(id);
                    });
                    updateCheckboxStates();
                })
                .catch(err => {
                    console.error('Failed to load settings', err);
                    Swal.fire('Error', 'Cannot load settings: ' + err.message, 'error');
                });
        }

        function renderClinicCheckboxes() {
            const container = document.getElementById('clinics-list');
            if (!container) return;
            if (!allClinics.length) {
                container.innerHTML = '<p class="text-gray-500">No active clinics found.</p>';
                return;
            }
            let html = '';
            allClinics.forEach(clinic => {
                // 使用 clinic.name（從 API 返回的欄位）
                html += `<label class="flex items-center gap-3 p-2 rounded-lg hover:bg-white transition">
                            <input type="checkbox" class="clinic-checkbox" value="${clinic.id}">
                            <span class="text-gray-700">${escapeHtml(clinic.name)}</span>
                        </label>`;
            });
            container.innerHTML = html;
            document.querySelectorAll('.clinic-checkbox').forEach(cb => {
                cb.addEventListener('change', function() {
                    const id = parseInt(this.value);
                    if (this.checked) selectedClinicIds.add(id);
                    else selectedClinicIds.delete(id);
                });
            });
        }

        function updateCheckboxStates() {
            document.querySelectorAll('.clinic-checkbox').forEach(cb => {
                const id = parseInt(cb.value);
                cb.checked = selectedClinicIds.has(id);
            });
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/[&<>]/g, function(m) {
                if (m === '&') return '&amp;';
                if (m === '<') return '&lt;';
                if (m === '>') return '&gt;';
                return m;
            });
        }

        function saveSettings() {
            const maxActive = document.getElementById('st-max').value;
            const cancelHours = document.getElementById('st-cancel').value;
            const queueEnabled = document.getElementById('st-queue').checked ? '1' : '0';
            const approvalRequired = document.getElementById('st-approval').checked ? '1' : '0';
            const walkinEnabledClinics = Array.from(selectedClinicIds).join(',');

            const formData = new URLSearchParams();
            formData.append('max_active_bookings_per_patient', maxActive);
            formData.append('cancel_deadline_hours', cancelHours);
            formData.append('same_day_queue_enabled', queueEnabled);
            formData.append('booking_approval_required', approvalRequired);
            formData.append('walkin_enabled_clinics', walkinEnabledClinics);

            fetch(contextPath + '/admin/settings/save', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData,
                credentials: 'same-origin'
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    Swal.fire('Saved', data.message, 'success');
                    loadSettings(); // 刷新 UI
                } else {
                    Swal.fire('Error', data.message || 'Save failed', 'error');
                }
            })
            .catch(err => {
                console.error(err);
                Swal.fire('Error', 'Network error', 'error');
            });
        }

        // 綁定事件（確保 DOM 元素存在）
        const queueToggle = document.getElementById('st-queue');
        if (queueToggle) {
            queueToggle.addEventListener('change', function(e) {
                const section = document.getElementById('walkin-clinics-section');
                if (section) section.style.display = e.target.checked ? 'block' : 'none';
            });
        }
        const saveBtn = document.getElementById('save-settings-btn');
        if (saveBtn) saveBtn.addEventListener('click', saveSettings);
        
        loadSettings();
    })();
</script>