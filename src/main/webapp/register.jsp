<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Patient Registration</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        .hero-bg { background: linear-gradient(135deg, #f8fafc 0%, #e0f2fe 100%); }
        .glass {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }
    </style>
</head>
<body class="hero-bg min-h-screen flex items-center justify-center">

    <div class="glass rounded-3xl p-8 w-full max-w-2xl shadow-lg">
        <div class="flex items-center justify-between mb-6 border-b pb-4">
            <h3 class="text-2xl font-semibold text-gray-800">
                <i class="fa-solid fa-user-plus mr-2 text-indigo-600"></i> Patient Registration
            </h3>
        </div>

        <form action="RegisterServlet" method="post" class="space-y-6" onsubmit="return showSuccess()">
            <div>
                <label class="block text-sm font-medium text-gray-700">Username</label>
                <input type="text" name="username" required
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Password</label>
                <input type="password" name="password" required
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Real Name</label>
                <input type="text" name="real_name" required
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Gender</label>
                <select name="gender"
                        class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
                    <option value="1">Male</option>
                    <option value="2">Female</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Phone</label>
                <input type="text" name="phone"
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input type="email" name="email"
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">ID Card</label>
                <input type="text" name="id_card"
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Birthday</label>
                <input type="date" name="birthday"
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700">Address</label>
                <input type="text" name="address"
                       class="w-full px-4 py-2 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm">
            </div>

            <div class="flex justify-between items-center">
                <a href="${pageContext.request.contextPath}/login.jsp"
                   class="px-6 py-2 bg-red-50 text-red-600 transition hover:text-gray-800 font-medium rounded-xl hover:bg-gray-400 transition">
                    ← Back
                </a>
                <input type="submit" value="Register"
                       class="px-6 py-2 bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition">
            </div>
        </form>
    </div>

    <script>
        function showSuccess() {
            Swal.fire({
                icon: 'success',
                title: 'Registration Submitted',
                text: 'Your patient registration form has been sent!',
                confirmButtonColor: '#6366f1'
            });
            return true; // allow form submission
        }
    </script>

</body>
</html>
