<%-- 
    Document   : notifications-contents
    Created on : 2026年4月22日, 22:15:53
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="max-w-4xl mx-auto glass rounded-3xl p-8">
    <h3 class="text-2xl font-semibold mb-6">Notifications</h3>
    <div class="space-y-4" id="notifications-panel"></div>
</div>

<script>
    function escapeHtml(s) {
        if (s === null || s === undefined) return '';
        return String(s).replace(/[&<>"'\/]/g, function (c) {
            return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;','/':'&#x2F;'}[c];
        });
    }

    function updateSidebarBadge(count) {
        var badge = document.getElementById('notifications-badge');
        if (badge) {
            badge.innerHTML = count > 0 ? ('<span class="bg-red-500 text-white text-[10px] w-5 h-5 flex items-center justify-center rounded-full ml-auto">' + count + '</span>') : '';
        }
    }

    function renderNotifications(notifications) {
        var panel = document.getElementById('notifications-panel');
        if (!panel) return;
        var list = notifications || [];
        if (!list.length) {
            panel.innerHTML = '<div class="text-center py-12 text-gray-500"><i class="fa-regular fa-bell-slash text-4xl mb-3"></i><p>No notifications</p></div>';
            updateSidebarBadge(0);
            return;
        }
        panel.innerHTML = list.map(function(n) {
            var title = escapeHtml(n.title || '');
            var message = escapeHtml(n.message || '');
            var typeClass = (n.type === 'success') ? 'bg-green-100 text-green-700' : (n.type === 'warning') ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700';
            var time = '';
            if (n.time) {
                try {
                    var d = new Date(n.time);
                    if (!isNaN(d.getTime())) {
                        time = d.toLocaleString();
                    } else {
                        time = String(n.time);
                    }
                } catch (e) {
                    time = String(n.time);
                }
            }
            return '<div class="p-4 border rounded-2xl bg-white flex items-start gap-4 shadow-sm">' +
                   '<div class="w-10 h-10 rounded-full ' + typeClass + ' flex items-center justify-center"><i class="fa-solid fa-bell"></i></div>' +
                   '<div class="flex-1"><div class="flex items-center justify-between"><p class="font-semibold text-gray-800">' + title + '</p><span class="text-xs text-gray-400">' + escapeHtml(time) + '</span></div>' +
                   '<p class="text-gray-600 mt-1">' + message + '</p></div></div>';
        }).join('');
        updateSidebarBadge(list.length);
    }

    function loadNotifications() {
        var panel = document.getElementById('notifications-panel');
        if (panel) {
            panel.innerHTML = '<div class="text-center py-12 text-gray-500"><i class="fa-solid fa-spinner fa-pulse text-2xl"></i><p>Loading...</p></div>';
        }
        var apiUrl = '<%= request.getContextPath() %>/patient/notifications/json';
        fetch(apiUrl)
            .then(function(res) {
                if (!res.ok) throw new Error('HTTP ' + res.status);
                return res.json();
            })
            .then(function(data) {
                renderNotifications(data);
            })
            .catch(function(err) {
                console.error('Load notifications error:', err);
                if (panel) {
                    panel.innerHTML = '<div class="text-center py-12 text-red-500"><i class="fa-regular fa-bell-slash text-4xl mb-3"></i><p>Failed to load notifications.</p></div>';
                }
            });
    }

    loadNotifications();
</script>