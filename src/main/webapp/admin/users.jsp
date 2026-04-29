<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.model.LoginUser" %>
<%@ page import="com.mycompany.system.db.AdminDB" %>
<%@ page import="com.mycompany.system.db.DoctorDB" %>
<%@ page import="com.mycompany.system.db.PatientDB" %>
<%@ page import="com.mycompany.system.bean.AdminBean" %>
<%@ page import="com.mycompany.system.bean.DoctorBean" %>
<%@ page import="com.mycompany.system.bean.PatientBean" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="/WEB-INF/tlds/doctor.tld" prefix="doc" %>
<%@ taglib uri="/WEB-INF/tlds/patient.tld" prefix="pat" %>
<%@ taglib uri="/WEB-INF/tlds/admin.tld" prefix="adm" %>
<%@ page isELIgnored="false" %>
<%@taglib uri="/WEB-INF/tlds/current-date" prefix="today" %>

<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String adminSearch = request.getParameter("adminSearchInput");
    String docSearch = request.getParameter("docSearchInput");
    String patSearch = request.getParameter("patSearchInput");

    List<AdminBean> adminList;
    if (adminSearch != null && !adminSearch.trim().isEmpty()) {
        adminList = AdminDB.search(adminSearch.trim());
    } else {
        adminList = AdminDB.getAll();
    }
    request.setAttribute("adminUsers", adminList);

    List<DoctorBean> doctorListAll = DoctorDB.getAll();
    List<DoctorBean> doctorList = new ArrayList<>();
    if (docSearch != null && !docSearch.trim().isEmpty()) {
        String keyword = docSearch.trim().toLowerCase();
        for (DoctorBean d : doctorListAll) {
            if ((d.getRealName() != null && d.getRealName().toLowerCase().contains(keyword))
                    || (d.getPhone() != null && d.getPhone().toLowerCase().contains(keyword))
                    || (d.getEmail() != null && d.getEmail().toLowerCase().contains(keyword))
                    || (d.getTitle() != null && d.getTitle().toLowerCase().contains(keyword))) {
                doctorList.add(d);
            }
        }
    } else {
        doctorList = doctorListAll;
    }
    request.setAttribute("doctorUsers", doctorList);

    List<PatientBean> patientListAll = PatientDB.getAll();
    List<PatientBean> patientList = new ArrayList<>();
    if (patSearch != null && !patSearch.trim().isEmpty()) {
        String keyword = patSearch.trim().toLowerCase();
        for (PatientBean p : patientListAll) {
            if ((p.getRealName() != null && p.getRealName().toLowerCase().contains(keyword))
                    || (p.getPhone() != null && p.getPhone().toLowerCase().contains(keyword))
                    || (p.getEmail() != null && p.getEmail().toLowerCase().contains(keyword))) {
                patientList.add(p);
            }
        }
    } else {
        patientList = patientListAll;
    }
    request.setAttribute("patientUsers", patientList);
