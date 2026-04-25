<%-- 
    Document   : Adduse
    Created on : 2026年4月25日, 下午8:16:27
    Author     : USER
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
<div id="addUserModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
    <div class="bg-white rounded-xl p-8 w-[500px] shadow-lg">
        <h3 class="text-xl font-bold mb-4">Add User</h3>
        <form action="/admin/user/create" method="post">

            <!-- Role Selection -->
            <div class="mb-4">
                <label class="block text-sm font-medium">Role</label>
                <select name="type" id="userRole" class="w-full border rounded p-2" onchange="toggleRoleFields()">
                    <option value="patient">Patient</option>
                    <option value="doctor">Doctor</option>
                    <option value="admin">Admin</option>
                </select>
            </div>

            <div class="mb-3">
                <label class="block text-sm font-medium">Username</label>
                <input type="text" name="username" class="w-full border rounded p-2"/>
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium">Password</label>
                <input type="password" name="password" class="w-full border rounded p-2"/>
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium">Full Name</label>
                <input type="text" name="realName" class="w-full border rounded p-2"/>
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium">Phone</label>
                <input type="text" name="phone" class="w-full border rounded p-2"/>
            </div>
            <div class="mb-3">
                <label class="block text-sm font-medium">Email</label>
                <input type="email" name="email" class="w-full border rounded p-2"/>
            </div>

            <div id="doctorFields" class="hidden">
                <div class="mb-3">
                    <label class="block text-sm font-medium">Title</label>
                    <input type="text" name="title" class="w-full border rounded p-2"/>
                </div>
                <div class="mb-3">
                    <label class="block text-sm font-medium">Department ID</label>
                    <input type="text" name="departmentId" class="w-full border rounded p-2"/>
                </div>
            </div>

            <div id="patientFields" class="hidden">
                <div class="mb-3">
                    <label class="block text-sm font-medium">Address</label>
                    <input type="text" name="address" class="w-full border rounded p-2"/>
                </div>
            </div>


            <div class="flex justify-end gap-3 mt-4">
                <button type="button" onclick="document.getElementById('addUserModal').classList.add('hidden')" 
                        class="px-4 py-2 bg-gray-300 rounded">Cancel</button>
                <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded">Save</button>
            </div>
        </form>
    </div>
</div>

<script>
    function addUser() {
        document.getElementById('addUserModal').classList.remove('hidden');
    }
    function toggleRoleFields() {
        const role = document.getElementById("userRole").value;
        document.getElementById("doctorFields").classList.add("hidden");
        document.getElementById("patientFields").classList.add("hidden");

        if (role === "doctor") {
            document.getElementById("doctorFields").classList.remove("hidden");
        } else if (role === "patient") {
            document.getElementById("patientFields").classList.remove("hidden");
        }
    }
    </body>
</html>
