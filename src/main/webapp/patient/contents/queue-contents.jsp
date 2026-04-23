<%-- 
    Document   : queue-contents
    Created on : 2026年4月22日, 22:15:46
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<%
    List<Map<String, Object>> queue = (List<Map<String, Object>>) request.getAttribute("queue");
    if (queue == null)
        queue = new ArrayList<>();
%>

<div class="max-w-5xl mx-auto space-y-6">
    <div class="glass rounded-3xl p-8">
        <h2 class="text-3xl font-bold mb-4">My Queue</h2>
        <div class="space-y-4">
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
                    <p class="font-semibold text-lg text-gray-800"><%= item.get("clinicName")%></p>
                    <p class="text-sm text-gray-500 mt-1">
                        Ticket Number:
                        <span class="font-mono font-bold text-lg text-indigo-600"><%= item.get("queueNo")%></span>
                    </p>
                </div>
                <span class="px-4 py-2 rounded-full text-sm font-bold border <%= qClass%>">
                    <%= status.toUpperCase()%>
                </span>
            </div>
            <% } %>

            <% if (queue.isEmpty()) { %>
            <div class="text-center py-10 text-gray-500">
                <i class="fa-solid fa-users-slash text-4xl mb-3"></i>
                <p>No queue</p>
            </div>
            <% }%>
        </div>
    </div>
</div>