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
    <title>My Loans | Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f5f5f5; display: flex; min-height: 100vh; }

        /* Sidebar Styles */
        .sidebar { width: 260px; background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%); color: white; padding: 20px 0; position: fixed; height: 100vh; overflow-y: auto; }
        .sidebar-header { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 20px; }
        .sidebar-header h2 { font-size: 20px; color: white; }
        .sidebar-header p { font-size: 12px; color: #95a5a6; margin-top: 5px; }
        .nav-menu { list-style: none; }
        .nav-item { margin-bottom: 5px; }
        .nav-link { display: flex; align-items: center; padding: 12px 20px; color: #ecf0f1; text-decoration: none; transition: all 0.3s; cursor: pointer; }
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.1); color: white; border-left: 3px solid #3498db; }
        .nav-link .icon { margin-right: 10px; font-size: 18px; }
        .nav-section { padding: 15px 20px 5px; font-size: 11px; text-transform: uppercase; color: #95a5a6; font-weight: bold; letter-spacing: 1px; }

        /* Main Content */
        .main-content { flex: 1; margin-left: 260px; padding: 30px; overflow-y: auto; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .page-header h1 { color: #2c3e50; font-size: 28px; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .user-info span { color: #555; }
        .btn-logout { padding: 8px 16px; background: #e74c3c; color: white; text-decoration: none; border-radius: 4px; font-size: 14px; border: none; cursor: pointer; }
        .btn-logout:hover { background: #c0392b; }
        .btn { padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; text-decoration: none; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }

        /* Card Styles */
        .panel { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .panel-heading { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #ecf0f1; }
        .panel-heading h2 { color: #2c3e50; font-size: 22px; }
        .welcome-panel { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .welcome-panel h1 { color: #2c3e50; font-size: 28px; margin-bottom: 8px; }
        .welcome-panel p { color: #7f8c8d; margin: 0; }
        .eyebrow { font-size: 12px; text-transform: uppercase; color: #95a5a6; font-weight: bold; letter-spacing: 1px; margin-bottom: 8px; }

        /* Loan List */
        .loan-grid { display: grid; gap: 18px; margin-top: 24px; }
        .loan-card { padding: 22px; background: white; border: 1px solid #ecf0f1; border-radius: 14px; }
        .loan-card h3 { margin: 0 0 10px; font-size: 1.05rem; color: #2c3e50; }
        .loan-meta { display: grid; gap: 6px; color: #7f8c8d; font-size: .92rem; }
        .loan-meta strong { color: #2c3e50; }
        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 6px; font-size: .82rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d1e7dd; color: #0f5132; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        .status-cancelled { background: #e2e3e5; color: #41464b; }
        .status-repaid { background: #d1e7dd; color: #0f5132; }
        .status-overdue { background: #f8d7da; color: #721c24; }
        .loan-actions { margin-top: 16px; display: flex; gap: 10px; flex-wrap: wrap; }
        .loan-actions form { display: inline; margin: 0; }
        .empty-state { padding: 40px 0; text-align: center; border-top: 1px solid #ecf0f1; }
        .empty-state h3 { color: #2c3e50; margin-bottom: 8px; }
        .empty-state p { color: #7f8c8d; }

        /* Modal */
        .modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.45); display: none; align-items: center; justify-content: center; padding: 24px; z-index: 100; }
        .modal-overlay.open { display: flex; }
        .modal { background: white; border: 1px solid #ecf0f1; border-radius: 14px; padding: 28px; width: min(100%, 520px); }
        .modal h2 { margin: 0 0 18px; color: #2c3e50; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 18px; }
        .repayment-info { background: #f8f9fa; padding: 14px; border-radius: 8px; margin: 12px 0; font-size: .92rem; }

        /* Filter */
        .filter-bar { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; margin-bottom: 18px; padding: 16px; background: #f8f9fa; border-radius: 8px; }
        .filter-bar select, .filter-bar input { padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; background: #fff; font: inherit; }
        .message { padding: 14px 18px; border-radius: 8px; margin-bottom: 20px; }
        .message[role="alert"] { background: #fff0ed; color: #a33426; }
        .message.success[role="status"] { background: #e8f5ed; color: #155724; }

        @media (max-width: 768px) {
            .sidebar { width: 100%; position: relative; }
            .main-content { margin-left: 0; }
            .filter-bar { flex-direction: column; align-items: stretch; }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h2>🏛️ Kimwanyi SACCO</h2>
            <p>Member Portal</p>
        </div>
        <ul class="nav-menu">
            <li class="nav-section">Main Menu</li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/dashboard" class="nav-link">
                    <span class="icon">📊</span> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/loans" class="nav-link active">
                    <span class="icon">📋</span> My Loans
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/payments?action=history" class="nav-link">
                    <span class="icon">💳</span> Payment History
                </a>
            </li>

            <li class="nav-section">Services</li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/loans?action=apply" class="nav-link">
                    <span class="icon">➕</span> Apply for Loan
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/savings" class="nav-link">
                    <span class="icon">💰</span> My Savings
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/savings?action=deposit" class="nav-link">
                    <span class="icon">➕</span> Make Deposit
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/savings?action=withdraw" class="nav-link">
                    <span class="icon">➖</span> Withdraw
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/savings?action=calculate-interest" class="nav-link">
                    <span class="icon">📈</span> Calculate Interest
                </a>
            </li>

            <li class="nav-section">System</li>
            <li class="nav-item">
                <form method="post" action="<%= request.getContextPath() %>/logout" style="display: inline;">
                    <button type="submit" class="nav-link" style="width: 100%; border: none; background: none; cursor: pointer; text-align: left;">
                        <span class="icon">🚪</span> Logout
                    </button>
                </form>
            </li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <div class="page-header">
            <h1>My Loans</h1>
            <div class="user-info">
                <span>Welcome, <strong><%= session.getAttribute("fullName") %></strong></span>
                <form method="post" action="<%= request.getContextPath() %>/logout" style="display: inline;">
                    <button type="submit" class="btn-logout">Logout</button>
                </form>
            </div>
        </div>

        <div class="welcome-panel">
            <p class="eyebrow">Member services</p>
            <h1>My Loans</h1>
            <p>Apply for a new loan, track your applications, and manage repayments.</p>
        </div>

        <div class="panel">
            <div class="panel-heading">
                <div><p class="eyebrow">Applications</p><h2>Your loans</h2></div>
                <button type="button" class="button" id="applyBtn">Apply for loan</button>
            </div>

            <% if (request.getParameter("error") != null) { %>
                <p class="message" role="alert"><%= request.getParameter("error") %></p>
            <% } else if (request.getParameter("message") != null) { %>
                <p class="message success" role="status">Operation completed successfully.</p>
            <% } %>

            <form method="get" action="<%= request.getContextPath() %>/loans" class="filter-bar">
                <label for="statusFilter" style="font-weight: 700;">Filter by status</label>
                <select id="statusFilter" name="status" onchange="this.form.submit()">
                    <option value="">All</option>
                    <option value="PENDING">Pending</option>
                    <option value="APPROVED">Approved</option>
                    <option value="REJECTED">Rejected</option>
                    <option value="CANCELLED">Cancelled</option>
                    <option value="REPAID">Repaid</option>
                    <option value="OVERDUE">Overdue</option>
                </select>
                <button type="submit" class="button">Filter</button>
                <a href="<%= request.getContextPath() %>/loans" class="button" style="background: #95a5a6;">Reset</a>
            </form>

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
                            <div>Requested amount: <strong>UGX <%= loan.getRequestedAmount() %></strong></div>
                            <div>Purpose: <strong><%= loan.getPurpose() %></strong></div>
                            <div>Applied on: <strong><%= loan.getAppliedAtFormatted() %></strong></div>
                            <% if (loan.getTotalRepayable() != null) { %>
                                <div>Total repayable: <strong>UGX <%= loan.getTotalRepayable() %></strong></div>
                            <% } %>
                            <% if (outstanding != null) { %>
                                <div>Outstanding balance: <strong>UGX <%= outstanding %></strong></div>
                            <% } %>
                            <% if (loan.getReviewComment() != null && !loan.getReviewComment().isBlank()) { %>
                                <div>Review comment: <strong><%= loan.getReviewComment() %></strong></div>
                            <% } %>
                        </div>
                        <div class="loan-actions">
                            <% if (canUpdate) { %>
                                <button type="button" class="button" style="background: #f39c12;" onclick="openUpdateModal(<%= loan.getId() %>, '<%= loan.getRequestedAmount() %>', '<%= escapeJs(loan.getPurpose()) %>')">Update</button>
                                <form method="post" action="<%= request.getContextPath() %>/loans" onsubmit="return confirm('Cancel this loan application?');">
                                    <input type="hidden" name="action" value="cancel"/>
                                    <input type="hidden" name="loanId" value="<%= loan.getId() %>"/>
                                    <button type="submit" class="button" style="background: #95a5a6;">Cancel</button>
                                </form>
                            <% } %>
                            <% if (canRepay) { %>
                                <a href="<%= request.getContextPath() %>/payments?action=form&loanId=<%= loan.getId() %>" class="button" style="background: #27ae60;">Make Payment</a>
                            <% } %>
                            <% if (loan.getStatus() == LoanStatus.APPROVED) { %>
                                <button type="button" class="button" style="background: #17a2b8;" onclick="openInterestModal(<%= loan.getId() %>)">Calculate Interest</button>
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
        </div>
    </main>

    <!-- Apply Modal -->
    <div class="modal-overlay" id="applyModal">
        <div class="modal">
            <h2>Apply for a loan</h2>
            <form method="post" action="<%= request.getContextPath() %>/loans">
                <input type="hidden" name="action" value="apply"/>
                <label for="applyAmount">Amount (UGX)</label>
                <input id="applyAmount" type="number" name="amount" step="0.01" min="1" required style="width: 100%; padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; margin-bottom: 12px;"/>
                <label for="applyPurpose">Purpose</label>
                <input id="applyPurpose" type="text" name="purpose" maxlength="500" required style="width: 100%; padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; margin-bottom: 12px;"/>
                <div class="modal-actions">
                    <button type="button" class="button" style="background: #95a5a6;" onclick="closeModal('applyModal')">Close</button>
                    <button type="submit" class="button" style="background: #27ae60;">Submit application</button>
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
                <label for="updateAmount">Amount (UGX)</label>
                <input id="updateAmount" type="number" name="amount" step="0.01" min="1" required style="width: 100%; padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; margin-bottom: 12px;"/>
                <label for="updatePurpose">Purpose</label>
                <input id="updatePurpose" type="text" name="purpose" maxlength="500" required style="width: 100%; padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; margin-bottom: 12px;"/>
                <div class="modal-actions">
                    <button type="button" class="button" style="background: #95a5a6;" onclick="closeModal('updateModal')">Close</button>
                    <button type="submit" class="button" style="background: #27ae60;">Save changes</button>
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
                    Outstanding balance: <strong>UGX <span id="repayBalance">0.00</span></strong>
                </div>
                <label for="repayAmount">Repayment amount (UGX)</label>
                <input id="repayAmount" type="number" name="amount" step="0.01" min="0.01" required style="width: 100%; padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; margin-bottom: 12px;"/>
                <div class="modal-actions">
                    <button type="button" class="button" style="background: #95a5a6;" onclick="closeModal('repayModal')">Close</button>
                    <button type="submit" class="button" style="background: #27ae60;">Pay now</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Interest Calculation Modal -->
    <div class="modal-overlay" id="interestModal">
        <div class="modal">
            <h2>Calculate Interest</h2>
            <form method="post" action="<%= request.getContextPath() %>/loans">
                <input type="hidden" name="action" value="calculateInterest"/>
                <input type="hidden" name="loanId" id="interestLoanId"/>
                <label for="periodType">Calculation Period</label>
                <select id="periodType" name="periodType" required style="width: 100%; padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; margin-bottom: 12px;">
                    <option value="MONTHLY">Monthly</option>
                    <option value="WEEKLY">Weekly</option>
                </select>
                <div class="modal-actions">
                    <button type="button" class="button" style="background: #95a5a6;" onclick="closeModal('interestModal')">Close</button>
                    <button type="submit" class="button" style="background: #27ae60;">Calculate</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Calculation Result Modal -->
    <div class="modal-overlay" id="resultModal">
        <div class="modal" style="width: min(100%, 700px);">
            <h2>Interest Calculation Result</h2>
            <div style="background: #f8f9fa; padding: 16px; border-radius: 8px; margin: 12px 0; max-height: 400px; overflow-y: auto;">
                <pre id="calculationProcedure" style="white-space: pre-wrap; font-family: monospace; font-size: .85rem; line-height: 1.5;"></pre>
            </div>
            <div class="modal-actions">
                <button type="button" class="button" style="background: #95a5a6;" onclick="closeModal('resultModal')">Close</button>
            </div>
        </div>
    </div>

    <script>
        const applyBtn = document.getElementById('applyBtn');
        const applyModal = document.getElementById('applyModal');
        const updateModal = document.getElementById('updateModal');
        const repayModal = document.getElementById('repayModal');
        const interestModal = document.getElementById('interestModal');
        const resultModal = document.getElementById('resultModal');

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

        function openInterestModal(loanId) {
            document.getElementById('interestLoanId').value = loanId;
            openModal('interestModal');
        }

        <% 
            String calculationProcedure = (String) request.getAttribute("calculationProcedure"); 
            if (calculationProcedure != null) {
                request.removeAttribute("calculationProcedure");
        %>
            window.addEventListener('DOMContentLoaded', function() {
                document.getElementById('calculationProcedure').textContent = '<%= escapeJs(calculationProcedure) %>';
                openModal('resultModal');
            });
        <% } %>

        document.querySelectorAll('.modal-overlay').forEach(overlay => {
            overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(overlay.id); });
        });
    </script>
</body>
</html>