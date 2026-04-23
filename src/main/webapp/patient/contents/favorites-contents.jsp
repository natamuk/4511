<%-- 
    Document   : favorites-contents
    Created on : 2026年4月22日, 22:16:04
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*" %>
<%
    List<Map<String, Object>> clinics = (List<Map<String, Object>>) request.getAttribute("clinics");
    List<Map<String, Object>> favorites = (List<Map<String, Object>>) request.getAttribute("favorites");
    if (clinics == null) {
        clinics = new ArrayList<>();
    }
    if (favorites == null)
        favorites = new ArrayList<>();
%>
<div class="glass p-8 rounded-3xl max-w-4xl mx-auto">
    <h3 class="text-2xl font-bold mb-6 border-b pb-3">Saved Clinics</h3>
    <div class="space-y-4" id="favorites-list"></div>
</div>

<script>
    const clinics =<%=new com.google.gson.Gson().toJson(clinics)%>;
    const favorites =<%=new com.google.gson.Gson().toJson(favorites)%>;
    function renderFavorites() {
        const list = clinics.filter(cn => favorites.some(f => String.valueOf(f).equals(cn.get("name"))));
        const c = document.getElementById('favorites-list');
        c.innerHTML = '';
        if (list.length == 0) {
            c.innerHTML = '<div class="text-center py-12 text-gray-500"><i class="fa-regular fa-heart text-4xl mb-3"></i><p>No favorite clinics added yet.</p></div>';
            return;
        }
        list.forEach(x => {
            c.innerHTML += `<div class="p-5 border rounded-2xl bg-white flex justify-between items-center shadow-sm hover:shadow-md transition">
<div>
<p class="font-semibold text-lg text-gray-800">${x.name}</p>
<p class="text-sm text-gray-500 mt-1"><i class="fa-solid fa-location-dot mr-1"></i> ${x.location||''}</p>
</div>
<div class="flex gap-3">
<button onclick="loadPage('book')" class="px-4 py-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition font-medium">Book</button>
<button onclick="toggleFavorite('${x.name}');loadPage('favorites')" class="px-4 py-2 bg-red-50 text-red-500 rounded-xl hover:bg-red-100 transition font-medium"><i class="fa-solid fa-heart"></i></button>
</div>
</div>`;
        });
    }
    setTimeout(renderFavorites, 100);
</script>