package com.mycompany.system.tag;

import jakarta.servlet.jsp.tagext.SimpleTagSupport;
import jakarta.servlet.jsp.JspWriter;
import java.io.IOException;
import java.util.List;
import com.mycompany.system.bean.DoctorBean;
import jakarta.servlet.jsp.PageContext;

public class DoctorTableTag extends SimpleTagSupport {

    private List<DoctorBean> doctors;

    public void setDoctors(List<DoctorBean> doctors) {
        this.doctors = doctors;
    }

    @Override
    public void doTag() throws IOException {
        JspWriter out = getJspContext().getOut();
        PageContext pageContext = (PageContext) getJspContext();
        String contextPath = pageContext.getRequest().getServletContext().getContextPath();

        out.write("<table class='w-full text-sm text-left min-w-[900px]'>");
        out.write("<thead class='bg-gray-50 text-gray-600 border-b'>");
        out.write("<tr><th>Name</th><th>Username</th><th>Phone</th><th>Email</th><th>Title</th><th>Action</th></tr>");
        out.write("</thead><tbody>");
        if (doctors != null) {
            for (DoctorBean d : doctors) {
                out.write("<tr>");
                out.write("<td>" + d.getRealName() + "</td>");
                out.write("<td>" + d.getUsername() + "</td>");
                out.write("<td>" + d.getPhone() + "</td>");
                out.write("<td>" + d.getEmail() + "</td>");
                out.write("<td>" + d.getTitle() + "</td>");
                out.write("<td>");
                out.write("<a href='" + contextPath + "/admin/contents/edit.jsp?role=doctor&id=" + d.getId()
                        + "' class='px-3 py-1 bg-blue-600 text-white rounded mr-2'>Edit</a>");
                out.write("<a href='" + contextPath + "/AbminDeleteServlet?role=doctor&id=" + d.getId()
                        + "' class='px-3 py-1 bg-red-600 text-white rounded' "
                        + "onclick=\"return confirm('Are you sure you want to delete this doctor?');\">Delete</a>");
                out.write("</td>");
                out.write("</tr>");
            }
        }
        out.write("</tbody></table>");
    }
}
