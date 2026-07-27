<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>My Savings - Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .nav-links a { margin-left: 15px; text-decoration: none; color: #3498db; font-weight: bold; }
        .nav-links a:hover { color: #2980b9; }
        .alert { padding: 12px; margin-bottom: 20px; border-radius: 4px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .balance-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px; margin-bottom: 30px; text-align: center; }
        .balance-card h2 { font-size: 16px; margin-bottom: 10px; opacity: 0.9; }
        .balance-card .amount { font-size: 42px; font-weight: bold; margin-bottom: 15px; }
        .balance-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 20px; }
        .stat-box { background: rgba(255,255,255,0.15); padding: 15px; border-radius: 6px; }
        .stat-box .label { font-size: 12px; opacity: 0.9; margin-bottom: 5px; }
        .stat-box .value { font-size: 20px; font-weight: bold; }
        .action-buttons { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 30px; }
        .btn { display: inline-block; padding: 15px 30px; background: #3498db; color: white; text-decoration: none; border-radius: 6px; text-align: center; font-weight: bold; border: none; cursor: pointer; font-size: 16px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .btn-info { background: #17a2b8; }
        .btn-info:hover { background: #138496; }
        .transactions-section { margin-top: 30px; }
        .transactions-section h2 { color: #2c3e50; margin-bottom: 15px; font-size: 22px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #2c3e50; color: white; font-weight: bold; }
        tr:hover { background-color: #f5f5f5; }
        .amount-positive { color: #27ae60; font-weight: bold; }
        .amount-negative { color: #e74c3c; font-weight: bold; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-deposit { background: #d4edda; color: #155724; }
        .badge-withdrawal { background: #f8d7da; color: #721c24; }
        .badge-interest { background: #d1ecf1; color: #0c5460; }
        .no-data { text-align: center; padding: 40px; color: #7f8c8d; font-style: italic; }
        .account-info { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px; }
        .account-info p { margin: 5px 0; color: #555; }
        .account-info strong { color: #2c3e50; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>💰 My Savings Account</h1>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <a href="${pageContext.request.contextPath}/loans">Loans</a>
                <a href="${pageContext.request.contextPath}/logout">Logout</a>
            </div>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Operation completed successfully!</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>

        <c:if test="${not empty allAccounts && allAccounts.size() > 1}">
            <div class="account-selector" style="background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px;">
                <label for="accountSelect" style="display: block; margin-bottom: 8px; color: #2c3e50; font-weight: bold;">Select Account:</label>
                <select id="accountSelect" name="accountId" onchange="switchAccount(this.value)" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 16px;">
                    <c:forEach var="acc" items="${allAccounts}">
                        <option value="${acc.id}" ${acc.id == account.id ? 'selected' : ''}>
                            ${acc.accountNumber} - KES ${acc.balance} (${acc.status})
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
                <h2>Available Balance</h2>
                <div class="amount">KES ${account.balance}</div>
                <div class="balance-stats">
                    <div class="stat-box">
                        <div class="label">Total Deposits</div>
                        <div class="value">KES ${account.totalDeposits}</div>
                    </div>
                    <div class="stat-box">
                        <div class="label">Total Withdrawals</div>
                        <div class="value">KES ${account.totalWithdrawals}</div>
                    </div>
                    <div class="stat-box">
                        <div class="label">Interest Earned</div>
                        <div class="value">KES ${account.totalInterestEarned}</div>
                    </div>
                </div>
            </div>

            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/savings?action=deposit" class="btn btn-success">➕ Make Deposit</a>
                <a href="${pageContext.request.contextPath}/savings?action=withdraw" class="btn btn-warning">➖ Withdraw Funds</a>
                <a href="${pageContext.request.contextPath}/savings?action=statement" class="btn btn-info">📄 Account Statement</a>
                <button onclick="calculateInterest()" class="btn" style="background: #17a2b8;">📈 Calculate Interest</button>
                <button onclick="showChangeAccountNumberModal()" class="btn" style="background: #9b59b6;">✏️ Change Account Number</button>
            </div>

            <div class="transactions-section">
                <h2>Recent Transactions</h2>
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
                                            ${tx.type == 'DEPOSIT' || tx.type == 'INTEREST' ? '+' : '-'} KES ${tx.amount}
                                        </td>
                                        <td><strong>KES ${tx.balanceAfter}</strong></td>
                                        <td>${tx.notes}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="no-data">No transactions yet. Make your first deposit to get started!</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${empty account}">
            <div class="no-data">
                <h3>No Savings Account Found</h3>
                <p>Your savings account is being created...</p>
            </div>
        </c:if>
    </div>

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
