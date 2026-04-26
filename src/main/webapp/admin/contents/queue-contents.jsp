<%-- 
    Document   : queue-contents
    Created on : 2026年4月23日, 23:47:00
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<%
    List<Map<String, Object>> queue = (List<Map<String, Object>>) request.getAttribute("queue");
    if (queue == null) queue = new ArrayList<>();
    boolean walkinEnabled = Boolean.TRUE.equals(request.getAttribute("sameDayQueueEnabled"));
    List<Map<String, Object>> availableClinics = (List<Map<String, Object>>) request.getAttribute("availableWalkinClinics");
    if (availableClinics == null) availableClinics = new ArrayList<>();
%>
<div class="max-w-5xl mx-auto space-y-6">
    <div class="glass rounded-3xl p-8">
        <h2 class="text-3xl font-bold mb-4">My Queue</h2>
        <div class="space-y-4">
            <% if (!queue.isEmpty()) { %>
                <% for (Map<String, Object> item : queue) {
                    String status = (String) item.get("status");
                    String qClass = "";
                    if ("waiting".equals(status)) {
                        qClass = "bg-yellow-100 text-yellow-700 border-yellow-200";
                    } else if ("called".equals(status)) {
                        qClass = "bg-blue-100 text-blue-700 border-blue-200 animate-pulse";
                    } else {
                        qClass = "bg-green-100 text-green-700 border-green-200";
                    }
                %>
                <div class="p-5 border rounded-2xl bg-white flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm">
                    <div>
                        <p class="font-semibold text-lg text-gray-800"><%= item.get("clinic") %></p>
                        <p class="text-sm text-gray-500 mt-1">
                            Ticket Number:
                            <span class="font-mono font-bold text-lg text-indigo-600"><%= item.get("ticketNo") %></span>
                        </p>
                    </div>
                    <span class="px-4 py-2 rounded-full text-sm font-bold border <%= qClass %>">
                        <%= status.toUpperCase() %>
                    </span>
                </div>
                <% } %>
            <% } else { %>
                <div class="text-center py-10 text-gray-500">
                    <i class="fa-solid fa-users-slash text-4xl mb-3"></i>
                    <p>No active queue entry.</p>
                    <% if (walkinEnabled && !availableClinics.isEmpty()) { %>
                        <button id="joinQueueBtn" class="mt-4 px-4 py-2 bg-indigo-600 text-white rounded-xl">Join Walk-in Queue</button>
                    <% } else if (walkinEnabled && availableClinics.isEmpty()) { %>
                        <p class="text-sm text-gray-400 mt-4">No clinic currently accepts walk-in queue.</p>
                    <% } else if (!walkinEnabled) { %>
                        <p class="text-sm text-gray-400 mt-4">Walk-in queue is disabled by administrator.</p>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
</div>

<script>
    var joinBtn = document.getElementById('joinQueueBtn');
    if (joinBtn) {
        joinBtn.addEventListener('click', function() {
            var clinics = <%= new com.google.gson.Gson().toJson(availableClinics) %>;
            var options = {};
            clinics.forEach(function(c) {
                options[c.id] = c.name;
            });
            Swal.fire({
                title: 'Select Clinic',
                input: 'select',
                inputOptions: options,
                inputPlaceholder: 'Choose a clinic',
                showCancelButton: true,
                preConfirm: function(clinicId) {
                    if (!clinicId) {
                        Swal.showValidationMessage('Please select a clinic');
                        return false;
                    }
                    return fetch((window.CONTEXT_PATH || '') + '/patient/queue/join', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                        body: 'clinicId=' + encodeURIComponent(clinicId)
                    }).then(function(res) {
                        if (res.ok) return res.json();
                        return res.json().then(function(err) { throw new Error(err.message || 'Failed'); });
                    }).then(function(data) {
                        if (data.success) {
                            Swal.fire('Joined', data.message, 'success').then(function() {
                                location.reload();
                            });
                        } else {
                            Swal.showValidationMessage(data.message || 'Unable to join');
                        }
                    }).catch(function(err) {
                        Swal.showValidationMessage(err.message);
                    });
                }
            });
        });
    }
</script>