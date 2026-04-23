<%-- 
    Document   : record-contents
    Created on : 2026年4月22日, 22:16:12
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*,java.util.stream.Collectors" %>
<%
    List<Map<String, Object>> records = (List<Map<String, Object>>) request.getAttribute("records");
    if (records == null)
        records = new ArrayList<>();
%>
<div class="glass rounded-3xl p-8 max-w-5xl mx-auto">
    <h3 class="text-2xl font-semibold mb-6 border-b pb-3">Consultation History</h3>
    <div class="space-y-4">
        <%= !records.isEmpty()
                ? records.stream().map(h
                        -> "<div class=\"p-5 border rounded-2xl bg-white flex flex-col md:flex-row justify-between md:items-center gap-4 shadow-sm hover:shadow-md transition\">"
                + "<div class=\"flex-1\">"
                + "<div class=\"flex items-center gap-3 mb-2\">"
                + "<p class=\"font-bold text-lg text-gray-800\">" + (h.get("departmentName") != null ? h.get("departmentName") : "General") + "</p>"
                + "<span class=\"px-3 py-1 rounded-full text-xs font-bold bg-green-100 text-green-700 border border-green-200\">Completed</span>"
                + "</div>"
                + "<p class=\"text-sm text-gray-600 font-medium\"><i class=\"fa-regular fa-calendar mr-1\"></i> " + (h.get("consultationTime") != null ? h.get("consultationTime") : "")
                + " ｜ <i class=\"fa-solid fa-user-doctor mr-1\"></i> " + (h.get("doctorName") != null ? h.get("doctorName") : "-") + "</p>"
                + "<div class=\"mt-3 p-3 bg-gray-50 rounded-xl border border-gray-100\">"
                + "<p class=\"text-sm text-gray-700\"><b>Diagnosis:</b> " + (h.get("diagnosis") != null ? h.get("diagnosis") : "None recorded") + "</p>"
                + "<p class=\"text-sm text-gray-700 mt-1\"><b>Advice:</b> " + (h.get("medicalAdvice") != null ? h.get("medicalAdvice") : "Rest well") + "</p>"
                + "</div></div></div>"
                ).collect(Collectors.joining(""))
                : "<div class=\"text-center py-12 text-gray-500\"><i class=\"fa-solid fa-notes-medical text-4xl mb-3\"></i><p>No past medical history found.</p></div>"%>
    </div>
</div>