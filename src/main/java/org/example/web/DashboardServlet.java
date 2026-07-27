package org.example.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import jakarta.servlet.ServletException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Object name = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userName");
        if (name == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        String safeName = name.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
        request.setAttribute("safeUserName", safeName);
        Object role = request.getSession(false).getAttribute("userRole");
        String dashboard = "ADMIN".equals(role) ? "/WEB-INF/views/admin-dashboard.jsp" : "/WEB-INF/views/member-dashboard.jsp";
        request.getRequestDispatcher(dashboard).forward(request, response);
    }
}
