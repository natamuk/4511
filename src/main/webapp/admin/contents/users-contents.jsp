<%-- 
    Document   : users-contents
    Created on : 2026年4月23日, 23:46:48
    Author     : 123
--%>

<%@ page isELIgnored="false" %>
<%@page import="com.mycompany.system.db.PatientDB"%>
<%@page import="com.mycompany.system.db.DoctorDB"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib uri="/WEB-INF/tlds/doctor.tld" prefix="doc" %>
<%@taglib uri="/WEB-INF/tlds/patient.tld" prefix="pat" %>
<%@page import="java.util.ArrayList" %>
<%@page import="com.mycompany.system.bean.DoctorBean" %>
<%@page import="com.mycompany.system.bean.PatientBean" %>


<%

    List<DoctorBean> doctorList = DoctorDB.getAll();
    request.setAttribute("doctorUsers", doctorList);

    List<PatientBean> patientList = PatientDB.getAll();
    request.setAttribute("patientUsers", patientList);

%>

<div class="space-y-8">

    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">Doctor Management</h3>
            <div class="flex items-center gap-3">
                <a href="${pageContext.request.contextPath}/admin/contents/add-user.jsp"
                   class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition">
                    Add User
                </a>
                <span id="doc-count" class="text-sm font-medium px-3 py-2 bg-indigo-50 text-indigo-700 rounded-xl">Total:</span>
            </div>
        </div>
        <form method="get">
            <div class="mb-6">

                <input type="text" name="docSearchInput" placeholder="Search by name / phone / email..."
                       class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none">
                <button type="submit">Search</button>

                <!--            <input type="text" id="docSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterDoctors()">-->
            </div>
            <div class="overflow-x-auto">
                <base href="${pageContext.request.contextPath}/" />
                <doc:doctorTable doctors="${doctorUsers}" />
            </div>
        </form>
    </div>
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">Patient Management</h3>
            <span id="pat-count" class="text-sm font-medium px-3 py-1 bg-emerald-50 text-emerald-700 rounded-lg">Total: </span>
        </div>
        <form method="get">
            <div class="mb-6">
                <input type="text" name="patSearchInput" placeholder="Search by name / phone / email..."
                       class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none">
                <button type="submit">Search</button>

                <!--            <input type="text" id="patSearchInput" placeholder="Search by name / phone / email..." class="w-full md:w-1/2 px-4 py-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" oninput="filterPatients()">-->
            </div>
        </form>
        <div class="overflow-x-auto">
            <pat:patientTable patients="${patientUsers}" />
        </div>
    </div>
</div>
