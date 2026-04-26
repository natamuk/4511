<%-- 
    Document   : queue-contents
    Created on : 2026年4月22日, 22:15:46
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="max-w-5xl mx-auto space-y-6">
    <div class="glass rounded-3xl p-8">
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
</style>

<script>
(function() {
    var container = document.getElementById('queue-container');
    var contextPath = window.contextPath || '';
    if (!contextPath && typeof CONTEXT_PATH !== 'undefined') contextPath = CONTEXT_PATH;

    function loadQueue() {
        fetch(contextPath + '/patient/queue/list')
            .then(function(res) {
                if (!res.ok) throw new Error('HTTP ' + res.status);
                return res.json();
            })
            .then(function(data) {
                var queue = data.queue || [];
                if (queue.length > 0) {
                    showQueueList(queue);
                    var hasWaiting = queue.some(function(item) { return (item.status || '').toLowerCase() === 'waiting'; });
                    if (!hasWaiting) {
                        checkWalkinStatus(true); 
                    }
                } else {
                    checkWalkinStatus(false); 
                }
            })
            .catch(function(err) {
                console.error('Load queue error:', err);
                container.innerHTML = '<div class="text-red-500 text-center py-10">Error loading queue. Please refresh.</div>';
            });
    }

    function showQueueList(queueList) {
        var html = '';
        queueList.forEach(function(item) {
            var status = (item.status || '').toLowerCase();
            var qClass = '';
            if (status === 'waiting')
                qClass = 'bg-yellow-100 text-yellow-700 border-yellow-200';
            else if (status === 'called')
                qClass = 'bg-blue-100 text-blue-700 border-blue-200 animate-pulse';
            else
                qClass = 'bg-green-100 text-green-700 border-green-200';
            var clinicName = item.clinic || item.clinicName || 'Clinic';
            var ticketNo = item.queueNo || item.ticketNo || '';
            html += '<div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm">' +
                    '<div><p class="font-semibold text-lg text-gray-800">' + escapeHtml(clinicName) + '</p>' +
                    '<p class="text-sm text-gray-500 mt-1">Ticket Number: <span class="font-mono font-bold text-lg text-indigo-600">' + escapeHtml(ticketNo) + '</span></p></div>' +
                    '<span class="px-4 py-2 rounded-full text-sm font-bold border ' + qClass + '">' + (status ? status.toUpperCase() : '') + '</span></div>';
        });
        container.innerHTML = html;
    }

    function renderClinicCards(clinics, appendMode) {
        var gridHtml = '<div class="grid-wrap" id="clinic-grid">';
        clinics.forEach(function(c) {
            var name = c.name || c.clinic_name || ('Clinic ' + (c.id || ''));
            var loc = c.location || c.address || '';
            var waiting = c.waitingCount != null ? c.waitingCount : (c.currentWaiting || 0);
            gridHtml += '<div class="p-5 bg-white border shadow-sm queue-clinic-card">' +
                            '<div>' +
                                '<div class="queue-clinic-title">' + escapeHtml(name) + '</div>' +
                                '<div class="text-sm muted mt-2">' + escapeHtml(loc) + '</div>' +
                                '<div class="text-sm mt-3 queue-clinic-meta"><i class="fa-solid fa-users mr-1"></i> Current waiting: <span class="font-semibold text-gray-800">' + escapeHtml(String(waiting)) + '</span></div>' +
                            '</div>' +
                            '<div>' +
                                '<button class="w-full px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-medium queue-clinic-btn join-clinic-btn" data-clinic-id="' + escapeHtml(String(c.id)) + '" data-clinic-name="' + escapeHtml(name) + '">' +
                                    'Join Queue' +
                                '</button>' +
                            '</div>' +
                        '</div>';
        });
        gridHtml += '</div>';

        if (appendMode) container.insertAdjacentHTML('beforeend', gridHtml);
        else container.innerHTML = gridHtml;

        var btns = document.querySelectorAll('.join-clinic-btn');
        btns.forEach(function(b) {
            var nb = b.cloneNode(true);
            b.parentNode.replaceChild(nb, b);
            nb.addEventListener('click', function() {
                var clinicId = nb.getAttribute('data-clinic-id');
                var clinicName = nb.getAttribute('data-clinic-name');
                if (!clinicId) return;
                // optional confirmation
                Swal.fire({
                    title: 'Join queue?',
                    text: 'Join ' + clinicName + ' (Current waiting: ' + nb.closest('.queue-clinic-card').querySelector('.queue-clinic-meta span').textContent + ')',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, join',
                    cancelButtonText: 'Cancel'
                }).then(function(res) {
                    if (res.isConfirmed) {
                        joinQueueByClinic(clinicId, clinicName);
                    }
                });
            });
        });
    }

    function checkWalkinStatus(appendMode) {
        fetch(contextPath + '/patient/queue/status')
            .then(function(res) {
                if (!res.ok) throw new Error('HTTP ' + res.status);
                return res.json();
            })
            .then(function(data) {
                if (!data.enabled) {
                    var disabledHtml = '<div class="text-center py-10 text-gray-500"><i class="fa-solid fa-users-slash text-4xl mb-3"></i><p>Walk-in queue is disabled by administrator.</p></div>';
                    if (appendMode) container.insertAdjacentHTML('beforeend', disabledHtml); else container.innerHTML = disabledHtml;
                    return;
                }
                var clinics = data.clinics || [];
                if (clinics.length === 0) {
                    var noneHtml = '<div class="text-center py-10 text-gray-500"><i class="fa-solid fa-users-slash text-4xl mb-3"></i><p>No clinic currently accepts walk-in queue.</p></div>';
                    if (appendMode) container.insertAdjacentHTML('beforeend', noneHtml); else container.innerHTML = noneHtml;
                    return;
                }
                renderClinicCards(clinics, appendMode);
            })
            .catch(function(err) {
                console.error('Check walkin status error:', err);
                var errHtml = '<div class="text-red-500 text-center py-10">Error loading walk-in status. Please refresh.</div>';
                if (appendMode) container.insertAdjacentHTML('beforeend', errHtml); else container.innerHTML = errHtml;
            });
    }

    function joinQueueByClinic(clinicId, clinicName) {
        var url = contextPath + '/patient/queue/join';
        fetch(url, {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest'},
            body: 'clinicId=' + encodeURIComponent(clinicId)
        }).then(function(res) {
            return res.text().then(function(text) {
                var obj = null;
                try { obj = JSON.parse(text); } catch (e) { obj = null; }
                if (!res.ok) {
                    var msg = (obj && obj.message) ? obj.message : ('Request failed (' + res.status + ')');
                    throw new Error(msg);
                }
                var success = obj && obj.success !== undefined ? obj.success : true;
                var message = (obj && obj.message) ? obj.message : ('Joined queue' + (obj && obj.queueNo ? ': ' + obj.queueNo : ''));
                if (success) {
                    Swal.fire('Joined', message, 'success').then(function() {
                        location.reload();
                    });
                } else {
                    Swal.fire('Unable to join', message, 'error');
                }
            });
        }).catch(function(err) {
            console.error('Join error:', err);
            Swal.fire('Error', err.message || 'Join queue failed', 'error');
        });
    }

    function escapeHtml(s) {
        if (s === null || s === undefined) return '';
        return String(s).replace(/[&<>"'\/]/g, function (c) {
            return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;','/':'&#x2F;'}[c];
        });
    }

    loadQueue();
})();
</script>