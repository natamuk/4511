<%-- 
    Document   : profile-contents
    Created on : 2026年4月22日, 22:15:58
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<%
    Map<String, Object> profile = (Map<String, Object>) request.getAttribute("patientProfile");
    if (profile == null)
        profile = new HashMap<>();
%>
<div class="max-w-4xl mx-auto space-y-6">
    <div class="glass rounded-3xl p-8">
        <h3 class="text-2xl font-semibold mb-6 border-b pb-3">Personal Information</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div class="md:col-span-2">
                <label class="text-sm text-gray-700 font-semibold mb-2 flex items-center gap-2">Profile Avatar <span class="text-red-500 text-xs font-normal bg-red-50 px-2 py-1 rounded-md">JPG/PNG only</span></label>
                <input id="avatar-upload" type="file" accept="image/jpeg, image/png" class="w-full p-3 border rounded-xl bg-white cursor-pointer hover:bg-gray-50 transition">
            </div>
            <div class="md:col-span-2 flex items-center gap-4 mb-2">
                <img id="avatar-preview" src="<%= profile.get("avatar") != null ? profile.get("avatar") : "https://picsum.photos/200/200?random=1"%>" class="w-20 h-20 rounded-2xl object-cover ring-4 ring-gray-100 shadow-sm" alt="avatar preview">
                <p class="text-sm text-gray-500">Image previews immediately after selection.</p>
            </div>
            <div><label class="block text-sm text-gray-700 font-medium mb-1">Full Name</label><input id="pf-name" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= profile.get("realName") != null ? profile.get("realName") : ""%>"></div>
            <div><label class="block text-sm text-gray-700 font-medium mb-1">Phone Number</label><input id="pf-phone" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= profile.get("phone") != null ? profile.get("phone") : ""%>"></div>
            <div><label class="block text-sm text-gray-700 font-medium mb-1">Email Address</label><input id="pf-email" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= profile.get("email") != null ? profile.get("email") : ""%>"></div>
            <div><label class="block text-sm text-gray-700 font-medium mb-1">Home Address</label><input id="pf-address" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" value="<%= profile.get("address") != null ? profile.get("address") : ""%>"></div>
        </div>
    </div>
    <div class="glass rounded-3xl p-8">
        <h3 class="text-2xl font-semibold mb-6 border-b pb-3 text-gray-800"><i class="fa-solid fa-lock text-gray-400 mr-2"></i>Change Password</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div class="md:col-span-2"><label class="block text-sm text-gray-700 font-medium mb-1">Current Password</label><input type="password" id="pf-old-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Leave blank if not changing"></div>
            <div><label class="block text-sm text-gray-700 font-medium mb-1">New Password</label><input type="password" id="pf-new-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Enter new password"></div>
            <div><label class="block text-sm text-gray-700 font-medium mb-1">Confirm New Password</label><input type="password" id="pf-conf-pwd" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-blue-500 transition" placeholder="Re-enter new password"></div>
        </div>
    </div>
    <div class="flex gap-4 pt-2">
        <button onclick="saveProfileFromPage()" class="px-8 py-3 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 shadow-sm transition">Save All Changes</button>
        <button onclick="loadPage('home')" class="px-8 py-3 bg-gray-200 text-gray-700 font-medium rounded-xl hover:bg-gray-300 transition">Cancel</button>
    </div>
</div>