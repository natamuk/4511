/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.system.tag;

import jakarta.servlet.jsp.JspWriter;
import jakarta.servlet.jsp.PageContext;
import jakarta.servlet.jsp.tagext.SimpleTagSupport;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 *
 * @author USER
 */
public class TodayTag extends SimpleTagSupport {

    @Override
    public void doTag() throws IOException {
        JspWriter out = getJspContext().getOut();

        String today = LocalDate.now()
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd EEE", Locale.ENGLISH));

        out.write(today);
    }
}
