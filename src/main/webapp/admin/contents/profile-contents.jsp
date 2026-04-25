<%-- 
    Document   : profile-contents
    Created on : 2026年4月23日, 23:47:36
    Author     : 123
--%>


<%@page import="com.mycompany.system.db.AdminDB"%>
<%@page import="com.mycompany.system.bean.AdminBean"%>
<%@page import="com.mycompany.system.model.LoginUser"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    LoginUser user = (LoginUser) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Long adminId = user.getId();
    AdminBean profile = AdminDB.getById(adminId);

    request.setAttribute("adminProfile", profile);

    String realName = user.getRealName();
    String email = "";
    String phone = "";

    if (profile != null) {
        if (profile.getRealName() != null) {
            realName = profile.getRealName();
        }
        if (profile.getEmail() != null) {
            email = profile.getEmail();
        }
        if (profile.getPhone() != null) {
            phone = profile.getPhone();
        }
    }
%>
<div class="max-w-3xl mx-auto glass rounded-3xl p-8">
    <h3 class="text-2xl font-bold mb-6 text-gray-800 border-b pb-4"><i class="fa-solid fa-user-shield text-gray-400 mr-2"></i>Account Profile</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="md:col-span-2 flex items-center gap-6 mb-4">
            <img src="https://picsum.photos/200/200?random=99" class="w-24 h-24 rounded-full ring-4 ring-indigo-50 object-cover shadow-sm" alt="avatar">
            <div>
                <h4 class="text-xl font-bold text-gray-800">${adminProfile.realName}</h4>
                <p class="text-sm font-medium text-indigo-600 bg-indigo-50 px-3 py-1 rounded inline-block mt-2">System Administrator</p>
            </div>
        </div>
        <div><label class="block text-sm font-bold text-gray-700 mb-2">Full Name</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="${adminProfile.realName}" readonly></div>
        <div><label class="block text-sm font-bold text-gray-700 mb-2">Role Access</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="Full Access" readonly></div>
        <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-2">Email Address</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="${adminProfile.email}" readonly></div>
        <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-2">Phone Number</label><input class="w-full p-3 border rounded-xl bg-gray-50 text-gray-600 outline-none" value="${adminProfile.phone}" readonly></div>
    </div>
    <div class="mt-10 pt-8 border-t border-gray-200">
        <h3 class="text-2xl font-bold mb-6 text-gray-800"><i class="fa-solid fa-lock text-gray-400 mr-2"></i>Change Password</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="md:col-span-2">
                <label class="block text-sm font-bold text-gray-700 mb-2">Current Password</label>
                <input type="password" id="admin-old-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 transition shadow-sm" placeholder="Leave blank if not changing">
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">New Password</label>
                <input type="password" id="admin-new-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 transition shadow-sm" placeholder="Enter new password">
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">Confirm New Password</label>
                <input type="password" id="admin-conf-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 transition shadow-sm" placeholder="Re-enter new password">
            </div>
        </div>
        <div class='mt-8 pt-4 flex justify-end gap-3'>
            <button onclick='Swal.fire("Saved", "Profile updated", "success")' class='px-8 py-3 bg-sky-600 text-white rounded-xl font-bold hover:bg-sky-700 transition shadow-md'>Save Changes</button>
        </div>
    </div>
</div>

