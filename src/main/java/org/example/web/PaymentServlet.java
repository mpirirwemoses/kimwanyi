package org.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.config.HibernateUtil;
import org.example.model.Loan;
import org.example.model.Payment;
import org.example.model.PaymentMethod;
import org.example.model.User;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Long userId = sessionUserId(request);
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        
        String action = request.getParameter("action");
        if ("history".equals(action)) {
            showPaymentHistory(request, response, userId);
        } else if ("form".equals(action)) {
            showPaymentForm(request, response, userId);
        } else {
            response.sendRedirect(request.getContextPath() + "/loans");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        Long userId = sessionUserId(request);
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.find(User.class, userId);
            if (user == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
            
            Transaction transaction = session.beginTransaction();
            
            Long loanId = Long.valueOf(request.getParameter("loanId"));
            Loan loan = session.find(Loan.class, loanId);
            if (loan == null || !loan.getMember().getId().equals(userId)) {
                throw new IllegalArgumentException("Loan not found or access denied.");
            }
            
            BigDecimal amount = new BigDecimal(request.getParameter("amount"));
            String paymentMethodStr = request.getParameter("paymentMethod");
            PaymentMethod paymentMethod = PaymentMethod.valueOf(paymentMethodStr);
            
            String transactionId = generateTransactionId();
            String cardLastFour = request.getParameter("cardLastFour");
            
            Payment payment = new Payment(loan, user, amount, paymentMethod, transactionId);
            if (cardLastFour != null && !cardLastFour.isEmpty()) {
                payment.setCardLastFour(cardLastFour);
            }
            payment.setNotes(request.getParameter("notes"));
            
            loan.repay(amount);
            session.merge(loan);
            session.persist(payment);
            
            transaction.commit();
            response.sendRedirect(request.getContextPath() + "/payments?action=history&message=success");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/payments?action=form&loanId=" + request.getParameter("loanId") + "&error=" + e.getMessage().replace(' ', '+'));
        }
    }

    private void showPaymentHistory(HttpServletRequest request, HttpServletResponse response, Long userId) throws ServletException, IOException {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            var payments = session.createQuery(
                "from Payment where member.id = :memberId order by paymentDate desc", Payment.class)
                .setParameter("memberId", userId)
                .list();
            request.setAttribute("payments", payments);
            request.getRequestDispatcher("/WEB-INF/views/payment-history.jsp").forward(request, response);
        }
    }

    private void showPaymentForm(HttpServletRequest request, HttpServletResponse response, Long userId) throws ServletException, IOException {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Long loanId = Long.valueOf(request.getParameter("loanId"));
            Loan loan = session.find(Loan.class, loanId);
            if (loan == null || !loan.getMember().getId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/loans?error=Loan+not+found");
                return;
            }
            request.setAttribute("loan", loan);
            request.getRequestDispatcher("/WEB-INF/views/payment-form.jsp").forward(request, response);
        }
    }

    private String generateTransactionId() {
        return "TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private Long sessionUserId(HttpServletRequest request) {
        Object value = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
        return value instanceof Long id ? id : null;
    }
}