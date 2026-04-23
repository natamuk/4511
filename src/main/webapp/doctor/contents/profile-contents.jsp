<%-- 
    Document   : profile-contents
    Created on : 2026年4月23日, 02:23:03
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<div class='max-w-3xl mx-auto glass rounded-3xl p-8'>
    <div class='flex items-center gap-6 mb-8 pb-8 border-b'>
        <img src='https://picsum.photos/200' class='w-24 h-24 rounded-full ring-4 ring-sky-50 object-cover shadow-sm' alt='avatar'>
        <div>
            <h3 class='text-2xl font-bold text-gray-800'>Dr. User</h3>
            <p class='text-sky-600 font-medium mt-1'>Physician｜General Clinic</p>
        </div>
    </div>

    <h4 class='text-lg font-bold text-gray-800 mb-4'><i class='fa-solid fa-address-card text-gray-400 mr-2'></i> Basic Information</h4>
    <div class='grid grid-cols-1 md:grid-cols-2 gap-6'>
        <div>
            <label class='block text-sm font-medium text-gray-600 mb-1'>Full Name</label>
            <input class='w-full p-3 border rounded-xl bg-gray-50 text-gray-700 outline-none' value='Dr. User' readonly>
        </div>
        <div>
            <label class='block text-sm font-medium text-gray-600 mb-1'>Title</label>
            <input class='w-full p-3 border rounded-xl bg-gray-50 text-gray-700 outline-none' value='Physician' readonly>
        </div>
        <div class='md:col-span-2'>
            <label class='block text-sm font-medium text-gray-600 mb-1'>Department</label>
            <input class='w-full p-3 border rounded-xl bg-gray-50 text-gray-700 outline-none' value='General Clinic' readonly>
        </div>
    </div>

    <div class='mt-10 pt-8 border-t border-gray-200'>
        <h4 class='text-lg font-bold text-gray-800 mb-6'><i class='fa-solid fa-lock text-gray-400 mr-2'></i> Change Password</h4>
        <div class='grid grid-cols-1 md:grid-cols-2 gap-6'>
            <div class='md:col-span-2'>
                <label class='block text-sm font-medium text-gray-600 mb-1'>Current Password</label>
                <input type='password' id='doc-old-pwd' class='w-full p-3 border rounded-xl bg-white focus:ring-2 focus:ring-sky-500 outline-none transition shadow-sm' placeholder='Leave blank if not changing'>
            </div>
            <div>
                <label class='block text-sm font-medium text-gray-600 mb-1'>New Password</label>
                <input type='password' id='doc-new-pwd' class='w-full p-3 border rounded-xl bg-white focus:ring-2 focus:ring-sky-500 outline-none transition shadow-sm' placeholder='Enter new password'>
            </div>
            <div>
                <label class='block text-sm font-medium text-gray-600 mb-1'>Confirm New Password</label>
                <input type='password' id='doc-conf-pwd' class='w-full p-3 border rounded-xl bg-white focus:ring-2 focus:ring-sky-500 outline-none transition shadow-sm' placeholder='Re-enter new password'>
            </div>
        </div>
    </div>

    <div class='mt-8 pt-4 flex justify-end gap-3'>
        <button onclick='Swal.fire("Saved","Profile updated","success")' class='px-8 py-3 bg-sky-600 text-white rounded-xl font-bold hover:bg-sky-700 transition shadow-md'>Save Changes</button>
    </div>
</div>