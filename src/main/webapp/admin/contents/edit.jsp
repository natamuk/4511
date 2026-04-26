<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.mycompany.system.bean.DoctorBean" %>
<%@ page import="com.mycompany.system.bean.PatientBean" %>
<%@ page import="com.mycompany.system.db.DoctorDB" %>
<%@ page import="com.mycompany.system.db.PatientDB" %>

<%
    String idParam = request.getParameter("id");
    String roleParam = request.getParameter("role");

    DoctorBean doctor = null;
    PatientBean patient = null;

    if (idParam != null && idParam.matches("\\d+")) {
        Long id = Long.parseLong(idParam);

        if ("doctor".equalsIgnoreCase(roleParam)) {
            doctor = DoctorDB.getById(id);
        } else if ("patient".equalsIgnoreCase(roleParam)) {
            patient = PatientDB.getById(id);
        }
    }
%>

<html>
    <head>
        <title>Edit User</title>
    </head>
    <body>
        <h2>Edit User</h2>

        <% if (doctor != null) {%>
        <form method="post" action="${pageContext.request.contextPath}/UpdateDoctorServlet">
            <input type="hidden" name="id" value="<%= doctor.getId()%>" />
            Name: <input type="text" name="realName" value="<%= doctor.getRealName()%>" /><br/>
            Username: <input type="text" name="username" value="<%= doctor.getUsername()%>" /><br/>
            Phone: <input type="text" name="phone" value="<%= doctor.getPhone()%>" /><br/>
            Email: <input type="text" name="email" value="<%= doctor.getEmail()%>" /><br/>
            Title: <input type="text" name="title" value="<%= doctor.getTitle()%>" /><br/>
            Status: <select name="status">
                <option value="1" <%= doctor.getStatus() == 1 ? "selected" : ""%>>Active</option>
                <option value="0" <%= doctor.getStatus() == 0 ? "selected" : ""%>>Inactive</option>
            </select><br/>
            <button type="submit">Save</button>
        </form>
        <% } else if (patient != null) {%>
        <form method="post" action="${pageContext.request.contextPath}/UpdatePatientServlet">
            <input type="hidden" name="id" value="<%= patient.getId()%>" />
            Name: <input type="text" name="realName" value="<%= patient.getRealName()%>" /><br/>
            Username: <input type="text" name="username" value="<%= patient.getUsername()%>" /><br/>
            Phone: <input type="text" name="phone" value="<%= patient.getPhone()%>" /><br/>
            Email: <input type="text" name="email" value="<%= patient.getEmail()%>" /><br/>
            Address: <input type="text" name="address" value="<%= patient.getAddress()%>" /><br/>
            Status: <select name="status">
                <option value="1" <%= patient.getStatus() == 1 ? "selected" : ""%>>Active</option>
                <option value="0" <%= patient.getStatus() == 0 ? "selected" : ""%>>Inactive</option>
            </select><br/>
            
            <button type="button" 
                    onclick="window.location.href = '<%= request.getContextPath()%>/admin/dashboard'" 
                    class="px-4 py-2 bg-gray-300 rounded">
                Back
            </button>
            <button type="submit">Save</button>
        </form>
        <% } else { %>
        <p>User not found.</p>
        <% }%>


    </body>
</html>
