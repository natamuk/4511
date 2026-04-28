<%-- profile-contents.jsp --%>
<%@page import="com.mycompany.system.db.AdminDB"%>
<%@page import="com.mycompany.system.bean.AdminBean"%>
<%@page import="com.mycompany.system.model.LoginUser"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    LoginUser loginUser = (LoginUser) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(loginUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    AdminBean admin = AdminDB.getById(loginUser.getId());
    request.setAttribute("adminProfile", admin);
%>

<div class="max-w-3xl mx-auto glass rounded-3xl p-8">

    <h3 class="text-2xl font-bold mb-8 text-gray-800 border-b pb-4">
        <i class="fa-solid fa-user-shield mr-3"></i>Account Profile
    </h3>

    <!-- Profile Information -->
    <form action="${pageContext.request.contextPath}/admin/update-profile" method="post" class="space-y-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="md:col-span-2 flex items-center gap-6">
                <img src="https://picsum.photos/200/200?random=99" 
                     class="w-28 h-28 rounded-2xl object-cover ring-4 ring-indigo-100" alt="avatar">
                <div>
                    <h4 class="text-2xl font-bold">${adminProfile.realName}</h4>
                    <p class="text-indigo-600">System Administrator</p>
                </div>
            </div>

            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">Full Name</label>
                <input type="text" name="realName" value="${adminProfile.realName}" 
                       class="w-full p-4 border border-gray-300 rounded-2xl focus:ring-2 focus:ring-indigo-500 outline-none">
            </div>
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">Username</label>
                <input type="text" value="${adminProfile.username}" readonly 
                       class="w-full p-4 border border-gray-200 bg-gray-100 rounded-2xl text-gray-500">
            </div>

            <div class="md:col-span-2">
                <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
                <input type="email" name="email" value="${adminProfile.email}" 
                       class="w-full p-4 border border-gray-300 rounded-2xl focus:ring-2 focus:ring-indigo-500 outline-none">
            </div>

            <div class="md:col-span-2">
                <label class="block text-sm font-semibold text-gray-700 mb-2">Phone Number</label>
                <input type="text" name="phone" value="${adminProfile.phone}" 
                       class="w-full p-4 border border-gray-300 rounded-2xl focus:ring-2 focus:ring-indigo-500 outline-none">
            </div>
        </div>

        <div class="flex justify-end">
            <button type="submit" 
                    class="px-10 py-4 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-2xl transition">
                Save Profile Changes
            </button>
        </div>
    </form>

    <!-- Change Password -->
    <div class="mt-12 pt-10 border-t">
        <h3 class="text-2xl font-bold mb-6 text-gray-800">
            <i class="fa-solid fa-lock mr-3"></i>Change Password
        </h3>
        
        <form action="${pageContext.request.contextPath}/admin/update-profile" method="post">
            <input type="hidden" name="action" value="changePassword">

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="md:col-span-2">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Current Password</label>
                    <input type="password" name="oldPwd" required 
                           class="w-full p-4 border border-gray-300 rounded-2xl focus:ring-2 focus:ring-indigo-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">New Password</label>
                    <input type="password" name="newPwd" id="newPwd" required 
                           class="w-full p-4 border border-gray-300 rounded-2xl focus:ring-2 focus:ring-indigo-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Confirm New Password</label>
                    <input type="password" name="confirmPwd" id="confirmPwd" required 
                           class="w-full p-4 border border-gray-300 rounded-2xl focus:ring-2 focus:ring-indigo-500 outline-none">
                </div>
            </div>

            <div class="flex justify-end mt-8">
                <button type="submit" 
                        class="px-10 py-4 bg-amber-600 hover:bg-amber-700 text-white font-semibold rounded-2xl transition">
                    Update Password
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    // Password confirmation check
    document.querySelector('form[action*="changePassword"]').addEventListener('submit', function(e) {
        const newPwd = document.getElementById('newPwd').value;
        const confirmPwd = document.getElementById('confirmPwd').value;
        
        if (newPwd !== confirmPwd) {
            e.preventDefault();
            alert("New passwords do not match!");
        }
    });
</script>