<%-- 
    Document   : queue-contents
    Created on : 2026年4月22日, 22:15:46
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="max-w-5xl mx-auto space-y-6">
    <div class="glass rounded-3xl p-8">
        <div id="clinics-area" class="mb-6">
            <h3 class="text-2xl font-semibold mb-4">Join Walk-in Queue</h3>
            <div id="clinic-grid" class="grid-wrap"></div>
        </div>

        <h2 class="text-3xl font-bold mb-4">My Queue</h2>
        <div id="queue-container" class="space-y-4">
            <div class="text-center py-10 text-gray-500">
                <i class="fa-solid fa-spinner fa-pulse text-2xl"></i>
                <p>Loading...</p>
            </div>
        </div>
    </div>
</div>

<style>
.queue-clinic-card {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 160px;
    justify-content: space-between;
    border-radius: 14px;
}
.queue-clinic-title {
    height: 3.2rem;
    line-height: 1.2;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    font-weight: 700;
    font-size: 1.05rem;
    color: #0f172a;
}
.queue-clinic-meta { min-height: 1.25rem; color: #6b7280; }
.queue-clinic-btn { margin-top: 12px; }
.grid-wrap { display: grid; gap:16px; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); margin-top: 1rem; }
.disabled-btn { background: #e5e7eb !important; color: #6b7280 !important; cursor: not-allowed !important; }
.muted { color: #6b7280; }
</style>

<script>
(function(){
    var container = document.getElementById('queue-container');
    var clinicGrid = document.getElementById('clinic-grid');
    var contextPath = window.contextPath || '';
    if (!contextPath && typeof CONTEXT_PATH !== 'undefined') contextPath = CONTEXT_PATH;

    var lastQueueList = [];
    var clinicsCache = [];

    function escapeHtml(s){
        if (s === null || s === undefined) return '';
        return String(s).replace(/[&<>"'\/]/g, function(c){
            return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;','/':'&#x2F;'}[c];
        });
    }

    function loadQueue(){
        return fetch(contextPath + '/patient/queue/list')
            .then(function(res){
                if (!res.ok) throw new Error('HTTP ' + res.status);
                return res.json();
            })
            .then(function(data){
                lastQueueList = data.queue || [];
                renderQueueList(lastQueueList);
                if (clinicsCache && clinicsCache.length > 0){
                    renderClinics(clinicsCache, lastQueueList);
                } else {
                    return checkWalkinStatus().then(function(clinics){
                        renderClinics(clinics, lastQueueList);
                    });
                }
            })
            .catch(function(err){
                console.error('Load queue error:', err);
                container.innerHTML = '<div class="text-red-500 text-center py-10">Error loading queue. Please refresh.</div>';
            });
    }

    function renderQueueList(queueList){
        var html = '';
        if (queueList.length === 0){
            html = '<div class="text-center py-10 text-gray-500"><i class="fa-solid fa-users-slash text-4xl mb-3"></i><p>You have not joined any queue today.</p></div>';
        } else {
            queueList.forEach(function(item){
                var status = (item.status || '').toLowerCase();
                var qClass = '';
                if (status === 'waiting')
                    qClass = 'bg-yellow-100 text-yellow-700 border-yellow-200';
                else if (status === 'called')
                    qClass = 'bg-blue-100 text-blue-700 border-blue-200 animate-pulse';
                else if (status === 'skipped')
                    qClass = 'bg-red-100 text-red-700 border-red-200';
                else
                    qClass = 'bg-green-100 text-green-700 border-green-200';
                var clinicName = item.clinic || item.clinicName || 'Clinic';
                var ticketNo = item.queueNo || item.ticketNo || '';
                html += '<div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm">' +
                        '<div><p class="font-semibold text-lg text-gray-800">' + escapeHtml(clinicName) + '</p>' +
                        '<p class="text-sm text-gray-500 mt-1">Ticket Number: <span class="font-mono font-bold text-lg text-indigo-600">' + escapeHtml(ticketNo) + '</span></p></div>' +
                        '<span class="px-4 py-2 rounded-full text-sm font-bold border ' + qClass + '">' + (status ? status.toUpperCase() : '') + '</span></div>';
            });
        }
        container.innerHTML = html;
    }

    function checkWalkinStatus(){
        return fetch(contextPath + '/patient/queue/status')
            .then(function(res){
                if (!res.ok) throw new Error('HTTP ' + res.status);
                return res.json();
            })
            .then(function(data){
                var clinics = data.clinics || [];
                clinicsCache = clinics;
                return clinics;
            })
            .catch(function(err){
                console.error('Check walkin status error:', err);
                clinicGrid.innerHTML = '<div class="text-red-500 text-center py-10">Error loading clinics. Please refresh.</div>';
                return [];
            });
    }

    function renderClinics(clinics, queueList){
        clinicGrid.innerHTML = '';
        var waitingClinicIds = new Set();
        (queueList || []).forEach(function(q){
            try{
                var cid = q.clinicId || q.clinic_id || q.clinic || q.clinicName && q.clinicId;
                if (cid != null) waitingClinicIds.add(String(cid));
            } catch(e){}
        });

        var apptClinicIdsToday = new Set();
        try{
            var appts = window.appointmentsData || [];
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var dd = String(today.getDate()).padStart(2, '0');
            var todayStr = yyyy + '-' + mm + '-' + dd;
            appts.forEach(function(a){
                var aClinicId = a.clinicId || a.clinic_id || a.clinic || a.clinicName && a.clinicId;
                var aDate = a.date || a.regDate || a.appointmentDate || '';
                if (typeof aDate === 'string' && aDate.indexOf('T') !== -1) aDate = aDate.split('T')[0];
                if (aDate === todayStr && aClinicId != null) apptClinicIdsToday.add(String(aClinicId));
            });
        } catch(e){
            apptClinicIdsToday = new Set();
        }

        clinics.forEach(function(c){
            var id = c.id != null ? String(c.id) : (c.clinicId != null ? String(c.clinicId) : '');
            var name = c.name || c.clinic_name || c.clinicName || 'Clinic';
            var loc = c.location || c.address || '';
            var waitingCount = c.waitingCount != null ? c.waitingCount : (c.currentWaiting != null ? c.currentWaiting : 0);
            var disabled = apptClinicIdsToday.has(id) || waitingClinicIds.has(id);

            var card = document.createElement('div');
            card.className = 'p-5 bg-white border shadow-sm queue-clinic-card';
            card.innerHTML = ''
                + '<div>'
                + '<div class="queue-clinic-title">' + escapeHtml(name) + '</div>'
                + '<div class="text-sm muted mt-2">' + escapeHtml(loc) + '</div>'
                + '<div class="text-sm mt-3 queue-clinic-meta"><i class="fa-solid fa-users mr-1"></i> Current waiting: <span class="font-semibold text-gray-800">' + escapeHtml(String(waitingCount)) + '</span></div>'
                + '</div>';

            var btnWrap = document.createElement('div');
            var btn = document.createElement('button');
            btn.className = 'w-full px-4 py-2 rounded-xl font-medium queue-clinic-btn';
            btn.textContent = disabled ? (apptClinicIdsToday.has(id) ? 'Already booked (today)' : 'Already waiting') : 'Join Queue';

            if (disabled){
                btn.classList.add('disabled-btn');
                btn.setAttribute('disabled', 'disabled');
            } else {
                btn.classList.add('bg-emerald-600');
                btn.classList.add('text-white');
                btn.addEventListener('click', function(){
                    Swal.fire({
                        title: 'Join queue?',
                        text: 'Join ' + name + ' (Current waiting: ' + waitingCount + ')',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonText: 'Yes, join',
                        cancelButtonText: 'Cancel'
                    }).then(function(res){
                        if (res.isConfirmed) joinQueueByClinic(id, name);
                    });
                });
            }
            btnWrap.appendChild(btn);
            card.appendChild(btnWrap);
            clinicGrid.appendChild(card);
        });
    }

    function joinQueueByClinic(clinicId, clinicName){
        var url = contextPath + '/patient/queue/join';
        fetch(url, {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest'},
            body: 'clinicId=' + encodeURIComponent(clinicId)
        }).then(function(res){
            return res.text().then(function(text){
                var obj = null;
                try { obj = JSON.parse(text); } catch(e) { obj = null; }
                if (!res.ok){
                    var msg = (obj && obj.message) ? obj.message : ('Request failed (' + res.status + ')');
                    throw new Error(msg);
                }
                var success = obj && obj.success !== undefined ? obj.success : true;
                var message = (obj && obj.message) ? obj.message : ('Joined queue' + (obj && obj.queueNo ? ': ' + obj.queueNo : ''));
                if (success){
                    try {
                        window.notifications = window.notifications || [];
                        var newNotice = { title: 'Joined Walk-in Queue', message: message, time: new Date().toISOString(), type: 'success' };
                        window.notifications.unshift(newNotice);
                        if (typeof window.renderNotifications === 'function') window.renderNotifications();
                    } catch(e){}
                    loadQueue();
                    Swal.fire('Joined', message, 'success');
                } else {
                    Swal.fire('Unable to join', message, 'error');
                }
            });
        }).catch(function(err){
            console.error('Join error:', err);
            Swal.fire('Error', err.message || 'Join queue failed', 'error');
        });
    }

    loadQueue();
})();
</script>