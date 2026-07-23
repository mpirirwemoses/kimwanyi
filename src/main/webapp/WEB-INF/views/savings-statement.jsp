<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Account Statement - Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .nav-links a { margin-left: 15px; text-decoration: none; color: #3498db; font-weight: bold; }
        .nav-links a:hover { color: #2980b9; }
        .statement-header { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 30px; }
        .statement-header h2 { color: #2c3e50; margin-bottom: 15px; }
        .statement-header p { margin: 5px 0; color: #555; }
        .statement-header strong { color: #2c3e50; }
        .summary-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; margin-bottom: 30px; }
        .summary-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; text-align: center; }
        .summary-card h3 { font-size: 14px; opacity: 0.9; margin-bottom: 10px; }
        .summary-card .value { font-size: 24px; font-weight: bold; }
        .transactions-section { margin-top: 30px; }
        .transactions-section h2 { color: #2c3e50; margin-bottom: 15px; font-size: 22px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; font-size: 14px; }
        th { background-color: #2c3e50; color: white; font-weight: bold; }
        tr:hover { background-color: #f5f5f5; }
        .amount-positive { color: #27ae60; font-weight: bold; }
        .amount-negative { color: #e74c3c; font-weight: bold; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-deposit { background: #d4edda; color: #155724; }
        .badge-withdrawal { background: #f8d7da; color: #721c24; }
        .badge-interest { background: #d1ecf1; color: #0c5460; }
        .no-data { text-align: center; padding: 40px; color: #7f8c8d; font-style: italic; }
        .btn { display: inline-block; padding: 12px 24px; background: #3498db; color: white; text-decoration: none; border-radius: 6px; text-align: center; font-weight: bold; margin: 5px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        .action-buttons { margin-bottom: 20px; }
        .print-section { margin-top: 30px; padding-top: 20px; border-top: 2px solid #ddd; text-align: center; }
        @media print {
            body { background-color: white; padding: 0; }
            .container { box-shadow: none; max-width: 100%; }
            .nav-links, .action-buttons, .print-section { display: none; }
            .header { border-bottom: 2px solid #000; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📄 Account Statement</h1>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/savings">Back to Savings</a>
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            </div>
        </div>

        <c:if test="${not empty account}">
            <div class="statement-header">
                <h2>Kimwanyi SACCO - Member Savings Statement</h2>
                <p><strong>Member Name:</strong> ${sessionScope.fullName}</p>
                <p><strong>Account Number:</strong> ${account.accountNumber}</p>
                <p><strong>Account Status:</strong> ${account.status}</p>
                <p><strong>Statement Generated:</strong> ${statementDate}</p>
                <p><strong>Account Opened:</strong> ${account.createdAtFormatted}</p>
            </div>
            
            <c:url value="${pageContext.request.contextPath}/savings" var="backToSavingsUrl">
                <c:if test="${account.id != null}">
                    <c:param name="accountId" value="${account.id}" />
                </c:if>
            </c:url>
            <div class="action-buttons">
                <a href="javascript:window.print()" class="btn btn-success">🖨️ Print Statement</a>
                <a href="${backToSavingsUrl}" class="btn btn-secondary">Back to Savings</a>
                <button onclick="downloadStatement()" class="btn btn-warning">💾 Download Statement</button>
            </div>

            <div class="summary-cards">
                <div class="summary-card">
                    <h3>Current Balance</h3>
                    <div class="value">UGX ${account.balance}</div>
                </div>
                <div class="summary-card">
                    <h3>Total Deposits</h3>
                    <div class="value">UGX ${account.totalDeposits}</div>
                </div>
                <div class="summary-card">
                    <h3>Total Withdrawals</h3>
                    <div class="value">UGX ${account.totalWithdrawals}</div>
                </div>
                <div class="summary-card">
                    <h3>Interest Earned</h3>
                    <div class="value">UGX ${account.totalInterestEarned}</div>
                </div>
            </div>


            <div class="transactions-section">
                <h2>Transaction History</h2>
                <c:choose>
                    <c:when test="${not empty transactions}">
                        <table>
                            <thead>
                                <tr>
                                    <th>Date & Time</th>
                                    <th>Reference</th>
                                    <th>Type</th>
                                    <th>Amount</th>
                                    <th>Balance Before</th>
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
                                        <td>UGX ${tx.balanceBefore}</td>
                                        <td><strong>UGX ${tx.balanceAfter}</strong></td>
                                        <td>${tx.notes}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="no-data">No transactions found for this account.</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="print-section">
                <p><strong>End of Statement</strong></p>
                <p>Generated by Kimwanyi SACCO Management System</p>
            </div>
        </c:if>
    </div>

    <script>
        function downloadStatement() {
            const accountNumber = '${account.accountNumber}';
            const statementDate = '${statementDate}'.replace(/[\/:]/g, '-').replace(/ /g, '_');
            const filename = `Statement_${accountNumber}_${statementDate}.html`;
            
            // Create a new window with just the statement content
            const printWindow = window.open('', '_blank');
            printWindow.document.write(`
                <!DOCTYPE html>
                <html>
                <head>
                    <title>${filename}</title>
                    <style>
                        body { font-family: Arial, sans-serif; padding: 20px; }
                        .header { text-align: center; margin-bottom: 30px; }
                        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                        th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
                        th { background: #2c3e50; color: white; }
                        .summary { background: #f8f9fa; padding: 15px; margin-bottom: 20px; }
                    </style>
                </head>
                <body>
                    <div class="header">
                        <h1>Kimwanyi SACCO - Account Statement</h1>
                        <p>Account: ${accountNumber}</p>
                        <p>Generated: ${statementDate}</p>
                    </div>
                    <div class="summary">
                        <h3>Account Summary</h3>
                        <p>Current Balance: UGX ${account.balance}</p>
                        <p>Total Deposits: UGX ${account.totalDeposits}</p>
                        <p>Total Withdrawals: UGX ${account.totalWithdrawals}</p>
                        <p>Interest Earned: UGX ${account.totalInterestEarned}</p>
                    </div>
                    ${document.querySelector('.transactions-section').innerHTML}
                    <script>
                        window.onload = function() {
                            window.print();
                        }
                    <\/script>
                </body>
                </html>
            `);
            printWindow.document.close();
        }
    </script>
</body>
</html>
