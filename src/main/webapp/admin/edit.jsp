<%-- edit.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.bean.DoctorBean" %>
<%@ page import="com.mycompany.system.bean.PatientBean" %>
<%@ page import="com.mycompany.system.bean.AdminBean" %>
<%@ page import="com.mycompany.system.db.DoctorDB" %>
<%@ page import="com.mycompany.system.db.PatientDB" %>
<%@ page import="com.mycompany.system.db.AdminDB" %>

<%
    String idParam = request.getParameter("id");
    String roleParam = request.getParameter("role");

    DoctorBean doctor = null;
    PatientBean patient = null;
    AdminBean admin = null;

    if (idParam != null && idParam.matches("\\d+")) {
        Long id = Long.parseLong(idParam);
        if ("doctor".equalsIgnoreCase(roleParam)) {
            doctor = DoctorDB.getById(id);
        } else if ("patient".equalsIgnoreCase(roleParam)) {
            patient = PatientDB.getById(id);
        } else if ("admin".equalsIgnoreCase(roleParam)) {
            admin = AdminDB.getById(id);
        }
    }
%>

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - CCHC Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">

<div class="max-w-2xl mx-auto pt-12 px-4">
    <div class="bg-white rounded-3xl shadow-xl p-10">

        <h2 class="text-3xl font-bold mb-8 text-center text-gray-800">
            <i class="fa-solid fa-user-pen mr-3"></i>Edit User
        </h2>

        <% if (doctor != null) { %>
        <form action="${pageContext.request.contextPath}/admin/user/update" method="post" class="space-y-6">
            <input type="hidden" name="id" value="<%= doctor.getId() %>">
            <input type="hidden" name="type" value="doctor">

            <!-- Doctor Fields -->
            <div class="grid grid-cols-2 gap-6">
                <div><label class="block text-sm font-semibold mb-2">Real Name</label>
                    <input type="text" name="realName" value="<%= doctor.getRealName() %>" class="w-full px-4 py-3 border rounded-2xl"></div>
                <div><label class="block text-sm font-semibold mb-2">Gender</label>
                    <select name="gender" class="w-full px-4 py-3 border rounded-2xl">
                        <option value="1" <%= doctor.getGender() == 1 ? "selected" : "" %>>Male</option>
                        <option value="2" <%= doctor.getGender() == 2 ? "selected" : "" %>>Female</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-6">
                <div><label class="block text-sm font-semibold mb-2">Title</label>
                    <input type="text" name="title" value="<%= doctor.getTitle() != null ? doctor.getTitle() : "" %>" class="w-full px-4 py-3 border rounded-2xl"></div>
                <div><label class="block text-sm font-semibold mb-2">Department</label>
                    <select name="departmentId" class="w-full px-4 py-3 border rounded-2xl">
                        <option value="1" <%= doctor.getDepartmentId() == 1 ? "selected" : "" %>>Internal Medicine</option>
                        <option value="2" <%= doctor.getDepartmentId() == 2 ? "selected" : "" %>>Surgery</option>
                        <option value="3" <%= doctor.getDepartmentId() == 3 ? "selected" : "" %>>Pediatrics</option>
                        <option value="4" <%= doctor.getDepartmentId() == 4 ? "selected" : "" %>>Gynecology</option>
                        <option value="5" <%= doctor.getDepartmentId() == 5 ? "selected" : "" %>>Dermatology</option>
                        <option value="6" <%= doctor.getDepartmentId() == 6 ? "selected" : "" %>>ENT</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-6">
                <div><label class="block text-sm font-semibold mb-2">Phone</label>
                    <input type="text" name="phone" value="<%= doctor.getPhone() %>" class="w-full px-4 py-3 border rounded-2xl"></div>
                <div><label class="block text-sm font-semibold mb-2">Email</label>
                    <input type="email" name="email" value="<%= doctor.getEmail() %>" class="w-full px-4 py-3 border rounded-2xl"></div>
            </div>

            <div class="flex justify-end gap-4 pt-6">
                <button type="button" onclick="history.back()" class="px-8 py-3 border border-gray-300 rounded-2xl hover:bg-gray-50">Cancel</button>
                <button type="submit" class="px-8 py-3 bg-indigo-600 text-white rounded-2xl hover:bg-indigo-700">Save Changes</button>
            </div>
        </form>

        <% } else if (patient != null) { %>
        <form action="${pageContext.request.contextPath}/admin/user/update" method="post" class="space-y-6">
            <input type="hidden" name="id" value="<%= patient.getId() %>">
            <input type="hidden" name="type" value="patient">

            <!-- Patient Fields -->
            <div class="grid grid-cols-2 gap-6">
                <div><label class="block text-sm font-semibold mb-2">Real Name</label>
                    <input type="text" name="realName" value="<%= patient.getRealName() %>" class="w-full px-4 py-3 border rounded-2xl"></div>
                <div><label class="block text-sm font-semibold mb-2">Gender</label>
                    <select name="gender" class="w-full px-4 py-3 border rounded-2xl">
                        <option value="1" <%= patient.getGender() == 1 ? "selected" : "" %>>Male</option>
                        <option value="2" <%= patient.getGender() == 2 ? "selected" : "" %>>Female</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-6">
                <div><label class="block text-sm font-semibold mb-2">Phone</label>
                    <input type="text" name="phone" value="<%= patient.getPhone() %>" class="w-full px-4 py-3 border rounded-2xl"></div>
                <div><label class="block text-sm font-semibold mb-2">Email</label>
                    <input type="email" name="email" value="<%= patient.getEmail() %>" class="w-full px-4 py-3 border rounded-2xl"></div>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2">Address</label>
                <input type="text" name="address" value="<%= patient.getAddress() != null ? patient.getAddress() : "" %>" class="w-full px-4 py-3 border rounded-2xl">
            </div>

            <div class="flex justify-end gap-4 pt-6">
                <button type="button" onclick="history.back()" class="px-8 py-3 border border-gray-300 rounded-2xl hover:bg-gray-50">Cancel</button>
                <button type="submit" class="px-8 py-3 bg-indigo-600 text-white rounded-2xl hover:bg-indigo-700">Save Changes</button>
            </div>
        </form>

        <% } else if (admin != null) { %>
        <form action="${pageContext.request.contextPath}/admin/user/update" method="post" class="space-y-6">
            <input type="hidden" name="id" value="<%= admin.getId() %>">
            <input type="hidden" name="type" value="admin">

            <div>
                <label class="block text-sm font-semibold mb-2">Real Name</label>
                <input type="text" name="realName" value="<%= admin.getRealName() %>" class="w-full px-4 py-3 border rounded-2xl">
            </div>
            <div>
                <label class="block text-sm font-semibold mb-2">Username</label>
                <input type="text" name="username" value="<%= admin.getUsername() %>" class="w-full px-4 py-3 border rounded-2xl">
            </div>
            <div>
                <label class="block text-sm font-semibold mb-2">Phone</label>
                <input type="text" name="phone" value="<%= admin.getPhone() != null ? admin.getPhone() : "" %>" class="w-full px-4 py-3 border rounded-2xl">
            </div>
            <div>
                <label class="block text-sm font-semibold mb-2">Email</label>
                <input type="email" name="email" value="<%= admin.getEmail() != null ? admin.getEmail() : "" %>" class="w-full px-4 py-3 border rounded-2xl">
            </div>

            <div class="flex justify-end gap-4 pt-6">
                <button type="button" onclick="history.back()" class="px-8 py-3 border border-gray-300 rounded-2xl hover:bg-gray-50">Cancel</button>
                <button type="submit" class="px-8 py-3 bg-indigo-600 text-white rounded-2xl hover:bg-indigo-700">Save Changes</button>
            </div>
        </form>

        <% } else { %>
            <p class="text-center text-red-500 text-xl py-12">User not found.</p>
        <% } %>
    </div>
</div>
</body>
</html>