<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.example.model.Loan" %>
<%@ page import="org.example.model.LoanStatus" %>
<%@ page import="java.math.BigDecimal" %>
<%!
    public static String escapeJs(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("\\", "\\\\")
                   .replace("'", "\\'")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "");
    }
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Loans | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
    <style>
        .loan-grid { display: grid; gap: 18px; margin-top: 24px; }
        .loan-card { padding: 22px; background: var(--surface); border: 1px solid var(--line); border-radius: 14px; }
        .loan-card h3 { margin: 0 0 10px; font-size: 1.05rem; }
        .loan-meta { display: grid; gap: 6px; color: var(--muted); font-size: .92rem; }
        .loan-meta strong { color: var(--ink); }
        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 6px; font-size: .82rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d1e7dd; color: #0f5132; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        .status-cancelled { background: #e2e3e5; color: #41464b; }
        .status-repaid { background: #d1e7dd; color: #0f5132; }
        .status-overdue { background: #f8d7da; color: #721c24; }
        .loan-actions { margin-top: 16px; display: flex; gap: 10px; flex-wrap: wrap; }
        .loan-actions form { display: inline; margin: 0; }
        .empty-state { padding: 40px 0; text-align: center; border-top: 1px solid var(--line); }
        .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.45); display: none; align-items: center; justify-content: center; padding: 24px; z-index: 100; }
        .modal-overlay.open { display: flex; }
        .modal { background: var(--surface); border: 1px solid var(--line); border-radius: 14px; padding: 28px; width: min(100%, 520px); }
        .modal h2 { margin: 0 0 18px; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 18px; }
        .repayment-info { background: #f8f9fa; padding: 14px; border-radius: 8px; margin: 12px 0; font-size: .92rem; }
    </style>
</head>
<body class="dashboard-body">
<div class="dashboard-shell">
    <header class="topbar">
        <a class="brand" href="<%= request.getContextPath() %>/dashboard">Credit SACCO</a>
        <form method="post" action="<%= request.getContextPath() %>/logout">
            <button class="button secondary" type="submit">Log out</button>
        </form>
    </header>

    <main class="dashboard-content">
        <section class="welcome-panel">
            <p class="eyebrow">Member services</p>
            <h1>My Loans</h1>
            <p>Apply for a new loan, track your applications, and manage repayments.</p>
        </section>

        <section class="content-grid">
            <article class="panel">
                <div class="panel-heading">
                    <div><p class="eyebrow">Applications</p><h2>Your loans</h2></div>
                    <button type="button" class="button" id="applyBtn">Apply for loan</button>
                </div>

                <% if (request.getParameter("error") != null) { %>
                    <p class="message" role="alert"><%= request.getParameter("error") %></p>
                <% } else if (request.getParameter("message") != null) { %>
                    <p class="message success" role="status">Operation completed successfully.</p>
                <% } %>

                <%
                    java.util.List<Loan> loans = (java.util.List<Loan>) request.getAttribute("loans");
                    if (loans == null || loans.isEmpty()) {
                %>
                    <div class="empty-state">
                        <h3>No loans yet</h3>
                        <p>You have not applied for any loans. Click the button above to get started.</p>
                    </div>
                <%
                    } else {
                %>
                    <div class="loan-grid">
                        <%
                            for (Loan loan : loans) {
                                String statusClass = "status-" + loan.getStatus().name().toLowerCase();
                                BigDecimal outstanding = loan.getOutstandingBalance();
                                boolean canUpdate = loan.getStatus() == LoanStatus.PENDING;
                                boolean canCancel = loan.getStatus() == LoanStatus.PENDING;
                                boolean canRepay = loan.getStatus() == LoanStatus.APPROVED && outstanding != null && outstanding.compareTo(BigDecimal.ZERO) > 0;
                        %>
                        <div class="loan-card">
                            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px;">
                                <h3>Loan #<%= loan.getId() %></h3>
                                <span class="status-badge <%= statusClass %>"><%= loan.getStatus() %></span>
                            </div>
                            <div class="loan-meta">
                                <div>Requested amount: <strong>KES <%= loan.getRequestedAmount() %></strong></div>
                                <div>Purpose: <strong><%= loan.getPurpose() %></strong></div>
                                <div>Applied on: <strong><%= loan.getAppliedAtFormatted() %></strong></div>
                                <% if (loan.getTotalRepayable() != null) { %>
                                    <div>Total repayable: <strong>KES <%= loan.getTotalRepayable() %></strong></div>
                                <% } %>
                                <% if (outstanding != null) { %>
                                    <div>Outstanding balance: <strong>KES <%= outstanding %></strong></div>
                                <% } %>
                                <% if (loan.getReviewComment() != null && !loan.getReviewComment().isBlank()) { %>
                                    <div>Review comment: <strong><%= loan.getReviewComment() %></strong></div>
                                <% } %>
                            </div>
                            <div class="loan-actions">
                                <% if (canUpdate) { %>
                                    <button type="button" class="button secondary" onclick="openUpdateModal(<%= loan.getId() %>, '<%= loan.getRequestedAmount() %>', '<%= escapeJs(loan.getPurpose()) %>')">Update</button>
                                    <form method="post" action="<%= request.getContextPath() %>/loans" onsubmit="return confirm('Cancel this loan application?');">
                                        <input type="hidden" name="action" value="cancel"/>
                                        <input type="hidden" name="loanId" value="<%= loan.getId() %>"/>
                                        <button type="submit" class="button secondary">Cancel</button>
                                    </form>
                                <% } %>
                                <% if (canRepay) { %>
                                    <a href="<%= request.getContextPath() %>/payments?action=form&loanId=<%= loan.getId() %>" class="button">Make Payment</a>
                                <% } %>
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

<!-- Apply Modal -->
<div class="modal-overlay" id="applyModal">
    <div class="modal">
        <h2>Apply for a loan</h2>
        <form method="post" action="<%= request.getContextPath() %>/loans">
            <input type="hidden" name="action" value="apply"/>
            <label for="applyAmount">Amount (KES)</label>
            <input id="applyAmount" type="number" name="amount" step="0.01" min="1" required/>
            <label for="applyPurpose">Purpose</label>
            <input id="applyPurpose" type="text" name="purpose" maxlength="500" required/>
            <div class="modal-actions">
                <button type="button" class="button secondary" onclick="closeModal('applyModal')">Close</button>
                <button type="submit" class="button">Submit application</button>
            </div>
        </form>
    </div>
</div>

<!-- Update Modal -->
<div class="modal-overlay" id="updateModal">
    <div class="modal">
        <h2>Update loan application</h2>
        <form method="post" action="<%= request.getContextPath() %>/loans">
            <input type="hidden" name="action" value="update"/>
            <input type="hidden" name="loanId" id="updateLoanId"/>
            <label for="updateAmount">Amount (KES)</label>
            <input id="updateAmount" type="number" name="amount" step="0.01" min="1" required/>
            <label for="updatePurpose">Purpose</label>
            <input id="updatePurpose" type="text" name="purpose" maxlength="500" required/>
            <div class="modal-actions">
                <button type="button" class="button secondary" onclick="closeModal('updateModal')">Close</button>
                <button type="submit" class="button">Save changes</button>
            </div>
        </form>
    </div>
</div>

<!-- Repay Modal -->
<div class="modal-overlay" id="repayModal">
    <div class="modal">
        <h2>Make a repayment</h2>
        <form method="post" action="<%= request.getContextPath() %>/loans">
            <input type="hidden" name="action" value="repay"/>
            <input type="hidden" name="loanId" id="repayLoanId"/>
            <div class="repayment-info">
                Outstanding balance: <strong>KES <span id="repayBalance">0.00</span></strong>
            </div>
            <label for="repayAmount">Repayment amount (KES)</label>
            <input id="repayAmount" type="number" name="amount" step="0.01" min="0.01" required/>
            <div class="modal-actions">
                <button type="button" class="button secondary" onclick="closeModal('repayModal')">Close</button>
                <button type="submit" class="button">Pay now</button>
            </div>
        </form>
    </div>
</div>

<script>
    const applyBtn = document.getElementById('applyBtn');
    const applyModal = document.getElementById('applyModal');
    const updateModal = document.getElementById('updateModal');
    const repayModal = document.getElementById('repayModal');

    applyBtn.addEventListener('click', () => openModal('applyModal'));

    function openModal(id) { document.getElementById(id).classList.add('open'); }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); }

    function openUpdateModal(id, amount, purpose) {
        document.getElementById('updateLoanId').value = id;
        document.getElementById('updateAmount').value = amount;
        document.getElementById('updatePurpose').value = purpose;
        openModal('updateModal');
    }

    function escapeJs(text) {
        return text.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '');
    }

    function openRepayModal(id, balance) {
        document.getElementById('repayLoanId').value = id;
        document.getElementById('repayBalance').textContent = balance;
        document.getElementById('repayAmount').value = '';
        openModal('repayModal');
    }

    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(overlay.id); });
    });
</script>
</body>
</html>