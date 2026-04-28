package com.mycompany.system.tag;

import com.mycompany.system.bean.AdminBean;
import jakarta.servlet.jsp.JspWriter;
import jakarta.servlet.jsp.PageContext;
import jakarta.servlet.jsp.tagext.SimpleTagSupport;
import java.io.IOException;
import java.util.List;

public class AdminTableTag extends SimpleTagSupport {

    private List<AdminBean> admins;

    public void setAdmins(List<AdminBean> admins) {
        this.admins = admins;
    }

    @Override
    public void doTag() throws IOException {
        JspWriter out = getJspContext().getOut();
        PageContext pageContext = (PageContext) getJspContext();
        String contextPath = pageContext.getRequest().getServletContext().getContextPath();

        out.write("<table class='w-full text-sm text-left min-w-[900px]'>");
        out.write("<thead class='bg-gray-50 text-gray-600 border-b'>");
        out.write("<tr>");
        out.write("<th>Name</th>");
        out.write("<th>Username</th>");
        out.write("<th>Phone</th>");
        out.write("<th>Email</th>");
        out.write("<th>Action</th>");
        out.write("</tr>");
        out.write("</thead>");
        out.write("<tbody>");

        if (admins != null && !admins.isEmpty()) {
            for (AdminBean a : admins) {
                out.write("<tr>");
                out.write("<td>" + (a.getRealName() != null ? a.getRealName() : "") + "</td>");
                out.write("<td>" + (a.getUsername() != null ? a.getUsername() : "") + "</td>");
                out.write("<td>" + (a.getPhone() != null ? a.getPhone() : "") + "</td>");
                out.write("<td>" + (a.getEmail() != null ? a.getEmail() : "") + "</td>");
                out.write("<td>");
                out.write("<a href='" + contextPath + "/admin/contents/edit.jsp?role=admin&id=" + a.getId() 
                        + "' class='px-3 py-1 bg-blue-600 text-white rounded mr-2 hover:bg-blue-700'>Edit</a>");
                out.write("<a href='" + contextPath + "/AbminDeleteServlet?role=admin&id=" + a.getId() 
                        + "' class='px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700' "
                        + "onclick=\"return confirm('Are you sure you want to delete this admin?');\">Delete</a>");
                out.write("</td>");
                out.write("</tr>");
            }
        } else {
            out.write("<tr><td colspan='6' class='text-center py-8 text-gray-500'>No admin users found.</td></tr>");
        }

        out.write("</tbody></table>");
    }
}