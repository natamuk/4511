<%-- 
    Document   : appointments-contents
    Created on : 2026年4月23日, 02:22:34
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%@ page import="java.util.*" %>

<%
    String ctx = request.getContextPath();
    List<Map<String, Object>> appointments = (List<Map<String, Object>>) request.getAttribute("appointments");
    if (appointments == null) appointments = new ArrayList<>();
%>

<div class='glass rounded-3xl p-6'>
    <h3 class='text-2xl font-semibold mb-6'>Appointment Management</h3>
    <div class='overflow-x-auto'>
        <table class='w-full text-sm min-w-[900px] text-left'>
            <thead class='border-b bg-gray-50 text-gray-600'>
                <tr>
                    <th class='py-4 px-4 rounded-tl-xl'>Date & Time</th>
                    <th class='py-4 px-4'>Ticket No.</th>
                    <th class='py-4 px-4'>Patient Name</th>
                    <th class='py-4 px-4'>Service</th>
                    <th class='py-4 px-4'>Status</th>
                    <th class='py-4 px-4 rounded-tr-xl text-center'>Action</th>
                </tr>
            </thead>
            <tbody class='divide-y'>
                <%
                for (Map<String, Object> item : appointments) {
                    int statusCode = item.get("statusCode") == null ? 0 : ((Number)item.get("statusCode")).intValue();
                    String date = item.get("date") == null ? "" : item.get("date").toString();
                    String time = item.get("time") == null ? "" : item.get("time").toString();
                    String ticketNo = item.get("ticketNo") == null ? "-" : item.get("ticketNo").toString();
                    String patient = item.get("patient") == null ? "-" : item.get("patient").toString();
                    String service = item.get("service") == null ? "-" : item.get("service").toString();
                    int id = item.get("id") == null ? 0 : ((Number)item.get("id")).intValue();
                %>
                <tr class="hover:bg-gray-50/50 transition">
                    <td class="py-4 px-4 font-medium"><%= date %> <%= time %></td>
                    <td class="px-4 text-gray-500"><%= ticketNo %></td>
                    <td class="px-4 font-bold text-gray-800"><%= patient %></td>
                    <td class="px-4 text-gray-600"><%= service %></td>
                    <td class="px-4">
                        <% if (statusCode == 1) { %>
                        <span class="px-2 py-1 bg-yellow-100 text-yellow-700 text-xs rounded">Pending</span>
                        <% } else if (statusCode == 3) { %>
                        <span class="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">Checked In</span>
                        <% } else if (statusCode == 4) { %>
                        <span class="px-2 py-1 bg-indigo-100 text-indigo-700 text-xs rounded">Consulting</span>
                        <% } else if (statusCode == 5) { %>
                        <span class="px-2 py-1 bg-green-100 text-green-700 text-xs rounded">Done</span>
                        <% } else { %>
                        <span class="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded">Rejected</span>
                        <% } %>
                    </td>
                    <td class="px-4 text-center">
                        <% if (statusCode == 1) { %>
                            <form method="post" action="<%= ctx %>/doctor/action" style="display:inline;">
                                <input type="hidden" name="action" value="approve" />
                                <input type="hidden" name="id" value="<%= id %>" />
                                <button type="submit" class="px-3 py-1.5 mr-1 bg-green-50 text-green-700 font-medium rounded-lg hover:bg-green-100 transition border border-green-200">
                                    <i class="fa-solid fa-check mr-1"></i>Approve
                                </button>
                            </form>

                            <form method="post" action="<%= ctx %>/doctor/action" style="display:inline;">
                                <input type="hidden" name="action" value="reject" />
                                <input type="hidden" name="id" value="<%= id %>" />
                                <button type="submit" class="px-3 py-1.5 bg-red-50 text-red-700 font-medium rounded-lg hover:bg-red-100 transition border border-red-200">
                                    <i class="fa-solid fa-xmark mr-1"></i>Reject
                                </button>
                            </form>
                        <% } else { %>
                        <span class="text-gray-400 text-xs font-medium">Processed</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>

                <% if (appointments.isEmpty()) { %>
                <tr>
                    <td colspan="6" class="text-center py-10 text-gray-500">No appointment records found.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>