package org.example.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Object name = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userName");
        if (name == null) { response.sendRedirect(request.getContextPath() + "/login.html"); return; }
        response.setContentType("text/html;charset=UTF-8");
        String safeName = name.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
        response.getWriter().printf("<!doctype html><html><head><meta charset='UTF-8'><title>Credit SACCO</title><link rel='stylesheet' href='%s/assets/styles.css'></head><body><main class='card'><p class='eyebrow'>Credit SACCO</p><h1>Welcome, %s</h1><p>You are signed in successfully.</p><form method='post' action='%s/logout'><button type='submit'>Log out</button></form></main></body></html>", request.getContextPath(), safeName, request.getContextPath());
    }
}
