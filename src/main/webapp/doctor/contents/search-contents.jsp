<%-- 
    Document   : search-contents
    Created on : 2026年4月23日, 02:22:48
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class='glass rounded-3xl p-6 max-w-4xl'>
    <h3 class='text-2xl font-bold mb-6'>Patient Lookup</h3>
    <div class='flex flex-col md:flex-row gap-3 mb-6'>
        <input id='search-keyword' placeholder='Enter name, phone, or ticket no...' class='flex-1 p-3 border rounded-xl outline-none focus:ring-2 focus:ring-sky-500 transition'>
        <button class='px-6 py-3 bg-sky-600 hover:bg-sky-700 text-white font-medium rounded-xl transition' onclick='performSearch()'>Search</button>
    </div>
    <div id='search-results' class='space-y-3'>
        <div class='p-8 border-2 border-dashed rounded-2xl text-center text-gray-400'><i class='fa-solid fa-magnifying-glass text-3xl mb-2'></i><p>Enter details above to search records.</p></div>
    </div>
</div>