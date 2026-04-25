<%-- 
    Document   : favorites-contents
    Created on : 2026年4月22日, 22:16:04
    Author     : 123
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" import="java.util.*, com.google.gson.Gson" isELIgnored="true" %>
<%
    List<Map<String, Object>> clinics = (List<Map<String, Object>>) request.getAttribute("clinics");
    List<Map<String, Object>> favorites = (List<Map<String, Object>>) request.getAttribute("favorites");
    if (clinics == null) {
        clinics = new ArrayList<>();
    }
    if (favorites == null) {
        favorites = new ArrayList<>();
    }
    Gson gson = new Gson();
    String clinicsJson = gson.toJson(clinics);
    String favoritesJson = gson.toJson(favorites);
%>
<div class="glass rounded-3xl p-8 max-w-4xl mx-auto">
    <h3 class="text-2xl font-bold mb-6 border-b pb-3">Saved Clinics</h3>
    <div id="favorites-list" class="space-y-4"></div>
</div>

<script>
    var clinics = <%= clinicsJson%>;
    var favorites = <%= favoritesJson%>;

    function renderFavorites() {
        const container = document.getElementById('favorites-list');
        if (!favorites.length) {
            container.innerHTML = '<div class="text-center py-12 text-gray-500"><i class="fa-regular fa-heart text-4xl mb-3"></i><p>No favorite clinics added yet.</p></div>';
            return;
        }
        container.innerHTML = '';
        favorites.forEach(fav => {
            const clinic = clinics.find(c => c.id === fav.clinicId);
            if (!clinic)
                return;
            const card = `
                <div class="p-5 border rounded-2xl bg-white flex justify-between items-center shadow-sm">
                    <div>
                        <p class="font-semibold text-lg text-gray-800">${escapeHtml(clinic.name)}</p>
                        <p class="text-sm text-gray-500 mt-1"><i class="fa-solid fa-location-dot mr-1"></i> ${escapeHtml(clinic.location)}</p>
                    </div>
                    <div class="flex gap-3">
                        <button onclick="loadPage('book')" class="px-4 py-2 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100">Book</button>
                        <button onclick="removeFavorite(${clinic.id})" class="px-4 py-2 bg-red-50 text-red-500 rounded-xl hover:bg-red-100"><i class="fa-solid fa-heart"></i></button>
                    </div>
                </div>
            `;
            container.innerHTML += card;
        });
    }

    async function removeFavorite(clinicId) {
        const res = await fetch(contextPath + '/patient/toggle-favorite', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: `clinicId=${clinicId}`
        });
        const data = await res.json();
        if (data.success) {
            loadPage('favorites');
        } else {
            Swal.fire('Error', data.message, 'error');
        }
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/[&<>]/g, function (m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        });
    }

    renderFavorites();
</script>