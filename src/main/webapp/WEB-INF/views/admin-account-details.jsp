<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Details | Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .btn { padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        
        .details-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .details-section h2 { color: #2c3e50; margin-bottom: 15px; font-size: 20px; }
        .detail-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #ddd; }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { color: #555; font-weight: 500; }
        .detail-value { color: #2c3e50; font-weight: bold; }
        
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-warning { background: #fff3cd; color: #856404; }
        .badge-danger { background: #f8d7da; color: #721c24; }
        .badge-info { background: #d1ecf1; color: #0c5460; }
        
        .action-buttons { display: flex; gap: 10px; margin-top: 20px; }
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        
        .balance-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px; margin-bottom: 20px; text-align: center; }
        .balance-card h2 { font-size: 18px; margin-bottom: 10px; opacity: 0.9; }
        .balance-card .amount { font-size: 42px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>💰 Account Details${pageContext.request.contextPath}</h1>
            <a href="${pageContext.request.contextPath}/admin-dashboard?section=accounts" class="btn btn-secondary">← Back to Accounts</a>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Operation completed successfully!</div>
        </c:if>

        <c:if test="${not empty viewAccount}">
            <div class="balance-card">
                <h2>Current Balance</h2>
                <div class="amount">UGX ${viewAccount.balance}</div>
            </div>

            <div class="details-section">
                <h2>Account Information</h2>
                <div class="detail-row">
                    <span class="detail-label">Account Number:</span>
                    <span class="detail-value">${viewAccount.accountNumber}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Account ID:</span>
                    <span class="detail-value">${viewAccount.id}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Member Name:</span>
                    <span class="detail-value">${viewAccount.member.fullName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Member Email:</span>
                    <span class="detail-value">${viewAccount.member.email}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="badge badge-${viewAccount.status == 'ACTIVE' ? 'success' : 'warning'}">${viewAccount.status}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Interest Rate:</span>
                    <span class="detail-value">${viewAccount.interestRate}% per annum</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total Deposits:</span>
                    <span class="detail-value">UGX ${viewAccount.totalDeposits}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total Withdrawals:</span>
                    <span class="detail-value">UGX ${viewAccount.totalWithdrawals}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total Interest Earned:</span>
                    <span class="detail-value">UGX ${viewAccount.totalInterestEarned}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Minimum Balance:</span>
                    <span class="detail-value">UGX ${viewAccount.minimumBalance}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Daily Withdrawal Limit:</span>
                    <span class="detail-value">UGX ${viewAccount.dailyWithdrawalLimit}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Created At:</span>
                    <span class="detail-value">${viewAccount.createdAtFormatted}</span>
                </div>
            </div>

            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=accounts&action=update-rate&accountId=${viewAccount.id}" class="btn btn-warning">📊 Update Interest Rate</a>
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=members&action=contact&memberId=${viewAccount.member.id}" class="btn btn-info">👤 Contact Member</a>
            </div>
        </c:if>

        <c:if test="${empty viewAccount}">
            <div class="details-section">
                <p style="text-align: center; color: #7f8c8d; padding: 40px;">Account not found or invalid account ID.</p>
            </div>
            <div class="action-buttons" style="justify-content: center;">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=accounts" class="btn btn-secondary">← Back to Accounts</a>
            </div>
        </c:if>
    </div>
</body>
</html>