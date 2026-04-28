<%-- add-user.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Add New User</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .add-container {
            background: white;
            padding: 40px 50px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 520px;
        }
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
            font-size: 28px;
        }
        label {
            display: block;
            margin: 15px 0 5px;
            font-weight: 600;
            color: #444;
        }
        input[type="text"], input[type="email"], input[type="password"], select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            box-sizing: border-box;
        }
        input:focus, select:focus {
            outline: none;
            border-color: #4f46e5;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        .hidden { display: none; }
        .button-group {
            margin-top: 30px;
            display: flex;
            gap: 12px;
            justify-content: center;
        }
        button {
            padding: 12px 28px;
            font-size: 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-back { background: #6c757d; color: white; }
        .btn-save { background: #4f46e5; color: white; }
        .btn-back:hover { background: #5a6268; }
        .btn-save:hover { background: #4338ca; transform: translateY(-2px); }
        .error {
            background-color: #fee2e2;
            color: #b91c1c;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="add-container">
        <h2>Add New User</h2>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/AdminCreateUserServlet" method="post">

            <!-- Role Selection -->
            <label>Role <span style="color:red">*</span></label>
            <select name="type" id="userRole" onchange="toggleRoleFields()" required>
                <option value="" disabled selected>Select Role</option>
                <option value="admin">Admin</option>
                <option value="doctor">Doctor</option>
                <option value="patient">Patient</option>
            </select>

            <!-- Common Fields -->
            <label>Username <span style="color:red">*</span></label>
            <input type="text" name="username" required />

            <label>Password <span style="color:red">*</span></label>
            <input type="password" name="password" required />

            <label>Full Name <span style="color:red">*</span></label>
            <input type="text" name="realName" required />

            <label>Phone <span style="color:red">*</span></label>
            <input type="text" name="phone" required />

            <label>Email <span style="color:red">*</span></label>
            <input type="email" name="email" required />

            <!-- Doctor Fields -->
            <div id="doctorFields" class="hidden">
                <label>Gender</label>
                <select name="gender">
                    <option value="1">Male</option>
                    <option value="2">Female</option>
                </select>

                <label>Title</label>
                <input type="text" name="title" placeholder="e.g. Chief Physician" />

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

            <!-- Patient Fields -->
            <div id="patientFields" class="hidden">
                <label>Gender</label>
                <select name="gender">
                    <option value="1">Male</option>
                    <option value="2">Female</option>
                </select>

                <label>Address</label>
                <input type="text" name="address" />
            </div>

            <!-- Buttons -->
            <div class="button-group">
                <button type="button" onclick="window.location.href='${pageContext.request.contextPath}/admin/dashboard'" 
                        class="btn-back">Back</button>
                <button type="submit" class="btn-save">Create User</button>
            </div>
        </form>
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

        window.onload = function() {
            document.querySelector("input[name='username']").focus();
        };
    </script>
</body>
</html>