<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Savings | Kimwanyi SACCO</title>
    <style>
        :root {
            --gray-50: #fafafa;
            --gray-100: #f5f5f5;
            --gray-200: #e5e7eb;
            --gray-300: #d1d5db;
            --gray-400: #9ca3af;
            --gray-500: #6b7280;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --gray-900: #111827;
            --green-500: #27ae60;
            --green-600: #229954;
            --green-50: #ecfdf5;
            --sidebar-bg: #1e293b;
            --sidebar-hover: #334155;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; font-size: 16px; line-height: 1.5; }
        body { background-color: var(--gray-100); display: flex; min-height: 100vh; color: var(--gray-700); }

        /* Sidebar */
        .sidebar { width: 260px; background: var(--sidebar-bg); color: white; padding: 20px 0; position: fixed; height: 100vh; overflow-y: auto; }
        .sidebar-header { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 20px; }
        .sidebar-header h2 { font-size: 18px; font-weight: 700; color: white; }
        .sidebar-header p { font-size: 13px; color: var(--gray-400); margin-top: 4px; }
        .nav-menu { list-style: none; }
        .nav-item { margin-bottom: 4px; }
        .nav-link { display: flex; align-items: center; padding: 12px 20px; color: #e2e8f0; text-decoration: none; transition: all 0.2s; border-radius: 0 6px 6px 0; }
        .nav-link:hover, .nav-link.active { background: var(--sidebar-hover); color: white; border-left: 3px solid var(--green-500); }
        .nav-link .icon { margin-right: 10px; font-size: 17px; }
        .nav-section { padding: 15px 20px 5px; font-size: 11px; text-transform: uppercase; color: var(--gray-400); font-weight: 600; letter-spacing: 0.5px; }

        /* Main Content */
        .main-content { flex: 1; margin-left: 260px; padding: 32px; overflow-y: auto; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; }
        .page-header h1 { color: var(--gray-800); font-size: 26px; font-weight: 700; }
        .user-info { display: flex; align-items: center; gap: 16px; }
        .user-info span { color: var(--gray-500); font-size: 15px; }
        .btn-logout { padding: 8px 18px; background: var(--gray-600); color: white; text-decoration: none; border-radius: 6px; font-size: 14px; border: none; cursor: pointer; transition: background 0.2s; }
        .btn-logout:hover { background: var(--gray-700); }

        /* Cards */
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; padding: 28px; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 24px; }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid var(--gray-200); }
        .card-header h2 { color: var(--gray-800); font-size: 20px; font-weight: 600; }

        /* Balance Card */
        .balance-card { background: linear-gradient(135deg, var(--green-500) 0%, var(--green-600) 100%); color: white; padding: 32px; border-radius: 12px; margin-bottom: 24px; text-align: center; }
        .balance-card h3 { font-size: 15px; opacity: 0.9; margin-bottom: 12px; font-weight: 500; }
        .balance-card .amount { font-size: 36px; font-weight: 700; margin-bottom: 20px; }
        .balance-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
        .stat-box { background: rgba(255,255,255,0.15); padding: 16px; border-radius: 8px; }
        .stat-box .label { font-size: 12px; opacity: 0.85; margin-bottom: 4px; font-weight: 500; }
        .stat-box .value { font-size: 18px; font-weight: 600; }

        /* Account Info */
        .account-info { background: var(--gray-50); padding: 18px; border-radius: 8px; margin-bottom: 24px; border: 1px solid var(--gray-200); }
        .account-info p { margin: 6px 0; color: var(--gray-600); font-size: 14px; }
        .account-info strong { color: var(--gray-800); font-weight: 600; }

        /* Alerts */
        .alert { padding: 14px 18px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; }
        .alert-success { background-color: #dcfce7; color: #166534; border: 1px solid #86efac; }
        .alert-error { background-color: #fee2e2; color: #991b2b; border: 1px solid #fca5a5; }

        /* Badges */
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .badge-deposit { background: #dcfce7; color: #166534; }
        .badge-withdrawal { background: #fee2e2; color: #991b2b; }
        .badge-interest { background: #cffafe; color: #083344; }

        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 16px; font-size: 14px; }
        th, td { padding: 12px 14px; text-align: left; border-bottom: 1px solid var(--gray-200); }
        th { background-color: var(--gray-800); color: white; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover { background-color: var(--gray-50); }
        .amount-positive { color: var(--green-600); font-weight: 600; }
        .amount-negative { color: #dc2626; font-weight: 600; }

        .no-data { text-align: center; padding: 48px 20px; color: var(--gray-400); font-style: italic; }
        .transactions-section { margin-top: 24px; }
        .transactions-section h2 { color: var(--gray-800); margin-bottom: 16px; font-size: 20px; font-weight: 600; }

        /* Quick Actions */
        .quick-actions { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 15px; margin-bottom: 24px; }
        .action-btn { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; background: var(--gray-50); border: 1px solid var(--gray-200); border-radius: 8px; text-decoration: none; color: var(--gray-700); transition: all 0.3s; text-align: center; }
        .action-btn:hover { background: var(--green-50); border-color: var(--green-500); transform: translateY(-2px); }
        .action-icon { font-size: 32px; margin-bottom: 10px; }
        .action-label { font-size: 14px; font-weight: 600; color: var(--gray-700); }

        @media (max-width: 768px) {
            .sidebar { width: 100%; position: relative; }
            .main-content { margin-left: 0; }
            .balance-card .amount { font-size: 28px; }
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
                <a href="<%= request.getContextPath() %>/loans" class="nav-link">
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
                <a href="<%= request.getContextPath() %>/savings" class="nav-link active">
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
            <h1>💰 My Savings Account</h1>
            <div class="user-info">
                <span>Welcome, <strong><%= session.getAttribute("fullName") %></strong></span>
                <form method="post" action="<%= request.getContextPath() %>/logout" style="display: inline;">
                    <button type="submit" class="btn-logout">Logout</button>
                </form>
            </div>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Operation completed successfully!</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>

        <c:if test="${not empty allAccounts && allAccounts.size() > 1}">
            <div class="card">
                <div class="card-header">
                    <h2>Select Account</h2>
                </div>
                <select id="accountSelect" name="accountId" onchange="switchAccount(this.value)" style="width: 100%; padding: 12px; border: 1px solid var(--gray-300); border-radius: 8px; font-size: 15px; background: white;">
                    <c:forEach var="acc" items="${allAccounts}">
                        <option value="${acc.id}" ${acc.id == account.id ? 'selected' : ''}>
                            ${acc.accountNumber} - UGX ${acc.balance} (${acc.status})
                        </option>
                    </c:forEach>
                </select>
            </div>
        </c:if>

        <c:if test="${not empty account}">
            <div class="account-info">
                <p><strong>Account Number:</strong> ${account.accountNumber}</p>
                <p><strong>Account Status:</strong> <span class="badge badge-${account.status == 'ACTIVE' ? 'deposit' : 'withdrawal'}">${account.status}</span></p>
                <p><strong>Member:</strong> ${sessionScope.fullName}</p>
                <p><strong>Interest Rate:</strong> ${account.interestRate}% per annum</p>
            </div>

            <div class="balance-card">
                <h3>Available Balance</h3>
                <div class="amount">UGX ${account.balance}</div>
                <div class="balance-stats">
                    <div class="stat-box">
                        <div class="label">Total Deposits</div>
                        <div class="value">UGX ${account.totalDeposits}</div>
                    </div>
                    <div class="stat-box">
                        <div class="label">Total Withdrawals</div>
                        <div class="value">UGX ${account.totalWithdrawals}</div>
                    </div>
                    <div class="stat-box">
                        <div class="label">Interest Earned</div>
                        <div class="value">UGX ${account.totalInterestEarned}</div>
                    </div>
                </div>
            </div>

            <div class="quick-actions">
                <a href="${pageContext.request.contextPath}/savings?action=deposit" class="action-btn">
                    <div class="action-icon">➕</div>
                    <div class="action-label">Make Deposit</div>
                </a>
                <a href="${pageContext.request.contextPath}/savings?action=withdraw" class="action-btn">
                    <div class="action-icon">➖</div>
                    <div class="action-label">Withdraw Funds</div>
                </a>
                <a href="${pageContext.request.contextPath}/savings?action=calculate-interest" class="action-btn">
                    <div class="action-icon">📈</div>
                    <div class="action-label">Calculate Interest</div>
                </a>
                <a href="${pageContext.request.contextPath}/savings?action=statement" class="action-btn">
                    <div class="action-icon">📄</div>
                    <div class="action-label">Account Statement</div>
                </a>
            </div>

            <div class="transactions-section card">
                <div class="card-header">
                    <h2>Recent Transactions</h2>
                </div>
                <c:choose>
                    <c:when test="${not empty transactions}">
                        <table>
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Reference</th>
                                    <th>Type</th>
                                    <th>Amount</th>
                                    <th>Balance After</th>
                                    <th>Notes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="tx" items="${transactions}">
                                    <tr>
                                        <td>${tx.transactionDateFormatted}</td>
                                        <td>${tx.transactionReference}</td>
                                        <td>
                                            <span class="badge badge-${tx.type == 'DEPOSIT' ? 'deposit' : tx.type == 'WITHDRAWAL' ? 'withdrawal' : 'interest'}">
                                                ${tx.type}
                                            </span>
                                        </td>
                                        <td class="${tx.type == 'DEPOSIT' || tx.type == 'INTEREST' ? 'amount-positive' : 'amount-negative'}">
                                            ${tx.type == 'DEPOSIT' || tx.type == 'INTEREST' ? '+' : '-'} UGX ${tx.amount}
                                        </td>
                                        <td><strong>UGX ${tx.balanceAfter}</strong></td>
                                        <td>${tx.notes}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="no-data">
                            <p>No transactions yet. Make your first deposit to get started!</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${empty account}">
            <div class="no-data">
                <h3 style="color: var(--gray-700); margin-bottom: 8px;">No Savings Account Found</h3>
                <p>Your savings account is being created...</p>
            </div>
        </c:if>
    </main>

    <script>
        function switchAccount(accountId) {
            if (accountId) {
                window.location.href = '${pageContext.request.contextPath}/savings?accountId=' + accountId;
            }
        }

        function calculateInterest() {
            if (confirm("Calculate interest for this account? This will show you the interest amount without applying it.")) {
                let form = document.createElement("form");
                form.method = "POST";
                form.action = "${pageContext.request.contextPath}/savings";
                let actionInput = document.createElement("input");
                actionInput.type = "hidden";
                actionInput.name = "action";
                actionInput.value = "calculate-interest";
                let accountIdInput = document.createElement("input");
                accountIdInput.type = "hidden";
                accountIdInput.name = "accountId";
                accountIdInput.value = "${account.id}";
                form.appendChild(actionInput);
                form.appendChild(accountIdInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        function showChangeAccountNumberModal() {
            const newAccountNumber = prompt("Enter new account number:");
            if (newAccountNumber && newAccountNumber.trim() !== "") {
                if (newAccountNumber.length > 30) {
                    alert("Account number must be 30 characters or less.");
                    return;
                }
                let form = document.createElement("form");
                form.method = "POST";
                form.action = "${pageContext.request.contextPath}/savings";
                let actionInput = document.createElement("input");
                actionInput.type = "hidden";
                actionInput.name = "action";
                actionInput.value = "change-account-number";
                let accountIdInput = document.createElement("input");
                accountIdInput.type = "hidden";
                accountIdInput.name = "accountId";
                accountIdInput.value = "${account.id}";
                let accountNumberInput = document.createElement("input");
                accountNumberInput.type = "hidden";
                accountNumberInput.name = "newAccountNumber";
                accountNumberInput.value = newAccountNumber.trim();
                form.appendChild(actionInput);
                form.appendChild(accountIdInput);
                form.appendChild(accountNumberInput);
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>
