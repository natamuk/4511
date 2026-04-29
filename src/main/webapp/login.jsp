<%-- 
    Document   : login
    Created on : 2026年3月31日, 21:50:35
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CCHC - Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap');
        body { font-family: 'Noto Sans TC', system-ui, sans-serif; background: linear-gradient(135deg, #f8fafc 0%, #e0f2fe 100%); }
        .hero-bg { background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%); }
        .fade-in { animation: fadeIn 0.8s ease forwards; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

        .input-icon {
            position: absolute;
            left: 1.25rem;
            top: 1rem;
            color: #9ca3af;
        }

        .login-input {
            width: 100%;
            padding-left: 3rem;
            padding-right: 1.25rem;
            padding-top: 1rem;
            padding-bottom: 1rem;
            border: 1px solid #d1d5db;
            border-radius: 1.5rem;
            outline: none;
            transition: all 0.2s ease;
            background: white;
        }

        .login-input:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 4px rgba(59,130,246,0.08);
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-6">

<div class="max-w-5xl w-full grid md:grid-cols-5 bg-white rounded-3xl shadow-2xl overflow-hidden">

    <!-- Left Brand Panel -->
    <div class="hero-bg md:col-span-3 p-12 lg:p-16 text-white flex flex-col justify-between hidden md:flex fade-in">
        <div>
            <div class="flex items-center gap-4 mb-12">
                <div class="w-16 h-16 bg-white/20 backdrop-blur-xl rounded-2xl flex items-center justify-center">
                    <i class="fa-solid fa-clinic-medical text-4xl"></i>
                </div>
                <div>
                    <h1 class="text-5xl font-bold tracking-tighter">CCHC</h1>
                    <p class="text-blue-100 text-xl">Community Care Health Consortium</p>
                </div>
            </div>

            <h2 class="text-4xl font-semibold leading-tight mb-6">
                Making healthcare<br>closer, faster, and safer
            </h2>
            <p class="text-blue-100 text-lg max-w-md">
                Serving 5 community clinics in Hong Kong<br>
                Chai Wan · Tseung Kwan O · Sha Tin · Tuen Mun · Tsing Yi
            </p>
        </div>

        <div class="text-sm opacity-75">
            <p>Professional · Reliable · Patient-centered</p>
            <p class="mt-6 text-xs">© 2026 Community Care Health Consortium</p>
        </div>
    </div>

    <!-- Right Login Panel -->
    <div class="md:col-span-2 p-10 lg:p-14 flex flex-col justify-center fade-in">
        <h2 class="text-3xl font-bold text-gray-800 mb-2">Welcome Back</h2>
        <p class="text-gray-600 mb-10">Please enter your account and password to sign in</p>

        <form action="${pageContext.request.contextPath}/login" method="post" class="space-y-6">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Account / ID Number</label>
                <div class="relative">
                    <i class="fa-solid fa-user input-icon"></i>
                    <input type="text" name="username" id="username" value="" class="login-input" required>
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Password</label>
                <div class="relative">
                    <i class="fa-solid fa-lock input-icon"></i>
                    <input type="password" name="password" id="password" value="" class="login-input" required>
                </div>
            </div>

            <button type="submit"
                    class="w-full py-5 bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold rounded-3xl text-lg hover:brightness-110 transition-all">
                Sign In
            </button>
        </form>

        <div class="mt-8 text-center space-y-3">
            <a href="${pageContext.request.contextPath}/register.jsp" class="block text-blue-600 hover:underline">Don't have an account? Register now</a>
        
        </div>

        <%
            String errorMsg = (String) request.getAttribute("errorMsg");
            if (errorMsg != null && !errorMsg.isEmpty()) {
        %>
            <div class="mt-6 p-4 rounded-2xl bg-red-50 text-red-700 border border-red-200 text-sm">
                <%= errorMsg %>
            </div>
        <%
            }
        %>
    </div>
</div>

</body>
</html>