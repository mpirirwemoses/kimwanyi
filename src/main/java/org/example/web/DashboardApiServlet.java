package org.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.config.HibernateUtil;
import org.example.model.Loan;
import org.example.model.LoanStatus;
import org.example.model.Payment;
import org.example.model.User;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/dashboard-data")
public class DashboardApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Long userId = sessionUserId(request);
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.find(User.class, userId);
            
            // Get all loans for the user
            List<Loan> loans = session.createQuery(
                "from Loan where member.id = :memberId order by appliedAt desc", Loan.class)
                .setParameter("memberId", userId)
                .list();
            
            // Calculate statistics
            int activeLoans = 0;
            BigDecimal totalOutstanding = BigDecimal.ZERO;
            BigDecimal totalRepaid = BigDecimal.ZERO;
            LocalDateTime nextDue = null;
            
            for (Loan loan : loans) {
                if (loan.getStatus() == LoanStatus.APPROVED) {
                    activeLoans++;
                    if (loan.getOutstandingBalance() != null) {
                        totalOutstanding = totalOutstanding.add(loan.getOutstandingBalance());
                    }
                    if (loan.getDueDate() != null && (nextDue == null || loan.getDueDate().isBefore(nextDue))) {
                        nextDue = loan.getDueDate();
                    }
                } else if (loan.getStatus() == LoanStatus.REPAID) {
                    if (loan.getTotalRepayable() != null) {
                        totalRepaid = totalRepaid.add(loan.getTotalRepayable());
                    }
                }
            }
            
            // Get recent loans (last 5)
            List<Loan> recentLoans = loans.subList(0, Math.min(5, loans.size()));
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"activeLoans\":").append(activeLoans).append(",");
            json.append("\"totalOutstanding\":").append(totalOutstanding).append(",");
            json.append("\"totalRepaid\":").append(totalRepaid).append(",");
            json.append("\"nextDue\":\"").append(nextDue != null ? nextDue.toString() : "").append("\",");
            json.append("\"recentLoans\":[");
            
            for (int i = 0; i < recentLoans.size(); i++) {
                Loan loan = recentLoans.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(loan.getId()).append(",");
                json.append("\"purpose\":\"").append(escapeJson(loan.getPurpose())).append("\",");
                json.append("\"amount\":").append(loan.getRequestedAmount()).append(",");
                json.append("\"status\":\"").append(loan.getStatus()).append("\",");
                json.append("\"appliedAt\":\"").append(loan.getAppliedAt().toString()).append("\"");
                json.append("}");
            }
            
            json.append("]");
            json.append("}");
            
            response.getWriter().write(json.toString());
        }
    }
    
    private Long sessionUserId(HttpServletRequest request) {
        Object value = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
        return value instanceof Long id ? id : null;
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "")
                  .replace("\t", "\\t");
    }
}