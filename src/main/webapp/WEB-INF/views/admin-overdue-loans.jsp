<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.example.model.Loan" %>
<%@ page import="org.example.model.LoanStatus" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%
    java.util.List<Loan> overdueLoans = (java.util.List<Loan>) request.getAttribute("overdueLoans");
    java.time.LocalDateTime now = java.time.LocalDateTime.now();
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Overdue Loans | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
    <style>
        .loan-grid { display: grid; gap: 18px; margin-top: 24px; }
        .loan-card { padding: 22px; background: var(--surface); border: 1px solid var(--line); border-radius: 14px; }
        .loan-card h3 { margin: 0 0 10px; font-size: 1.05rem; }
        .loan-meta { display: grid; gap: 6px; color: var(--muted); font-size: .92rem; }
        .loan-meta strong { color: var(--ink); }
        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 6px; font-size: .82rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
        .status-overdue { background: #f8d7da; color: #721c24; }
        .loan-actions { margin-top: 16px; display: flex; gap: 10px; flex-wrap: wrap; }
        .loan-actions form { display: inline; margin: 0; }
        .empty-state { padding: 40px 0; text-align: center; border-top: 1px solid var(--line); }
        .days-overdue { background: #fff3cd; color: #856404; padding: 8px 14px; border-radius: 6px; font-weight: 700; display: inline-block; margin-top: 8px; }
        .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.45); display: none; align-items: center; justify-content: center; padding: 24px; z-index: 100; }
        .modal-overlay.open { display: flex; }
        .modal { background: var(--surface); border: 1px solid var(--line); border-radius: 14px; padding: 28px; width: min(100%, 520px); }
        .modal h2 { margin: 0 0 18px; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 18px; }
    </style>
</head>
<body class="dashboard-body">
<div class="dashboard-shell">
    <header class="topbar">
        <a class="brand" href="<%= request.getContextPath() %>/dashboard">Credit SACCO <span>Admin</span></a>
        <form method="post" action="<%= request.getContextPath() %>/logout">
            <button class="button secondary" type="submit">Log out</button>
        </form>
    </header>

    <main class="dashboard-content">
        <section class="welcome-panel">
            <p class="eyebrow">Administration</p>
            <h1>Overdue Loans</h1>
            <p>Monitor and manage loans that have passed their due date.</p>
        </section>

        <section class="content-grid">
            <article class="panel">
                <div class="panel-heading">
                    <div><p class="eyebrow">Overdue</p><h2>Overdue Loans</h2></div>
                </div>

                <% if (request.getParameter("error") != null) { %>
                    <p class="message" role="alert"><%= request.getParameter("error") %></p>
                <% } else if (request.getParameter("message") != null) { %>
                    <p class="message success" role="status">Operation completed successfully.</p>
                <% } %>

                <%
                    if (overdueLoans == null || overdueLoans.isEmpty()) {
                %>
                    <div class="empty-state">
                        <h3>No overdue loans</h3>
                        <p>All loans are being repaid on time. Great job!</p>
                    </div>
                <%
                    } else {
                %>
                    <div class="loan-grid">
                        <%
                            for (Loan loan : overdueLoans) {
                                long daysOverdue = ChronoUnit.DAYS.between(loan.getDueDate(), now);
                                BigDecimal outstanding = loan.getOutstandingBalance();
                        %>
                        <div class="loan-card">
                            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px;">
                                <h3>Loan #<%= loan.getId() %> - <%= loan.getMember().getFullName() %></h3>
                                <span class="status-badge status-overdue"><%= loan.getStatus() %></span>
                            </div>
                            <div class="loan-meta">
                                <div>Member: <strong><%= loan.getMember().getFullName() %> (<%= loan.getMember().getEmail() %>)</strong></div>
                                <div>Loan Reference: <strong><%= loan.getLoanReference() %></strong></div>
                                <div>Requested amount: <strong>UGX <%= loan.getRequestedAmount() %></strong></div>
                                <div>Purpose: <strong><%= loan.getPurpose() %></strong></div>
                                <div>Applied on: <strong><%= loan.getAppliedAtFormatted() %></strong></div>
                                <div>Due date: <strong><%= loan.getDueDateFormatted() %></strong></div>
                                <% if (loan.getTotalRepayable() != null) { %>
                                    <div>Total repayable: <strong>UGX <%= loan.getTotalRepayable() %></strong></div>
                                <% } %>
                                <% if (outstanding != null) { %>
                                    <div>Outstanding balance: <strong>UGX <%= outstanding %></strong></div>
                                <% } %>
                                <div class="days-overdue">⚠️ <%= daysOverdue %> days overdue</div>
                            </div>
                            <div class="loan-actions">
                                <a href="<%= request.getContextPath() %>/admin-dashboard?section=loans&action=view&id=<%= loan.getId() %>" class="button secondary">View Details</a>
                                <form method="post" action="<%= request.getContextPath() %>/admin-dashboard" style="display: inline;" onsubmit="return confirm('Record cash payment for this loan?')">
                                    <input type="hidden" name="action" value="approve-cash-payment">
                                    <input type="hidden" name="loanId" value="<%= loan.getId() %>">
                                    <input type="hidden" name="section" value="overdue">
                                    <button type="submit" class="button">💰 Approve Cash Payment</button>
                                </form>
                            </div>
                        </div>
                        <%
                            }
                        %>
                    </div>
                <%
                    }
                %>
            </article>
        </section>
    </main>
</div>

<script>
    function openModal(id) { document.getElementById(id).classList.add('open'); }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); }
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(overlay.id); });
    });
</script>
</body>
</html>