package org.example.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.config.HibernateUtil;
import org.example.model.User;
import org.example.model.UserRole;
import org.example.security.PasswordUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.IOException;
import java.util.Locale;

@WebServlet(urlPatterns = {"/signup", "/login", "/logout"})
public class AuthServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        switch (request.getServletPath()) {
            case "/signup" -> signup(request, response);
            case "/login" -> login(request, response);
            case "/logout" -> { request.getSession().invalidate(); response.sendRedirect(request.getContextPath() + "/login.jsp"); }
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void signup(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = value(request, "fullName");
        String email = value(request, "email").toLowerCase(Locale.ROOT);
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        if (name.isBlank() || !email.contains("@") || password == null || password.length() < 8
                || !password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/signup.jsp?error=validation"); return;
        }
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            if (session.createQuery("from User where email = :email", User.class).setParameter("email", email).uniqueResult() != null) {
                response.sendRedirect(request.getContextPath() + "/signup.jsp?error=exists"); return;
            }
            Transaction transaction = session.beginTransaction();
            session.persist(new User(name, email, PasswordUtil.hash(password)));
            transaction.commit();
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp?registered=1");
    }

    private void login(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = value(request, "email").toLowerCase(Locale.ROOT);
        String password = request.getParameter("password");
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.createQuery("from User where email = :email", User.class).setParameter("email", email).uniqueResult();
            if (user == null || password == null || !PasswordUtil.matches(password, user.getPasswordHash())) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid"); return;
            }
            request.getSession(true).setAttribute("userName", user.getFullName());
            UserRole role = user.getRole() == null ? UserRole.MEMBER : user.getRole();
            request.getSession().setAttribute("userRole", role.name());
            request.getSession().setAttribute("userId", user.getId());
        }
        
        // Redirect based on user role
        String userRole = (String) request.getSession(false).getAttribute("userRole");
        if ("ADMIN".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/admin-dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
