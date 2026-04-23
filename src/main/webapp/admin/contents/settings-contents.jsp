<%-- 
    Document   : settings-contents
    Created on : 2026年4月23日, 23:47:27
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="max-w-4xl mx-auto glass p-8 rounded-3xl space-y-8">
    <h3 class="text-2xl font-bold text-gray-800 border-b pb-4">Global Policies</h3>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="space-y-2">
            <label class="block text-sm font-bold text-gray-700 mb-2">Max Active Bookings per Patient</label>
            <p class="text-xs text-gray-500 mb-2">Limit how many future appointments a single patient can hold.</p>
            <input id="st-max" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" value="${settings.max_active_bookings_per_patient != null ? settings.max_active_bookings_per_patient : 3}">
        </div>
        <div class="space-y-2">
            <label class="block text-sm font-bold text-gray-700 mb-2">Cancellation Deadline (Hours)</label>
            <p class="text-xs text-gray-500 mb-2">How many hours before the appointment can they cancel?</p>
            <input id="st-cancel" type="number" class="w-full p-3 border rounded-xl outline-none focus:ring-2 focus:ring-indigo-500 shadow-sm" value="${settings.cancel_deadline_hours != null ? settings.cancel_deadline_hours : 24}">
        </div>
    </div>
    <h3 class="text-2xl font-bold text-gray-800 border-b pb-4 mt-10">Feature Toggles</h3>
    <div class="space-y-6">
        <div class="flex items-center gap-4 p-4 border rounded-2xl bg-white shadow-sm">
            <div class="relative inline-block w-12 h-6 align-middle select-none transition duration-200 ease-in">
                <input type="checkbox" name="toggle" id="st-queue" class="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 appearance-none cursor-pointer border-gray-300 checked:border-indigo-600 checked:right-0 transition-all duration-200" ${settings.same_day_queue_enabled == '1' ? 'checked' : ''}/>
                <label for="st-queue" class="toggle-label block overflow-hidden h-6 rounded-full bg-gray-300 cursor-pointer"></label>
            </div>
            <div>
                <label for="st-queue" class="font-bold text-gray-800 cursor-pointer">Enable Same-day Walk-in Queue</label>
                <p class="text-sm text-gray-500">Allow patients to join the queue on the day of service.</p>
            </div>
        </div>
        <div class="flex items-center gap-4 p-4 border rounded-2xl bg-white shadow-sm">
            <div class="relative inline-block w-12 h-6 align-middle select-none transition duration-200 ease-in">
                <input type="checkbox" name="toggle" id="st-approval" class="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 appearance-none cursor-pointer border-gray-300 checked:border-indigo-600 checked:right-0 transition-all duration-200" ${settings.booking_approval_required == '1' ? 'checked' : ''}/>
                <label for="st-approval" class="toggle-label block overflow-hidden h-6 rounded-full bg-gray-300 cursor-pointer"></label>
            </div>
            <div>
                <label for="st-approval" class="font-bold text-gray-800 cursor-pointer">Require Booking Approval</label>
                <p class="text-sm text-gray-500">Doctors or staff must manually approve new online bookings.</p>
            </div>
        </div>
    </div>
    <div class="pt-6 mt-6 border-t flex justify-end">
        <button onclick="Swal.fire('Info','Settings storage API is not connected yet.','info')" class="px-8 py-3 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold transition shadow-md">Save Global Settings</button>
    </div>
</div>