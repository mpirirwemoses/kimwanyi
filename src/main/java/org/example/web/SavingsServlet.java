package org.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.config.HibernateUtil;
import org.example.model.SavingsAccount;
import org.example.model.SavingsStatus;
import org.example.model.SavingsTransaction;
import org.example.model.TransactionType;
import org.example.model.User;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@WebServlet("/savings")
public class SavingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        Long userId = sessionUserId(request);
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        
        String action = request.getParameter("action");
        boolean admin = isAdmin(request);
        
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.find(User.class, userId);
            
            if (admin) {
                // Admin view - show all savings accounts
                List<SavingsAccount> accounts = session.createQuery(
                    "select sa from SavingsAccount sa join fetch sa.member order by sa.createdAt desc", 
                    SavingsAccount.class).list();
                request.setAttribute("accounts", accounts);
                
                // Get summary statistics
                BigDecimal totalSavings = session.createQuery(
                    "select sum(sa.balance) from SavingsAccount sa where sa.status = :status", BigDecimal.class)
                    .setParameter("status", SavingsStatus.ACTIVE)
                    .uniqueResult();
                if (totalSavings == null) totalSavings = BigDecimal.ZERO;
                request.setAttribute("totalSavings", totalSavings);
                
                Long totalMembers = session.createQuery(
                    "select count(sa) from SavingsAccount sa where sa.status = :status", Long.class)
                    .setParameter("status", SavingsStatus.ACTIVE)
                    .uniqueResult();
                if (totalMembers == null) totalMembers = 0L;
                request.setAttribute("totalMembers", totalMembers);
                
                request.getRequestDispatcher("/WEB-INF/views/admin-savings.jsp").forward(request, response);
            } else {
                // Member view - handle multiple accounts
                List<SavingsAccount> allAccounts = session.createQuery(
                    "select sa from SavingsAccount sa where sa.member.id = :memberId order by sa.createdAt desc", 
                    SavingsAccount.class)
                    .setParameter("memberId", userId)
                    .list();
                
                // Get selected account ID from parameter or session
                Long selectedAccountId = null;
                String accountIdParam = request.getParameter("accountId");
                if (accountIdParam != null && !accountIdParam.isEmpty()) {
                    try {
                        selectedAccountId = Long.valueOf(accountIdParam);
                    } catch (NumberFormatException e) {
                        // Invalid account ID, will use default
                    }
                }
                
                // If no valid selection, use first account or session default
                if (selectedAccountId == null) {
                    Object sessionAccountId = request.getSession(false).getAttribute("selectedSavingsAccountId");
                    if (sessionAccountId instanceof Long) {
                        selectedAccountId = (Long) sessionAccountId;
                    }
                }
                
                // Validate selected account belongs to user
                SavingsAccount selectedAccount = null;
                if (selectedAccountId != null) {
                    for (SavingsAccount acc : allAccounts) {
                        if (acc.getId().equals(selectedAccountId)) {
                            selectedAccount = acc;
                            break;
                        }
                    }
                }
                
                // Default to first account if none selected
                if (selectedAccount == null && !allAccounts.isEmpty()) {
                    selectedAccount = allAccounts.get(0);
                    selectedAccountId = selectedAccount.getId();
                }
                
                // Store selected account in session
                if (selectedAccountId != null) {
                    request.getSession(false).setAttribute("selectedSavingsAccountId", selectedAccountId);
                }
                
                // Create account if none exist
                if (allAccounts.isEmpty()) {
                    SavingsAccount newAccount = createSavingsAccount(session, user);
                    allAccounts.add(newAccount);
                    selectedAccount = newAccount;
                    selectedAccountId = newAccount.getId();
                    request.getSession(false).setAttribute("selectedSavingsAccountId", selectedAccountId);
                }
                
                // Automatically calculate and apply interest if it's been a month
                if (selectedAccount != null) {
                    LocalDateTime lastCalc = selectedAccount.getLastInterestCalculation();
                    long daysSinceLastCalc = java.time.temporal.ChronoUnit.DAYS.between(lastCalc, LocalDateTime.now());
                    
                    if (daysSinceLastCalc >= 30 && selectedAccount.getBalance().compareTo(BigDecimal.ZERO) > 0) {
                        // Auto-apply interest
                        BigDecimal balanceBefore = selectedAccount.getBalance();
                        selectedAccount.applyInterest();
                        BigDecimal interest = selectedAccount.getBalance().subtract(balanceBefore);
                        
                        if (interest.compareTo(BigDecimal.ZERO) > 0) {
                            SavingsTransaction tx = new SavingsTransaction(
                                selectedAccount, user, TransactionType.INTEREST, interest,
                                balanceBefore, selectedAccount.getBalance(), generateReference("INT")
                            );
                            tx.setNotes("Automatic monthly interest");
                            session.persist(tx);
                        }
                        session.merge(selectedAccount);
                    }
                }
                
                // Get transaction history for selected account
                List<SavingsTransaction> transactions = null;
                if (selectedAccount != null) {
                    transactions = session.createQuery(
                        "select st from SavingsTransaction st where st.savingsAccount.id = :accountId " +
                        "order by st.transactionDate desc", SavingsTransaction.class)
                        .setParameter("accountId", selectedAccount.getId())
                        .setMaxResults(50)
                        .list();
                }
                
                request.setAttribute("allAccounts", allAccounts);
                request.setAttribute("account", selectedAccount);
                request.setAttribute("transactions", transactions != null ? transactions : List.of());
                
                if ("statement".equals(action)) {
                    request.setAttribute("statementDate", java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("MMMM dd, yyyy HH:mm")));
                    request.getRequestDispatcher("/WEB-INF/views/savings-statement.jsp").forward(request, response);
                } else if ("deposit".equals(action)) {
                    request.getRequestDispatcher("/WEB-INF/views/savings-deposit.jsp").forward(request, response);
                } else if ("withdraw".equals(action)) {
                    request.getRequestDispatcher("/WEB-INF/views/savings-withdraw.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("/WEB-INF/views/member-savings.jsp").forward(request, response);
                }
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        Long userId = sessionUserId(request);
        if (userId == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        
        String action = request.getParameter("action");
        
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = session.find(User.class, userId);
            if (user == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
            
            Transaction transaction = session.beginTransaction();
            
            String viewPath;
            if (isAdmin(request)) {
                viewPath = adminAction(session, user, action, request);
            } else {
                viewPath = memberAction(session, user, action, request);
            }
            
            transaction.commit();
            
            // If a view path is returned, forward to it (for calculate-interest)
            if (viewPath != null) {
                request.getRequestDispatcher(viewPath).forward(request, response);
                return;
            }
            
            response.sendRedirect(request.getContextPath() + "/savings?message=success");
        } catch (IllegalArgumentException | IllegalStateException exception) {
            response.sendRedirect(request.getContextPath() + "/savings?error=" + exception.getMessage().replace(' ', '+'));
        }
    }

    private String memberAction(Session session, User member, String action, HttpServletRequest request) {
        // Get selected account ID from parameter or session
        Long accountId = null;
        String accountIdParam = request.getParameter("accountId");
        if (accountIdParam != null && !accountIdParam.isEmpty()) {
            try {
                accountId = Long.valueOf(accountIdParam);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Invalid account selected.");
            }
        }
        
        if (accountId == null) {
            Object sessionAccountId = request.getSession(false).getAttribute("selectedSavingsAccountId");
            if (sessionAccountId instanceof Long) {
                accountId = (Long) sessionAccountId;
            }
        }
        
        if (accountId == null) {
            throw new IllegalArgumentException("No account selected. Please select an account first.");
        }
        
        SavingsAccount account = session.find(SavingsAccount.class, accountId);
        if (account == null || !account.getMember().getId().equals(member.getId())) {
            throw new IllegalArgumentException("Account not found or access denied.");
        }
        
        if ("deposit".equals(action)) {
            BigDecimal amount = amount(request);
            BigDecimal balanceBefore = account.getBalance();
            account.deposit(amount);
            BigDecimal balanceAfter = account.getBalance();
            
            SavingsTransaction tx = new SavingsTransaction(
                account, member, TransactionType.DEPOSIT, amount, 
                balanceBefore, balanceAfter, generateReference("DEP")
            );
            tx.setTransactionId(value(request, "transactionId"));
            tx.setCardLastFour(value(request, "cardLastFour"));
            tx.setNotes(value(request, "notes"));
            session.persist(tx);
            session.merge(account);
            
        } else if ("withdraw".equals(action)) {
            BigDecimal amount = amount(request);
            
            // Validate minimum balance after withdrawal
            BigDecimal balanceAfterWithdrawal = account.getBalance().subtract(amount);
            if (balanceAfterWithdrawal.compareTo(account.getMinimumBalance()) < 0) {
                throw new IllegalArgumentException("Withdrawal would violate minimum balance requirement of KES " + account.getMinimumBalance() + 
                    ". Maximum withdrawable: KES " + account.getBalance().subtract(account.getMinimumBalance()));
            }
            
            // Validate daily withdrawal limit
            LocalDateTime today = LocalDateTime.now().truncatedTo(ChronoUnit.DAYS);
            LocalDateTime lastWithdrawal = account.getLastWithdrawalDate().truncatedTo(ChronoUnit.DAYS);
            
            BigDecimal dailyAmount = account.getDailyWithdrawalAmount();
            if (!today.equals(lastWithdrawal)) {
                // Reset daily amount if it's a new day
                dailyAmount = BigDecimal.ZERO;
            }
            
            if (dailyAmount.add(amount).compareTo(account.getDailyWithdrawalLimit()) > 0) {
                throw new IllegalArgumentException("Daily withdrawal limit exceeded. Remaining: KES " + 
                    account.getDailyWithdrawalLimit().subtract(dailyAmount));
            }
            
            BigDecimal balanceBefore = account.getBalance();
            account.withdraw(amount);
            BigDecimal balanceAfter = account.getBalance();
            
            // Update daily withdrawal tracking
            account.setDailyWithdrawalAmount(dailyAmount.add(amount));
            account.setLastWithdrawalDate(LocalDateTime.now());
            
            SavingsTransaction tx = new SavingsTransaction(
                account, member, TransactionType.WITHDRAWAL, amount, 
                balanceBefore, balanceAfter, generateReference("WTH")
            );
            tx.setTransactionId(value(request, "transactionId"));
            tx.setCardLastFour(value(request, "cardLastFour"));
            tx.setNotes(value(request, "notes"));
            session.persist(tx);
            session.merge(account);
            
        } else if ("calculate-interest".equals(action)) {
            // Calculate interest for display purposes only - do not apply
            BigDecimal calculatedInterest = account.calculateInterest();
            BigDecimal currentBalance = account.getBalance();
            BigDecimal projectedBalance = currentBalance.add(calculatedInterest);
            
            // Store calculation details in request for display
            request.setAttribute("calculatedInterest", calculatedInterest);
            request.setAttribute("currentBalance", currentBalance);
            request.setAttribute("projectedBalance", projectedBalance);
            request.setAttribute("interestRate", account.getInterestRate());
            request.setAttribute("lastInterestCalculation", account.getLastInterestCalculation());
            request.setAttribute("account", account);
            
            return "/WEB-INF/views/interest-calculation.jsp";
        } else if ("change-account-number".equals(action)) {
            String newAccountNumber = value(request, "newAccountNumber");
            if (newAccountNumber == null || newAccountNumber.trim().isEmpty()) {
                throw new IllegalArgumentException("Account number cannot be empty.");
            }
            if (newAccountNumber.length() > 30) {
                throw new IllegalArgumentException("Account number must be 30 characters or less.");
            }
            account.setAccountNumber(newAccountNumber.trim());
            session.merge(account);
        } else {
            throw new IllegalArgumentException("Unknown savings action.");
        }
        return null;
    }

    private String adminAction(Session session, User admin, String action, HttpServletRequest request) {
        // Admin can adjust interest rates or close accounts
        if ("update-rate".equals(action)) {
            Long accountId = id(request);
            SavingsAccount account = session.find(SavingsAccount.class, accountId);
            if (account == null) throw new IllegalArgumentException("Account not found.");
            
            BigDecimal newRate = new BigDecimal(value(request, "interestRate"));
            if (newRate.compareTo(BigDecimal.ZERO) <= 0 || newRate.compareTo(new BigDecimal("100")) > 0) {
                throw new IllegalArgumentException("Interest rate must be between 0 and 100.");
            }
            account.setInterestRate(newRate.setScale(2, BigDecimal.ROUND_HALF_UP));
            session.merge(account);
        } else if ("close-account".equals(action)) {
            Long accountId = id(request);
            SavingsAccount account = session.find(SavingsAccount.class, accountId);
            if (account == null) throw new IllegalArgumentException("Account not found.");
            
            account.setStatus(SavingsStatus.CLOSED);
            session.merge(account);
        } else {
            throw new IllegalArgumentException("Unknown admin action.");
        }
        return null;
    }

    private SavingsAccount createSavingsAccount(Session session, User member) {
        String accountNumber = generateAccountNumber(member);
        SavingsAccount account = new SavingsAccount(member, accountNumber);
        session.persist(account);
        return account;
    }

    private String generateAccountNumber(User member) {
        return "SAV-" + String.format("%06d", member.getId()) + "-" + System.currentTimeMillis() % 10000;
    }

    private String generateReference(String prefix) {
        return prefix + "-" + System.currentTimeMillis();
    }

    private BigDecimal amount(HttpServletRequest request) {
        try {
            BigDecimal amount = new BigDecimal(value(request, "amount"));
            if (amount.signum() <= 0) throw new IllegalArgumentException("Amount must be greater than zero.");
            if (amount.scale() > 2) throw new IllegalArgumentException("Amount cannot have more than 2 decimal places.");
            return amount.setScale(2, BigDecimal.ROUND_HALF_UP);
        } catch (NumberFormatException exception) { 
            throw new IllegalArgumentException("Enter a valid amount."); 
        }
    }

    private Long id(HttpServletRequest request) {
        try { return Long.valueOf(request.getParameter("accountId")); }
        catch (NumberFormatException exception) { throw new IllegalArgumentException("Invalid account."); }
    }

    private Long sessionUserId(HttpServletRequest request) {
        Object value = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
        return value instanceof Long id ? id : null;
    }

    private boolean isAdmin(HttpServletRequest request) {
        return "ADMIN".equals(request.getSession(false).getAttribute("userRole"));
    }

    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }
}