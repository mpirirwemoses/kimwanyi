package org.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.config.HibernateUtil;
import org.example.model.*;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;

@WebServlet("/admin-dashboard")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("===== ADMIN SERVLET REACHED =====");
        String action = request.getParameter("action");
        String section = request.getParameter("section");
        if (section == null) section = "dashboard";

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // Handle view actions for detail pages
            if ("view".equals(action)) {
                String id = request.getParameter("id");
                System.out.println(id);
                if (id != null) {
                    if ("accounts".equals(section)) {
                        SavingsAccount account = session.find(SavingsAccount.class, Long.valueOf(id));
                        request.setAttribute("viewAccount", account);
                        request.getRequestDispatcher("/WEB-INF/views/admin-account-details.jsp").forward(request, response);
                        return;
                    } else if ("loans".equals(section)) {
                        Loan loan = session.find(Loan.class, Long.valueOf(id));
                        request.setAttribute("viewLoan", loan);
                        request.getRequestDispatcher("/WEB-INF/views/admin-loan-details.jsp").forward(request, response);
                        return;
                    }
                }
            }
            
            // Handle update-rate action
            if ("update-rate".equals(action)) {
                String accountId = request.getParameter("accountId");
                if (accountId != null) {
                    SavingsAccount account = session.find(SavingsAccount.class, Long.valueOf(accountId));
                    request.setAttribute("viewAccount", account);
                    request.getRequestDispatcher("/WEB-INF/views/admin-update-rate.jsp").forward(request, response);
                    return;
                }
            }
            
            // Handle get-member action for member details
            if ("get-member".equals(action) || "contact".equals(action)) {
                String memberId = request.getParameter("memberId");
                if (memberId != null) {
                    User member = session.find(User.class, Long.valueOf(memberId));
                    request.setAttribute("editMember", member);
                }
                
                if ("contact".equals(action)) {
                    request.getRequestDispatcher("/WEB-INF/views/admin-contact-member.jsp").forward(request, response);
                    return;
                }
            }
            
            // Load the appropriate section
            switch (section) {
                case "members":
                    loadMembers(request, session);
                    break;
                case "accounts":
                    loadAccounts(request, session);
                    break;
                case "loans":
                    loadLoans(request, session);
                    break;
                case "overdue":
                    loadOverdueLoans(request, session);
                    break;
                case "notifications":
                    loadNotifications(request, session);
                    break;
                case "reports":
                    loadReports(request, session);
                    break;
                case "audit":
                    loadAuditTrail(request, session);
                    break;
                default:
                    loadDashboardStats(request, session);
                    break;
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/admin-enhanced.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String section = request.getParameter("section");

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction transaction = session.beginTransaction();

            switch (action) {
                case "add-member":
                case "update-member":
                    saveMember(request, session);
                    break;
                case "delete-member":
                    deleteMember(request, session);
                    break;
                case "approve-loan":
                    approveLoan(request, session);
                    break;
                case "reject-loan":
                    rejectLoan(request, session);
                    break;
                case "approve-cash-payment":
                    approveCashPayment(request, session);
                    break;
                case "change-loan-status":
                    changeLoanStatus(request, session);
                    break;
                case "update-rate":
                    updateInterestRate(request, session);
                    break;
                case "send-notification":
                    sendNotification(request, session);
                    break;
                case "send-overdue-notifications":
                    sendOverdueNotifications(request, session);
                    break;
                case "get-member":
                    getMember(request, session);
                    break;
                case "generate-report":
                    generateReport(request, session, response);
                    break;
                default:
                    break;
            }

            transaction.commit();
            
            // For get-member and generate-report, we don't redirect
            if (!"get-member".equals(action) && !"generate-report".equals(action)) {
                response.sendRedirect(request.getContextPath() + "/admin-dashboard?section=" + section + "&message=success");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin-dashboard?section=" + section + "&error=" + e.getMessage().replace(' ', '+'));
        }
    }

    private void loadDashboardStats(HttpServletRequest request, Session session) {
        // Total members
        Long totalMembers = session.createQuery("select count(u) from User u where u.role = :role", Long.class)
                .setParameter("role", UserRole.MEMBER)
                .uniqueResult();
        if (totalMembers == null) totalMembers = 0L;
        request.setAttribute("totalMembers", totalMembers);

        // Total savings
        BigDecimal totalSavings = session.createQuery("select sum(sa.balance) from SavingsAccount sa where sa.status = :status", BigDecimal.class)
                .setParameter("status", SavingsStatus.ACTIVE)
                .uniqueResult();
        if (totalSavings == null) totalSavings = BigDecimal.ZERO;
        request.setAttribute("totalSavings", totalSavings);

        // Pending loans
        Long pendingLoans = session.createQuery("select count(l) from Loan l where l.status = :status", Long.class)
                .setParameter("status", LoanStatus.PENDING)
                .uniqueResult();
        if (pendingLoans == null) pendingLoans = 0L;
        request.setAttribute("pendingLoans", pendingLoans);

        // Overdue loans
        LocalDateTime now = LocalDateTime.now();
        Long overdueLoans = session.createQuery(
                "select count(l) from Loan l where l.status = :status and l.dueDate < :now", Long.class)
                .setParameter("status", LoanStatus.APPROVED)
                .setParameter("now", now)
                .uniqueResult();
        if (overdueLoans == null) overdueLoans = 0L;
        request.setAttribute("overdueLoans", overdueLoans);
    }

    private void loadMembers(HttpServletRequest request, Session session) {
        List<User> members = session.createQuery("from User where role = :role order by fullName", User.class)
                .setParameter("role", UserRole.MEMBER)
                .list();
        request.setAttribute("members", members);
    }

    private void loadAccounts(HttpServletRequest request, Session session) {
        List<SavingsAccount> accounts = session.createQuery(
                "select sa from SavingsAccount sa join fetch sa.member order by sa.createdAt desc",
                SavingsAccount.class).list();
        request.setAttribute("accounts", accounts);
    }

    private void loadLoans(HttpServletRequest request, Session session) {
        List<Loan> loans = session.createQuery(
                "select l from Loan l join fetch l.member order by l.appliedAt desc",
                Loan.class).list();
        request.setAttribute("loans", loans);
    }

    private void loadOverdueLoans(HttpServletRequest request, Session session) {
        LocalDateTime now = LocalDateTime.now();
        List<Loan> overdueLoans = session.createQuery(
                "select l from Loan l join fetch l.member where l.status = :status and l.dueDate < :now order by l.dueDate desc",
                Loan.class)
                .setParameter("status", LoanStatus.APPROVED)
                .setParameter("now", now)
                .list();

        // Calculate days overdue for each loan
        for (Loan loan : overdueLoans) {
            if (loan.getDueDate() != null) {
                long daysOverdue = ChronoUnit.DAYS.between(loan.getDueDate(), now);
                loan.setOutstandingBalance(loan.getOutstandingBalance());
            }
        }

        request.setAttribute("overdueLoans", overdueLoans);
    }

    private void loadNotifications(HttpServletRequest request, Session session) {
        List<Notification> notifications = session.createQuery(
                "from org.example.model.Notification order by createdAt desc",
                Notification.class).list();
        request.setAttribute("notifications", notifications);
    }

    private void loadReports(HttpServletRequest request, Session session) {
        // Monthly savings
        LocalDateTime monthStart = LocalDateTime.now().withDayOfMonth(1).truncatedTo(ChronoUnit.DAYS);
        BigDecimal monthlySavings = session.createQuery(
                "select sum(st.amount) from SavingsTransaction st where st.type = :type and st.transactionDate >= :monthStart",
                BigDecimal.class)
                .setParameter("type", TransactionType.DEPOSIT)
                .setParameter("monthStart", monthStart)
                .uniqueResult();
        if (monthlySavings == null) monthlySavings = BigDecimal.ZERO;
        request.setAttribute("monthlySavings", monthlySavings);

        // Monthly loans
        BigDecimal monthlyLoans = session.createQuery(
                "select sum(l.requestedAmount) from Loan l where l.appliedAt >= :monthStart",
                BigDecimal.class)
                .setParameter("monthStart", monthStart)
                .uniqueResult();
        if (monthlyLoans == null) monthlyLoans = BigDecimal.ZERO;
        request.setAttribute("monthlyLoans", monthlyLoans);

        // Total members
        Long totalMembers = session.createQuery("select count(u) from User u where u.role = :role", Long.class)
                .setParameter("role", UserRole.MEMBER)
                .uniqueResult();
        if (totalMembers == null) totalMembers = 0L;
        request.setAttribute("totalMembers", totalMembers);

        // Active loans
        Long activeLoans = session.createQuery("select count(l) from Loan l where l.status = :status", Long.class)
                .setParameter("status", LoanStatus.APPROVED)
                .uniqueResult();
        if (activeLoans == null) activeLoans = 0L;
        request.setAttribute("activeLoans", activeLoans);
    }

    private void loadAuditTrail(HttpServletRequest request, Session session) {
        List<AuditLog> auditLogs = session.createQuery(
                "from org.example.model.AuditLog order by timestamp desc",
                AuditLog.class).list();
        request.setAttribute("auditLogs", auditLogs);
    }

    private void saveMember(HttpServletRequest request, Session session) {
        String memberId = request.getParameter("memberId");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String nationalId = request.getParameter("nationalId");
        String physicalAddress = request.getParameter("physicalAddress");
        String status = request.getParameter("status");

        User user;
        if (memberId != null && !memberId.isEmpty()) {
            user = session.find(User.class, Long.valueOf(memberId));
            if (user == null) throw new IllegalArgumentException("Member not found");
        } else {
            user = new User(fullName, email, "default123");
            user.setRole(UserRole.MEMBER);
            user.setMembershipNumber("MEM-" + System.currentTimeMillis());
        }

        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhoneNumber(phoneNumber);
        user.setNationalId(nationalId);
        user.setPhysicalAddress(physicalAddress);
        user.setStatus(AccountStatus.valueOf(status));

        if (memberId == null || memberId.isEmpty()) {
            session.persist(user);
        } else {
            session.merge(user);
        }

        // Create audit log
        createAuditLog(session, user, "MEMBER_UPDATE", "Member " + fullName + " was " + (memberId == null ? "created" : "updated"));
    }

    private void deleteMember(HttpServletRequest request, Session session) {
        Long memberId = Long.valueOf(request.getParameter("memberId"));
        User user = session.find(User.class, memberId);
        if (user == null) throw new IllegalArgumentException("Member not found");

        user.setStatus(AccountStatus.INACTIVE);
        session.merge(user);

        createAuditLog(session, user, "MEMBER_DELETE", "Member " + user.getFullName() + " was deactivated");
    }

    private void approveLoan(HttpServletRequest request, Session session) {
        Long loanId = Long.valueOf(request.getParameter("loanId"));
        String comment = request.getParameter("comment");
        Long adminId = Long.valueOf(request.getSession(false).getAttribute("userId").toString());

        Loan loan = session.find(Loan.class, loanId);
        if (loan == null) throw new IllegalArgumentException("Loan not found");

        User admin = session.find(User.class, adminId);
        loan.approve(admin, comment);
        session.merge(loan);

        createAuditLog(session, admin, "LOAN_APPROVE", "Loan " + loan.getLoanReference() + " was approved");

        // Send notification to member
        sendLoanNotification(session, loan.getMember(), "Loan Approved",
                "Your loan application " + loan.getLoanReference() + " has been approved. Amount: KES " + loan.getTotalRepayable());
    }

    private void rejectLoan(HttpServletRequest request, Session session) {
        Long loanId = Long.valueOf(request.getParameter("loanId"));
        String comment = request.getParameter("comment");
        Long adminId = Long.valueOf(request.getSession(false).getAttribute("userId").toString());

        Loan loan = session.find(Loan.class, loanId);
        if (loan == null) throw new IllegalArgumentException("Loan not found");

        User admin = session.find(User.class, adminId);
        loan.reject(admin, comment);
        session.merge(loan);

        createAuditLog(session, admin, "LOAN_REJECT", "Loan " + loan.getLoanReference() + " was rejected");

        // Send notification to member
        sendLoanNotification(session, loan.getMember(), "Loan Rejected",
                "Your loan application " + loan.getLoanReference() + " has been rejected. Reason: " + comment);
    }

    private void updateInterestRate(HttpServletRequest request, Session session) {
        Long accountId = Long.valueOf(request.getParameter("accountId"));
        BigDecimal newRate = new BigDecimal(request.getParameter("interestRate"));

        SavingsAccount account = session.find(SavingsAccount.class, accountId);
        if (account == null) throw new IllegalArgumentException("Account not found");

        account.setInterestRate(newRate.setScale(2, BigDecimal.ROUND_HALF_UP));
        session.merge(account);

        createAuditLog(session, null, "RATE_UPDATE", "Interest rate updated to " + newRate + "% for account " + account.getAccountNumber());
    }

    private void sendNotification(HttpServletRequest request, Session session) {
        String title = request.getParameter("title");
        String message = request.getParameter("message");
        String recipientType = request.getParameter("recipientType");
        Long recipientId = request.getParameter("recipientId") != null ? Long.valueOf(request.getParameter("recipientId")) : null;

        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setRecipientType(Notification.RecipientType.valueOf(recipientType));
        notification.setRead(false);
        notification.setCreatedAt(LocalDateTime.now());

        if (recipientId != null) {
            User recipient = session.find(User.class, recipientId);
            notification.setRecipient(recipient);
        }

        session.persist(notification);
    }

    private void sendOverdueNotifications(HttpServletRequest request, Session session) {
        LocalDateTime now = LocalDateTime.now();
        List<Loan> overdueLoans = session.createQuery(
                "select l from Loan l join fetch l.member where l.status = :status and l.dueDate < :now",
                Loan.class)
                .setParameter("status", LoanStatus.APPROVED)
                .setParameter("now", now)
                .list();

        int sentCount = 0;
        for (Loan loan : overdueLoans) {
            long daysOverdue = ChronoUnit.DAYS.between(loan.getDueDate(), now);
            sendLoanNotification(session, loan.getMember(),
                    "Overdue Loan Alert",
                    "Your loan " + loan.getLoanReference() + " is " + daysOverdue + " days overdue. Outstanding balance: KES " + loan.getOutstandingBalance());
            sentCount++;
        }

        createAuditLog(session, null, "OVERDUE_NOTIFICATIONS", "Sent overdue notifications to " + sentCount + " members");
    }

    private void sendLoanNotification(Session session, User member, String title, String message) {
        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setRecipient(member);
        notification.setRecipientType(Notification.RecipientType.MEMBER);
        notification.setRead(false);
        notification.setCreatedAt(LocalDateTime.now());
        session.persist(notification);
    }

    private void createAuditLog(Session session, User user, String action, String details) {
        AuditLog log = new AuditLog();
        log.setUser(user);
        log.setAction(action);
        log.setDetails(details);
        log.setTimestamp(LocalDateTime.now());
        log.setIpAddress(getClientIpAddress());
        session.persist(log);
    }
    
    private void getMember(HttpServletRequest request, Session session) {
        String memberId = request.getParameter("memberId");
        if (memberId != null && !memberId.isEmpty()) {
            User member = session.find(User.class, Long.valueOf(memberId));
            if (member != null) {
                request.setAttribute("editMember", member);
            }
        }
    }
    
    private void generateReport(HttpServletRequest request, Session session, HttpServletResponse response) throws IOException {
        String reportType = request.getParameter("reportType");
        
        // Generate report content
        StringBuilder reportContent = new StringBuilder();
        reportContent.append("Kimwanyi SACCO - Financial Report\n");
        reportContent.append("Generated: ").append(LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("MMMM dd, yyyy HH:mm"))).append("\n\n");
        
        if ("savings".equals(reportType)) {
            reportContent.append("=== SAVINGS REPORT ===\n\n");
            BigDecimal totalSavings = session.createQuery("select sum(sa.balance) from SavingsAccount sa where sa.status = :status", BigDecimal.class)
                    .setParameter("status", SavingsStatus.ACTIVE)
                    .uniqueResult();
            if (totalSavings == null) totalSavings = BigDecimal.ZERO;
            reportContent.append("Total Savings: KES ").append(totalSavings).append("\n");
            
            List<SavingsAccount> accounts = session.createQuery("from SavingsAccount", SavingsAccount.class).list();
            reportContent.append("Total Accounts: ").append(accounts.size()).append("\n\n");
            reportContent.append("Account Details:\n");
            for (SavingsAccount account : accounts) {
                reportContent.append("- ").append(account.getAccountNumber())
                    .append(": KES ").append(account.getBalance())
                    .append(" (").append(account.getMember().getFullName()).append(")\n");
            }
        } else if ("loans".equals(reportType)) {
            reportContent.append("=== LOANS REPORT ===\n\n");
            Long totalLoans = session.createQuery("select count(l) from Loan l where l.status = :status", Long.class)
                    .setParameter("status", LoanStatus.APPROVED)
                    .uniqueResult();
            reportContent.append("Active Loans: ").append(totalLoans).append("\n");
            
            BigDecimal totalLoanAmount = session.createQuery("select sum(l.outstandingBalance) from Loan l where l.status = :status", BigDecimal.class)
                    .setParameter("status", LoanStatus.APPROVED)
                    .uniqueResult();
            if (totalLoanAmount == null) totalLoanAmount = BigDecimal.ZERO;
            reportContent.append("Total Outstanding: KES ").append(totalLoanAmount).append("\n");
        } else if ("members".equals(reportType)) {
            reportContent.append("=== MEMBERS REPORT ===\n\n");
            Long totalMembers = session.createQuery("select count(u) from User u where u.role = :role", Long.class)
                    .setParameter("role", UserRole.MEMBER)
                    .uniqueResult();
            reportContent.append("Total Members: ").append(totalMembers).append("\n");
            
            List<User> members = session.createQuery("from User where role = :role", User.class)
                    .setParameter("role", UserRole.MEMBER)
                    .list();
            reportContent.append("\nMember Details:\n");
            for (User member : members) {
                reportContent.append("- ").append(member.getFullName())
                    .append(" (").append(member.getEmail()).append(")\n");
            }
        }
        
        // Set response headers for file download
        response.setContentType("text/plain");
        response.setHeader("Content-Disposition", "attachment; filename=" + reportType + "-report.txt");
        response.getWriter().write(reportContent.toString());
    }

    private void approveCashPayment(HttpServletRequest request, Session session) {
        Long loanId = Long.valueOf(request.getParameter("loanId"));
        String notes = request.getParameter("notes");
        Long adminId = Long.valueOf(request.getSession(false).getAttribute("userId").toString());

        Loan loan = session.find(Loan.class, loanId);
        if (loan == null) throw new IllegalArgumentException("Loan not found");

        User admin = session.find(User.class, adminId);
        
        // Get the outstanding balance to repay
        BigDecimal outstandingBalance = loan.getOutstandingBalance();
        if (outstandingBalance == null || outstandingBalance.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Loan has no outstanding balance to repay.");
        }

        // Create payment record for cash payment
        Payment payment = new Payment(loan, loan.getMember(), outstandingBalance, PaymentMethod.CASH, "CASH-" + System.currentTimeMillis());
        payment.setNotes(notes != null ? notes : "Cash payment approved by admin");
        session.persist(payment);

        // Apply the repayment
        loan.repay(outstandingBalance);
        session.merge(loan);

        createAuditLog(session, admin, "CASH_PAYMENT_APPROVED", 
            "Cash payment of KES " + outstandingBalance + " approved for loan " + loan.getLoanReference());

        // Send notification to member
        sendLoanNotification(session, loan.getMember(), "Cash Payment Received",
            "Your cash payment of KES " + outstandingBalance + " for loan " + loan.getLoanReference() + " has been received. " +
            (loan.getStatus() == LoanStatus.REPAID ? "Loan fully repaid!" : "Remaining balance: KES " + loan.getOutstandingBalance()));
    }

    private void changeLoanStatus(HttpServletRequest request, Session session) {
        Long loanId = Long.valueOf(request.getParameter("loanId"));
        String newStatusStr = request.getParameter("newStatus");
        String comment = request.getParameter("comment");
        Long adminId = Long.valueOf(request.getSession(false).getAttribute("userId").toString());

        Loan loan = session.find(Loan.class, loanId);
        if (loan == null) throw new IllegalArgumentException("Loan not found");

        User admin = session.find(User.class, adminId);
        
        // Parse the new status
        LoanStatus newStatus;
        try {
            newStatus = LoanStatus.valueOf(newStatusStr);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid loan status: " + newStatusStr);
        }

        // Validate status transition
        LoanStatus currentStatus = loan.getStatus();
        if (currentStatus == newStatus) {
            throw new IllegalArgumentException("Loan is already in " + newStatus + " status.");
        }

        // Business rules for status changes
        if (newStatus == LoanStatus.APPROVED && currentStatus != LoanStatus.PENDING) {
            throw new IllegalStateException("Only pending loans can be approved.");
        }
        if (newStatus == LoanStatus.REJECTED && currentStatus != LoanStatus.PENDING) {
            throw new IllegalStateException("Only pending loans can be rejected.");
        }
        if (newStatus == LoanStatus.CANCELLED && currentStatus != LoanStatus.PENDING && currentStatus != LoanStatus.APPROVED) {
            throw new IllegalStateException("Only pending or approved loans can be cancelled.");
        }
        if (newStatus == LoanStatus.OVERDUE && currentStatus != LoanStatus.APPROVED) {
            throw new IllegalStateException("Only approved loans can be marked as overdue.");
        }
        if (newStatus == LoanStatus.REPAID && currentStatus != LoanStatus.APPROVED && currentStatus != LoanStatus.OVERDUE) {
            throw new IllegalStateException("Only approved or overdue loans can be marked as repaid.");
        }

        // Update loan status
        loan.setStatus(newStatus);
        
        // If moving to repaid, ensure outstanding balance is zero
        if (newStatus == LoanStatus.REPAID) {
            loan.setOutstandingBalance(BigDecimal.ZERO);
        }

        session.merge(loan);

        String actionType = "LOAN_STATUS_CHANGE";
        String details = "Loan " + loan.getLoanReference() + " status changed from " + currentStatus + " to " + newStatus;
        if (comment != null && !comment.isBlank()) {
            details += ". Comment: " + comment;
        }
        createAuditLog(session, admin, actionType, details);

        // Send notification to member
        String notificationTitle = "Loan Status Updated";
        String notificationMessage = "Your loan " + loan.getLoanReference() + " status has been updated to " + newStatus + ".";
        if (comment != null && !comment.isBlank()) {
            notificationMessage += " Comment: " + comment;
        }
        sendLoanNotification(session, loan.getMember(), notificationTitle, notificationMessage);
    }

    private String getClientIpAddress() {
        // This would typically get the IP from the request
        return "127.0.0.1";
    }
}
