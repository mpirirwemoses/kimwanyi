<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.example.model.Payment" %>
<%@ page import="org.example.model.PaymentMethod" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment History | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
    <style>
        .history-container { max-width: 1000px; margin: 0 auto; padding: 40px 24px; }
        .page-header { margin-bottom: 32px; }
        .page-header h1 { font-size: 1.85rem; margin-bottom: 8px; }
        .page-header p { color: var(--muted); margin: 0; }
        .summary-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 18px; margin-bottom: 32px; }
        .summary-card { background: #fff; padding: 24px; border-radius: 14px; border: 1px solid var(--line); }
        .summary-label { color: var(--muted); font-size: .85rem; font-weight: 700; margin-bottom: 8px; }
        .summary-value { font-size: 1.75rem; font-weight: 800; color: var(--ink); }
        .payments-table { background: #fff; border-radius: 14px; border: 1px solid var(--line); overflow: hidden; }
        .table-header { padding: 20px 24px; border-bottom: 1px solid var(--line); }
        .table-header h2 { margin: 0; font-size: 1.15rem; }
        .table-responsive { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        th { background: var(--background); padding: 14px 24px; text-align: left; font-size: .82rem; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .05em; }
        td { padding: 16px 24px; border-top: 1px solid var(--line); font-size: .92rem; }
        tr:hover { background: #fafbfa; }
        .method-badge { display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; border-radius: 6px; font-size: .82rem; font-weight: 600; }
        .method-mpesa { background: #e8f5ed; color: #0f5936; }
        .method-card { background: #e3f2fd; color: #1565c0; }
        .method-bank { background: #fff3e0; color: #e65100; }
        .method-cash { background: #f3e5f5; color: #7b1fa2; }
        .amount { font-weight: 700; color: var(--ink); }
        .txn-id { font-family: monospace; font-size: .85rem; color: var(--muted); }
        .date { color: var(--muted); font-size: .88rem; }
        .empty-state { text-align: center; padding: 60px 24px; }
        .empty-state svg { width: 80px; height: 80px; color: var(--line); margin-bottom: 16px; }
        .empty-state h3 { margin: 0 0 8px; font-size: 1.15rem; }
        .empty-state p { color: var(--muted); margin: 0; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; color: var(--primary); text-decoration: none; font-weight: 600; margin-bottom: 20px; }
        .back-link:hover { text-decoration: underline; }
        @media (max-width: 768px) {
            .history-container { padding: 20px 16px; }
            th, td { padding: 12px 16px; }
        }
    </style>
</head>
<body>
    <div class="history-container">
        <a href="<%= request.getContextPath() %>/dashboard" class="back-link">
            <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            Back to Dashboard
        </a>

        <div class="page-header">
            <h1>Payment History</h1>
            <p>Track all your loan repayments and transactions</p>
        </div>

        <%
            java.util.List<Payment> payments = (java.util.List<Payment>) request.getAttribute("payments");
            BigDecimal totalPaid = BigDecimal.ZERO;
            BigDecimal thisMonth = BigDecimal.ZERO;
            int paymentCount = payments != null ? payments.size() : 0;
            
            if (payments != null) {
                for (Payment payment : payments) {
                    totalPaid = totalPaid.add(payment.getAmount());
                }
            }
        %>

        <div class="summary-cards">
            <div class="summary-card">
                <div class="summary-label">Total Payments</div>
                <div class="summary-value"><%= paymentCount %></div>
            </div>
            <div class="summary-card">
                <div class="summary-label">Total Amount Paid</div>
                <div class="summary-value">KES <%= java.text.NumberFormat.getNumberInstance().format(totalPaid) %></div>
            </div>
            <div class="summary-card">
                <div class="summary-label">Average Payment</div>
                <div class="summary-value">KES <%= java.text.NumberFormat.getNumberInstance().format(paymentCount > 0 ? totalPaid.divide(new BigDecimal(paymentCount), 2, BigDecimal.ROUND_HALF_UP) : BigDecimal.ZERO) %></div>
            </div>
        </div>

        <div class="payments-table">
            <div class="table-header">
                <h2>All Transactions</h2>
            </div>
            <div class="table-responsive">
                <%
                    if (payments == null || payments.isEmpty()) {
                %>
                    <div class="empty-state">
                        <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>
                        <h3>No payments yet</h3>
                        <p>Your payment history will appear here once you make your first repayment.</p>
                    </div>
                <%
                    } else {
                %>
                    <table>
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Transaction ID</th>
                                <th>Loan Reference</th>
                                <th>Method</th>
                                <th>Amount</th>
                                <th>Notes</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
                                for (Payment payment : payments) {
                                    PaymentMethod pm = payment.getPaymentMethod();
                                    String methodClass = "method-mpesa";
                                    String methodIcon = "📱";
                                    String methodLabel = "-";
                                    if (pm == null) { methodClass = ""; methodIcon = ""; methodLabel = "-"; }
                                    else if (pm == PaymentMethod.CARD) { methodClass = "method-card"; methodIcon = "💳"; methodLabel = pm.name(); }
                                    else if (pm == PaymentMethod.BANK_TRANSFER) { methodClass = "method-bank"; methodIcon = "🏦"; methodLabel = pm.name(); }
                                    else if (pm == PaymentMethod.CASH) { methodClass = "method-cash"; methodIcon = "💵"; methodLabel = pm.name(); }
                                    else { methodLabel = pm.name(); }
                            %>
                                <tr>
                                    <td class="date"><%= payment.getPaymentDate() != null ? payment.getPaymentDateFormatted() : "-" %></td>
                                    <td class="txn-id"><%= payment.getTransactionId() %></td>
                                    <td><%= payment.getLoan() != null ? payment.getLoan().getLoanReference() : "-" %></td>
                                    <td>
                                        <span class="method-badge <%= methodClass %>">
                                            <%= methodIcon %> <%= methodLabel %>
                                        </span>
                                    </td>
                                    <td class="amount">KES <%= payment.getAmount() %></td>
                                    <td><%= payment.getNotes() != null && !payment.getNotes().isEmpty() ? payment.getNotes() : "-" %></td>
                                </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                <%
                    }
                %>
            </div>
        </div>
    </div>
</body>
</html>