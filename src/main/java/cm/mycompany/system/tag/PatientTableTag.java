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
        out.write("<tr><th>Name</th><th>Username</th><th>Phone</th><th>Email</th><th>Address</th><th>Status</th><th>Action</th></tr>");
        out.write("</thead><tbody>");
        if (patients != null) {
            for (PatientBean p : patients) {
                out.write("<tr>");
                out.write("<td>" + p.getRealName() + "</td>");
                out.write("<td>" + p.getUsername() + "</td>");
                out.write("<td>" + p.getPhone() + "</td>");
                out.write("<td>" + p.getEmail() + "</td>");
                out.write("<td>" + p.getAddress() + "</td>");
                out.write("<td>" + (p.getStatus() == 1 ? "Active" : "Inactive") + "</td>");
                out.write("<td><a href='" + contextPath + "/admin/contents/edit.jsp?id=" + p.getId()
                        + "' class='px-3 py-1 bg-blue-600 text-white rounded'>Edit</a></td>");
                out.write("</tr>");
            }
        }
        out.write("</tbody></table>");
    }
}
