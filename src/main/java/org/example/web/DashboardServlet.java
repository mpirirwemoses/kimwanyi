package org.example.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.config.HibernateUtil;
import org.example.model.Loan;
import org.example.model.LoanStatus;
import org.example.model.SavingsAccount;
import org.hibernate.Session;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import jakarta.servlet.ServletException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Object name = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userName");
        if (name == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        request.setAttribute("safeUserName", name.toString());
        Object role = request.getSession(false).getAttribute("userRole");
        
        // Load dashboard data from database for initial server-side rendering
        if (!"ADMIN".equals(role)) {
            Long userId = (Long) request.getSession(false).getAttribute("userId");
            if (userId != null) {
                try (Session session = HibernateUtil.getSessionFactory().openSession()) {
                    List<Loan> loans = session.createQuery(
                        "from Loan where member.id = :memberId order by appliedAt desc", Loan.class)
                        .setParameter("memberId", userId)
                        .list();
                    
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
                    
                    BigDecimal savingsBalance = session.createQuery(
                        "select coalesce(sum(sa.balance), 0) from SavingsAccount sa where sa.member.id = :memberId and sa.status = :status", 
                        BigDecimal.class)
                        .setParameter("memberId", userId)
                        .setParameter("status", org.example.model.SavingsStatus.ACTIVE)
                        .uniqueResult();
                    
                    if (savingsBalance == null) savingsBalance = BigDecimal.ZERO;
                    
                    request.setAttribute("activeLoans", activeLoans);
                    request.setAttribute("totalOutstanding", totalOutstanding.setScale(2, RoundingMode.HALF_UP));
                    request.setAttribute("totalRepaid", totalRepaid.setScale(2, RoundingMode.HALF_UP));
                    request.setAttribute("savingsBalance", savingsBalance.setScale(2, RoundingMode.HALF_UP));
                    request.setAttribute("nextDue", nextDue != null ? nextDue.format(DateTimeFormatter.ofPattern("MMM dd, yyyy")) : "-");
                }
            }
        }
        
        String dashboard = "ADMIN".equals(role) ? "/WEB-INF/views/admin-dashboard.jsp" : "/WEB-INF/views/member-dashboard.jsp";
        request.getRequestDispatcher(dashboard).forward(request, response);
    }
}