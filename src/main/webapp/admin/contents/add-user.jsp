<%-- 
    Document   : add-user
    Created on : 2026年4月25日
    Author     : USER
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Add User</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #c5e0fa;
                margin: 0;
                padding: 0;
            }
            .hidden {
                display: none;
            }
            .modal-overlay {
                position: fixed;
                inset: 0;
                background: rgba(0,0,0,0.5);
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .modal-box {
                background: #fff;
                border-radius: 12px;
                padding: 2rem;
                width: 500px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            }
            h3 {
                font-size: 1.25rem;
                font-weight: bold;
                margin-bottom: 1rem;
            }
            label {
                display: block;
                font-size: 0.9rem;
                font-weight: 500;
                margin-bottom: 0.25rem;
            }
            input, select {
                width: 100%;
                border: 1px solid #d1d5db;
                border-radius: 6px;
                padding: 0.5rem;
                font-size: 0.9rem;
            }
            .mb-3 {
                margin-bottom: 1rem;
            }
            .mb-4 {
                margin-bottom: 1.25rem;
            }
            .btn {
                padding: 0.5rem 1rem;
                border-radius: 6px;
                font-size: 0.9rem;
                cursor: pointer;
                border: none;
            }
            .btn-back {
                background: #e5e7eb;
                color: #111827;
            }
            .btn-save {
                background: #4f46e5;
                color: #fff;
            }
            .btn-back:hover {
                background: #d1d5db;
            }
            .btn-save:hover {
                background: #4338ca;
            }
            .flex {
                display: flex;
            }
            .gap-3 {
                gap: 0.75rem;
            }
            .mt-4 {
                margin-top: 1rem;
            }
            .justify-end {
                justify-content: flex-end;
            }
        </style>
    </head>
    <body>
        <div id="addUserModal" class="modal-overlay">
            <div class="modal-box">
                <h3>Add User</h3>

                <% if (request.getAttribute("error") != null) {%>
                <div style="background-color:#fee2e2; color:#b91c1c; padding:10px; border-radius:6px; margin-bottom:15px;">
                    <%= request.getAttribute("error")%>
                </div>
                <% }%>


                <form action="<%= request.getContextPath()%>/AdminCreateUserServlet" method="post">

                    <!-- Role Selection -->
                    <div class="mb-4">
                        <label>Role</label>
                        <select name="type" id="userRole" onchange="toggleRoleFields()" required>
                            <option value="" disabled selected>Select role</option>
                            <option value="patient">Patient</option>
                            <option value="doctor">Doctor</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>

                    <!-- Common Fields -->
                    <div class="mb-3">
                        <label>Username</label>
                        <input type="text" name="username" required/>
                    </div>
                    <div class="mb-3">
                        <label>Password</label>
                        <input type="password" name="password" required/>
                    </div>
                    <div class="mb-3">
                        <label>Full Name</label>
                        <input type="text" name="realName" required/>
                    </div>
                    <div class="mb-3">
                        <label>Phone</label>
                        <input type="text" name="phone" required/>
                    </div>
                    <div class="mb-3">
                        <label>Email</label>
                        <input type="email" name="email" required/>
                    </div>

                    <!-- Doctor Fields -->
                    <div id="doctorFields" class="hidden">
                        <div class="mb-3">
                            <label>Title</label>
                            <input type="text" name="title"/>
                        </div>
                        <div class="mb-3">
                            <label>Department</label>
                            <select name="departmentId">
                                <option value="1">Internal Medicine</option>
                                <option value="2">Surgery</option>
                                <option value="3">Pediatrics</option>
                                <option value="4">Gynecology</option>
                                <option value="5">Dermatology</option>
                                <option value="6">ENT</option>
                            </select>
                        </div>
                    </div>

                    <!-- Patient Fields -->
                    <div id="patientFields" class="hidden">
                        <div class="mb-3">
                            <label>Address</label>
                            <input type="text" name="address"/>
                        </div>
                    </div>

                    <!-- Buttons -->
                    <div class="flex justify-end gap-3 mt-4">
                        <button type="button" 
                                onclick="window.location.href = '<%= request.getContextPath()%>/admin/dashboard'" 
                                class="btn btn-back">
                            Back
                        </button>
                        <button type="submit" class="btn btn-save">Save</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
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
        </script>
    </body>
</html>
