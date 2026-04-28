<%-- users-contents.jsp --%>
<%@page import="com.mycompany.system.db.AdminDB"%>
<%@page import="com.mycompany.system.db.PatientDB"%>
<%@page import="com.mycompany.system.db.DoctorDB"%>
<%@page import="java.util.List"%>
<%@ page isELIgnored="false" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@taglib uri="/WEB-INF/tlds/doctor.tld" prefix="doc" %>
<%@taglib uri="/WEB-INF/tlds/patient.tld" prefix="pat" %>
<%@taglib uri="/WEB-INF/tlds/admin.tld" prefix="adm" %>

<%@page import="com.mycompany.system.bean.AdminBean" %>
<%@page import="com.mycompany.system.bean.DoctorBean" %>
<%@page import="com.mycompany.system.bean.PatientBean" %>

<%
    String adminSearch = request.getParameter("adminSearchInput");
    String docSearch   = request.getParameter("docSearchInput");
    String patSearch   = request.getParameter("patSearchInput");

    // === ADMIN SEARCH ===
    List<AdminBean> adminList;
    if (adminSearch != null && !adminSearch.trim().isEmpty()) {
        adminList = AdminDB.search(adminSearch.trim());
    } else {
        adminList = AdminDB.getAll();
    }
    request.setAttribute("adminUsers", adminList);

    // === DOCTOR SEARCH ===
    List<DoctorBean> doctorList;
    if (docSearch != null && !docSearch.trim().isEmpty()) {
        doctorList = DoctorDB.search(docSearch.trim());
    } else {
        doctorList = DoctorDB.getAll();
    }
    request.setAttribute("doctorUsers", doctorList);

    // === PATIENT SEARCH ===
    List<PatientBean> patientList;
    if (patSearch != null && !patSearch.trim().isEmpty()) {
        patientList = PatientDB.search(patSearch.trim());
    } else {
        patientList = PatientDB.getAll();
    }
    request.setAttribute("patientUsers", patientList);
%>

<div class="space-y-8">

    <!-- ADMIN -->
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">Admin Management</h3>
            <a href="${pageContext.request.contextPath}/admin/contents/add-user.jsp?role=admin"
               class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700">
                Add Admin
            </a>
        </div>
        <form method="get">
            <div class="mb-6 flex gap-3">
                <input type="text" name="adminSearchInput" 
                       placeholder="Search admin by name / username / phone / email..."
                       value="<%= adminSearch != null ? adminSearch : "" %>"
                       class="flex-1 px-4 py-3 border rounded-xl outline-none">
                <button type="submit" class="px-6 py-3 bg-gray-700 text-white rounded-xl">Search</button>
            </div>
        </form>
        <div class="overflow-x-auto">
            <adm:adminTable admins="${adminUsers}" />
        </div>
    </div>

    <!-- DOCTOR -->
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">Doctor Management</h3>
            <a href="${pageContext.request.contextPath}/admin/contents/add-user.jsp?role=doctor"
               class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700">
                Add Doctor
            </a>
        </div>
        <form method="get">
            <div class="mb-6 flex gap-3">
                <input type="text" name="docSearchInput" 
                       placeholder="Search doctor by name / phone / email / title..."
                       value="<%= docSearch != null ? docSearch : "" %>"
                       class="flex-1 px-4 py-3 border rounded-xl outline-none">
                <button type="submit" class="px-6 py-3 bg-gray-700 text-white rounded-xl">Search</button>
            </div>
        </form>
        <div class="overflow-x-auto">
            <doc:doctorTable doctors="${doctorUsers}" />
        </div>
    </div>

    <!-- PATIENT -->
    <div class="glass rounded-3xl p-8">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">Patient Management</h3>
            <a href="${pageContext.request.contextPath}/admin/contents/add-user.jsp?role=patient"
               class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700">
                Add Patient
            </a>
        </div>
        <form method="get">
            <div class="mb-6 flex gap-3">
                <input type="text" name="patSearchInput" 
                       placeholder="Search patient by name / phone / email..."
                       value="<%= patSearch != null ? patSearch : "" %>"
                       class="flex-1 px-4 py-3 border rounded-xl outline-none">
                <button type="submit" class="px-6 py-3 bg-gray-700 text-white rounded-xl">Search</button>
            </div>
        </form>
        <div class="overflow-x-auto">
            <pat:patientTable patients="${patientUsers}" />
        </div>
    </div>
</div>