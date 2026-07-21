package org.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.config.HibernateUtil;
import org.example.model.Loan;
import org.example.model.LoanStatus;
import org.example.model.User;
import org.example.util.InterestCalculator;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@WebServlet("/loans")
public class LoanServlet extends HttpServlet {
    private static final java.math.BigDecimal DEFAULT_MAX_LOAN = new java.math.BigDecimal("100000");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Long userId = sessionUserId(request);
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        
        String action = request.getParameter("action");
        if ("apply".equals(action)) {
            request.getRequestDispatcher("/WEB-INF/views/loan-application.jsp").forward(request, response);
            return;
        }
        
        boolean admin = isAdmin(request);
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            List<Loan> loans = admin
                    ? session.createQuery("select l from Loan l join fetch l.member order by l.appliedAt desc", Loan.class).list()
                    : session.createQuery("from Loan where member.id = :memberId order by appliedAt desc", Loan.class)
                    .setParameter("memberId", userId).list();
            request.setAttribute("loans", loans);
        }
        request.getRequestDispatcher(admin ? "/WEB-INF/views/admin-loans.jsp" : "/WEB-INF/views/member-loans.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        Long userId = sessionUserId(request);
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        String action = request.getParameter("action");
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.find(User.class, userId);
            if (user == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
            Transaction transaction = session.beginTransaction();
            if (isAdmin(request)) adminAction(session, user, action, request);
            else memberAction(session, user, action, request);
            transaction.commit();
            response.sendRedirect(request.getContextPath() + "/loans?message=success");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            response.sendRedirect(request.getContextPath() + "/loans?error=" + exception.getMessage().replace(' ', '+'));
        }
    }

    private void memberAction(Session session, User member, String action, HttpServletRequest request) {
        if ("apply".equals(action)) {
            BigDecimal requested = amount(request);
            Long activeCount = session.createQuery("select count(l) from Loan l where l.member.id = :memberId and l.status in :statuses", Long.class)
                    .setParameter("memberId", member.getId())
                    .setParameterList("statuses", List.of(LoanStatus.PENDING, LoanStatus.APPROVED, LoanStatus.OVERDUE))
                    .uniqueResult();
            if (activeCount != null && activeCount > 0) throw new IllegalStateException("You already have an active or pending loan.");
            validateLoanAmount(requested, member);
            session.persist(new Loan(member, requested, purpose(request)));
            return;
        }
        Loan loan = ownedLoan(session, member, request);
        if ("update".equals(action)) loan.updateApplication(amount(request), purpose(request));
        else if ("cancel".equals(action)) loan.cancel();
        else if ("repay".equals(action)) {
            BigDecimal repayment = amount(request);
            loan.repay(repayment);
            session.merge(loan);
        }
        else if ("calculateInterest".equals(action)) {
            calculateLoanInterest(session, loan, request);
        }
        else throw new IllegalArgumentException("Unknown loan action.");
    }

    private void adminAction(Session session, User admin, String action, HttpServletRequest request) {
        if ("approve".equals(action) || "reject".equals(action)) {
            Loan loan = session.find(Loan.class, id(request));
            if (loan == null) throw new IllegalArgumentException("Loan not found.");
            String comment = value(request, "comment");
            if ("approve".equals(action)) loan.approve(admin, comment);
            else loan.reject(admin, comment);
        } else if ("calculateInterest".equals(action)) {
            Loan loan = session.find(Loan.class, id(request));
            if (loan == null) throw new IllegalArgumentException("Loan not found.");
            calculateLoanInterest(session, loan, request);
        } else {
            throw new IllegalArgumentException("Unknown loan action.");
        }
    }

    private Loan ownedLoan(Session session, User member, HttpServletRequest request) {
        Loan loan = session.find(Loan.class, id(request));
        if (loan == null || !loan.getMember().getId().equals(member.getId())) throw new IllegalArgumentException("Loan not found.");
        return loan;
    }

    private void validateLoanAmount(BigDecimal requested, User member) {
        // Business rule: maximum loan amount is three times the member's current savings balance.
        // If savings balance is not yet available (placeholder returning zero), fall back to a reasonable default maximum.
        BigDecimal savingsBalance = fetchSavingsBalance(member.getId());
        BigDecimal maxLoan;
        if (savingsBalance == null || savingsBalance.compareTo(BigDecimal.ZERO) == 0) {
            // Fallback to a default maximum until the savings module is integrated
            maxLoan = DEFAULT_MAX_LOAN;
        } else {
            maxLoan = savingsBalance.multiply(new BigDecimal("3"));
        }
        if (requested.compareTo(maxLoan) > 0) {
            throw new IllegalArgumentException("Requested loan exceeds the maximum allowed amount of KES " + maxLoan + ".");
        }
    }

    private BigDecimal fetchSavingsBalance(Long memberId) {
        // Placeholder for savings balance lookup. Returns zero until the savings module is integrated.
        return BigDecimal.ZERO;
    }

    private BigDecimal amount(HttpServletRequest request) {
        try {
            BigDecimal amount = new BigDecimal(value(request, "amount"));
            if (amount.signum() <= 0) throw new IllegalArgumentException("Loan amount must be greater than zero.");
            return amount;
        } catch (NumberFormatException exception) { throw new IllegalArgumentException("Enter a valid loan amount."); }
    }

    private String purpose(HttpServletRequest request) {
        String purpose = value(request, "purpose");
        if (purpose.isBlank() || purpose.length() > 500) throw new IllegalArgumentException("Enter a loan purpose of up to 500 characters.");
        return purpose;
    }

    private Long id(HttpServletRequest request) {
        try { return Long.valueOf(request.getParameter("loanId")); }
        catch (NumberFormatException exception) { throw new IllegalArgumentException("Invalid loan."); }
    }

    private Long sessionUserId(HttpServletRequest request) {
        Object value = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
        return value instanceof Long id ? id : null;
    }

    private boolean isAdmin(HttpServletRequest request) {
        return "ADMIN".equals(request.getSession(false).getAttribute("userRole"));
    }

    private void calculateLoanInterest(Session session, Loan loan, HttpServletRequest request) {
        if (loan.getStatus() != LoanStatus.APPROVED) {
            throw new IllegalStateException("Interest can only be calculated for approved loans.");
        }
        
        String periodTypeStr = value(request, "periodType");
        InterestCalculator.CalculationPeriod periodType = "WEEKLY".equalsIgnoreCase(periodTypeStr) 
            ? InterestCalculator.CalculationPeriod.WEEKLY 
            : InterestCalculator.CalculationPeriod.MONTHLY;
        
        loan.setInterestCalculationPeriod(periodType.name());
        
        LocalDateTime startDate = loan.getAppliedAt();
        LocalDateTime endDate = LocalDateTime.now();
        
        if (loan.getLastInterestCalculationDate() != null) {
            startDate = loan.getLastInterestCalculationDate();
        }
        
        int periods = InterestCalculator.calculatePeriods(startDate, endDate, periodType);
        if (periods <= 0) {
            throw new IllegalStateException("Not enough time has passed to calculate interest.");
        }
        
        BigDecimal principal = loan.getOutstandingBalance() != null ? loan.getOutstandingBalance() : loan.getRequestedAmount();
        InterestCalculator.InterestResult result = InterestCalculator.calculateSimpleInterest(
            principal, loan.getInterestRate(), periods, periodType
        );
        
        loan.setLastInterestCalculated(result.getInterestAmount());
        loan.setLastInterestCalculationDate(LocalDateTime.now());
        loan.setTotalRepayable(loan.getTotalRepayable().add(result.getInterestAmount()));
        loan.setOutstandingBalance(loan.getOutstandingBalance().add(result.getInterestAmount()));
        
        session.merge(loan);
        
        request.setAttribute("calculationProcedure", result.getCalculationProcedure());
    }

    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
