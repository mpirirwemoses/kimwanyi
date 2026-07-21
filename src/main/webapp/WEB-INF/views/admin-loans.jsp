<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.example.model.Loan" %>
<%@ page import="org.example.model.LoanStatus" %>
<%@ page import="java.math.BigDecimal" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loan Applications | Credit SACCO</title>
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
        .filter-bar { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; margin-bottom: 18px; }
        .filter-bar select, .filter-bar input { padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; background: #fff; font: inherit; }
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
            <h1>Loan Applications</h1>
            <p>Review member loan applications and take action.</p>
        </section>

        <section class="content-grid">
            <article class="panel">
                <div class="panel-heading">
                    <div><p class="eyebrow">Applications</p><h2>All loans</h2></div>
                </div>

                <% if (request.getParameter("error") != null) { %>
                    <p class="message" role="alert"><%= request.getParameter("error") %></p>
                <% } else if (request.getParameter("message") != null) { %>
                    <p class="message success" role="status">Operation completed successfully.</p>
                <% } %>

                <div class="filter-bar">
                    <label for="statusFilter">Filter by status</label>
                    <select id="statusFilter" onchange="filterLoans()">
                        <option value="">All</option>
                        <option value="PENDING">Pending</option>
                        <option value="APPROVED">Approved</option>
                        <option value="REJECTED">Rejected</option>
                        <option value="CANCELLED">Cancelled</option>
                        <option value="REPAID">Repaid</option>
                        <option value="OVERDUE">Overdue</option>
                    </select>
                    <input type="text" id="searchInput" placeholder="Search member or purpose..." oninput="filterLoans()"/>
                </div>

                <%
                    java.util.List<Loan> loans = (java.util.List<Loan>) request.getAttribute("loans");
                    if (loans == null || loans.isEmpty()) {
                %>
                    <div class="empty-state">
                        <h3>No applications yet</h3>
                        <p>Loan applications from members will appear here.</p>
                    </div>
                <%
                    } else {
                %>
                    <div class="loan-grid" id="loanGrid">
                        <%
                            for (Loan loan : loans) {
                                String statusClass = "status-" + loan.getStatus().name().toLowerCase();
                                BigDecimal outstanding = loan.getOutstandingBalance();
                                boolean canApprove = loan.getStatus() == LoanStatus.PENDING;
                                boolean canReject = loan.getStatus() == LoanStatus.PENDING;
                                String memberName = loan.getMember().getFullName();
                                String purpose = loan.getPurpose();
                        %>
                        <div class="loan-card" data-status="<%= loan.getStatus() %>" data-search="<%= memberName %> <%= purpose %>">
                            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px;">
                                <h3>Loan #<%= loan.getId() %> - <%= loan.getMember().getFullName() %></h3>
                                <span class="status-badge <%= statusClass %>"><%= loan.getStatus() %></span>
                            </div>
                            <div class="loan-meta">
                                <div>Member: <strong><%= loan.getMember().getFullName() %> (<%= loan.getMember().getEmail() %>)</strong></div>
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
                                <% if (canApprove) { %>
                                    <button type="button" class="button" data-action="approve" data-loan-id="<%= loan.getId() %>">Approve</button>
                                    <button type="button" class="button secondary" data-action="reject" data-loan-id="<%= loan.getId() %>">Reject</button>
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

<!-- Action Modal -->
<div class="modal-overlay" id="actionModal">
    <div class="modal">
        <h2 id="actionModalTitle">Review loan</h2>
        <form method="post" action="<%= request.getContextPath() %>/loans">
            <input type="hidden" name="action" id="actionType"/>
            <input type="hidden" name="loanId" id="actionLoanId"/>
            <label for="actionComment">Comment</label>
            <textarea id="actionComment" name="comment" rows="4" style="width:100%; padding:12px; border:1px solid #b9cbc0; border-radius:8px; font:inherit;" placeholder="Add a review comment..."></textarea>
            <div class="modal-actions">
                <button type="button" class="button secondary" onclick="closeModal('actionModal')">Close</button>
                <button type="submit" class="button" id="actionSubmit">Submit</button>
            </div>
        </form>
    </div>
</div>

<script>
    const actionModal = document.getElementById('actionModal');
    const actionType = document.getElementById('actionType');
    const actionModalTitle = document.getElementById('actionModalTitle');
    const actionSubmit = document.getElementById('actionSubmit');

    function openModal(id) { document.getElementById(id).classList.add('open'); }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); }

    function openActionModal(type, loanId) {
        actionType.value = type;
        document.getElementById('actionLoanId').value = loanId;
        actionModalTitle.textContent = type === 'approve' ? 'Approve loan' : 'Reject loan';
        actionSubmit.textContent = type === 'approve' ? 'Approve' : 'Reject';
        document.getElementById('actionComment').value = '';
        openModal('actionModal');
    }

    document.querySelectorAll('.loan-actions button[data-action]').forEach(button => {
        button.addEventListener('click', () => {
            const type = button.getAttribute('data-action');
            const loanId = button.getAttribute('data-loan-id');
            openActionModal(type, loanId);
        });
    });

    function filterLoans() {
        const status = document.getElementById('statusFilter').value;
        const search = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('#loanGrid .loan-card').forEach(card => {
            const cardStatus = card.getAttribute('data-status');
            const cardSearch = card.getAttribute('data-search').toLowerCase();
            const matchesStatus = !status || cardStatus === status;
            const matchesSearch = !search || cardSearch.includes(search);
            card.style.display = matchesStatus && matchesSearch ? '' : 'none';
        });
    }

    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(overlay.id); });
    });
</script>
</body>
</html>