%>
<!DOCTYPE html>
<html lang="zh">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>User Management - CCHC Admin</title>
        <script src="https://cdn.tailwindcss.com"></script><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
            *{
                box-sizing:border-box
            }
            body{
                font-family:'Noto Sans TC',sans-serif;
                background:linear-gradient(135deg,#f0f9ff 0%,#e0e7ff 100%)
            }
            .glass{
                background:rgba(255,255,255,0.95);
                border:1px solid rgba(255,255,255,0.6);
                box-shadow:0 4px 6px -1px rgba(0,0,0,0.05);
                backdrop-filter:blur(4px)
            }
            .nav-item{
                transition:all .2s;
                display:flex;
                align-items:center;
                gap:0.75rem;
                padding:0.75rem 1.25rem;
                border-radius:1rem
            }
            .nav-item:hover{
                transform:translateX(8px);
                background:rgba(99,102,241,0.1)
            }
            .nav-item.active{
                background:rgba(99,102,241,0.14);
                color:#4f46e5;
                font-weight:700
            }
            .badge{
                display:inline-flex;
                align-items:center;
                gap:0.35rem;
                padding:0.35rem 0.7rem;
                border-radius:999px;
                font-size:0.75rem;
                font-weight:700
            }
            .badge-success{
                background:#dcfce7;
                color:#166534
            }
            .badge-danger{
                background:#fee2e2;
                color:#b91c1c
            }
            .badge-info{
                background:#dbeafe;
                color:#1d4ed8
            }
        </style>
    </head>
    <body class="min-h-screen">
        <div class="flex h-screen overflow-hidden">
            <aside class="w-80 glass shadow-2xl flex flex-col border-r border-white/50 fixed md:relative h-full z-40">
                <div class="p-6 bg-gradient-to-r from-indigo-700 to-violet-700 text-white"><div class="flex items-center gap-3"><i class="fa-solid fa-user-shield text-4xl"></i><div><h1 class="text-2xl font-bold">CCHC</h1><p class="text-sm opacity-90">Admin Console</p></div></div></div>
                <div class="p-6 flex-1 flex flex-col overflow-y-auto">
                    <div class="flex items-center gap-4 p-4 glass rounded-3xl mb-8"><img src="https://picsum.photos/200/200?random=99" class="w-14 h-14 rounded-2xl ring-4 ring-white object-cover"><div><p class="font-semibold"><%= loginUser.getRealName()%></p><p class="text-indigo-600 text-sm">Full Access</p></div></div>
                    <nav class="space-y-1">
                        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-item "><i class="fa-solid fa-chart-pie w-5"></i><span>Dashboard</span></a>
                        <a href="${pageContext.request.contextPath}/admin/users.jsp" class="nav-item active"><i class="fa-solid fa-users w-5 "></i><span>User Management</span></a>
                        <a href="${pageContext.request.contextPath}/admin/clinic_config.jsp" class="nav-item"><i class="fa-solid fa-building"></i><span>Clinic & Services</span></a>
                        <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="nav-item"><i class="fa-solid fa-chart-bar w-5"></i><span>Reports</span></a>
                        <a href="${pageContext.request.contextPath}/admin/abnormal_records.jsp" class="nav-item"><i class="fa-solid fa-exclamation-triangle"></i><span>Abnormal Records</span></a>
                        <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="nav-item"><i class="fa-solid fa-bell w-5"></i><span>Notifications</span></a>
                        <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="nav-item"><i class="fa-solid fa-sliders w-5"></i><span>Settings</span></a>
                        <a href="${pageContext.request.contextPath}/admin/profile.jsp" class="nav-item"><i class="fa-solid fa-user-gear w-5"></i><span>Profile</span></a>
                    </nav>
                    <div class="mt-auto pt-6 border-t border-white/40"><a href="${pageContext.request.contextPath}/logout" class="w-full flex items-center justify-center gap-3 px-5 py-3 rounded-2xl text-gray-600 hover:bg-red-50 hover:text-red-600 transition"><i class="fa-solid fa-right-from-bracket"></i><span>Logout</span></a></div>
                </div>
            </aside>

            <div class="flex-1 flex flex-col min-w-0">
                <header class="glass border-b px-8 py-4 flex justify-between items-center"><h2 class="text-2xl font-semibold">User Management</h2><div class="flex items-center gap-3"><today:today/></div></header>
                <div class="flex-1 overflow-auto p-4 md:p-8">
                    <!-- Success / Error Message -->
                    <% if (request.getAttribute("success") != null) {%>
                    <div class="bg-green-100 border border-green-400 text-green-700 px-6 py-4 rounded-2xl mb-6 flex items-center gap-3">
                        <i class="fa-solid fa-check-circle"></i>
                        <%= request.getAttribute("success")%>
                    </div>
                    <% }%>
                    <div class="space-y-8">
                        <!-- ADMIN -->
                        <div class="glass rounded-3xl p-8"><div class="flex items-center justify-between mb-6 border-b pb-4"><h3 class="text-2xl font-semibold text-gray-800">Admin Management</h3><a href="${pageContext.request.contextPath}/admin/add-user.jsp?role=admin" class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700">Add Admin</a></div>
                            <form method="get"><div class="mb-6 flex gap-3"><input type="text" name="adminSearchInput" placeholder="Search admin by name / username / phone / email..." value="<%= adminSearch != null ? adminSearch : ""%>" class="flex-1 px-4 py-3 border rounded-xl outline-none"><button type="submit" class="px-6 py-3 bg-gray-700 text-white rounded-xl">Search</button></div></form>
                            <div class="overflow-x-auto"><adm:adminTable admins="${adminUsers}" /></div></div>
                        <!-- DOCTOR -->
                        <div class="glass rounded-3xl p-8"><div class="flex items-center justify-between mb-6 border-b pb-4"><h3 class="text-2xl font-semibold text-gray-800">Doctor Management</h3><a href="${pageContext.request.contextPath}/admin/add-user.jsp?role=doctor" class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700">Add Doctor</a></div>
                            <form method="get"><div class="mb-6 flex gap-3"><input type="text" name="docSearchInput" placeholder="Search doctor by name / phone / email / title..." value="<%= docSearch != null ? docSearch : ""%>" class="flex-1 px-4 py-3 border rounded-xl outline-none"><button type="submit" class="px-6 py-3 bg-gray-700 text-white rounded-xl">Search</button></div></form>
                            <div class="overflow-x-auto"><doc:doctorTable doctors="${doctorUsers}" /></div></div>
                        <!-- PATIENT -->
                        <div class="glass rounded-3xl p-8"><div class="flex items-center justify-between mb-6 border-b pb-4"><h3 class="text-2xl font-semibold text-gray-800">Patient Management</h3><a href="${pageContext.request.contextPath}/admin/add-user.jsp?role=patient" class="px-4 py-2 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700">Add Patient</a></div>
                            <form method="get"><div class="mb-6 flex gap-3"><input type="text" name="patSearchInput" placeholder="Search patient by name / phone / email..." value="<%= patSearch != null ? patSearch : ""%>" class="flex-1 px-4 py-3 border rounded-xl outline-none"><button type="submit" class="px-6 py-3 bg-gray-700 text-white rounded-xl">Search</button></div></form>
                            <div class="overflow-x-auto"><pat:patientTable patients="${patientUsers}" /></div></div>
                    </div>
                </div>
            </div>
        </div>
        <script>document.getElementById('current-date').innerText = new Date().toLocaleDateString('zh-CN', {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'});</script>
    </body>
</html>