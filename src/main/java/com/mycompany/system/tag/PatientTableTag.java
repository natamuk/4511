package com.mycompany.system.tag;

import com.mycompany.system.bean.PatientBean;
import jakarta.servlet.jsp.tagext.SimpleTagSupport;
import jakarta.servlet.jsp.JspWriter;
import jakarta.servlet.jsp.PageContext;
import java.io.IOException;
import java.util.List;

public class PatientTableTag extends SimpleTagSupport {

    private List<PatientBean> patients;

    public void setPatients(List<PatientBean> patients) {
        this.patients = patients;
    }

    @Override
    public void doTag() throws IOException {
        JspWriter out = getJspContext().getOut();
        PageContext pageContext = (PageContext) getJspContext();
        String contextPath = pageContext.getRequest().getServletContext().getContextPath();

        out.write("<table class='w-full text-sm text-left min-w-[900px]'>");
        out.write("<thead class='bg-gray-50 text-gray-600 border-b'>");
        out.write("<tr><th>Name</th><th>Username</th><th>Phone</th><th>Email</th><th>Address</th><th>Action</th></tr>");
        out.write("</thead><tbody>");
        if (patients != null) {
            for (PatientBean p : patients) {
                out.write("<tr>");
                out.write("<td>" + p.getRealName() + "</td>");
                out.write("<td>" + p.getUsername() + "</td>");
                out.write("<td>" + p.getPhone() + "</td>");
                out.write("<td>" + p.getEmail() + "</td>");
                out.write("<td>" + p.getAddress() + "</td>");
                out.write("<td><a href='" + contextPath + "/admin/edit.jsp?role=patient&id=" + p.getId()
                        + "' class='px-3 py-1 bg-green-600 text-white rounded'>Edit</a>");
                out.write("<a href='" + contextPath + "/AbminDeleteServlet?role=patient&id=" + p.getId()
                        + "' class='px-3 py-1 bg-red-600 text-white rounded' "
                        + "onclick=\"return confirm('Are you sure you want to delete this doctor?');\">Delete</a>");
                out.write("</td>");
                out.write("</tr>");
            }
        }
        out.write("</tbody></table>");
    }
}
