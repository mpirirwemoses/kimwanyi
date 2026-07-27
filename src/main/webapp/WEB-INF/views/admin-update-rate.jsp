<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Interest Rate | Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .btn { padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        
        .form-section { background: #f8f9fa; padding: 25px; border-radius: 8px; margin-bottom: 20px; }
        .form-section h2 { color: #2c3e50; margin-bottom: 20px; font-size: 22px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #555; font-weight: 500; font-size: 14px; }
        .form-group input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 16px; }
        .form-group input:focus { outline: none; border-color: #3498db; }
        .form-group .help-text { font-size: 12px; color: #7f8c8d; margin-top: 5px; }
        
        .info-box { background: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; border-radius: 6px; margin-bottom: 20px; color: #0c5460; }
        .info-box strong { color: #0c5460; }
        
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        
        .action-buttons { display: flex; gap: 10px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Update Interest Rate</h1>
            <a href="${pageContext.request.contextPath}/admin-dashboard?section=accounts" class="btn btn-secondary">← Back to Accounts</a>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Interest rate updated successfully!</div>
        </c:if>

        <c:if test="${not empty viewAccount}">
            <div class="info-box">
                <strong>ℹ️ Account Information:</strong> Updating interest rate for account <strong>${viewAccount.accountNumber}</strong> 
                belonging to <strong>${viewAccount.member.fullName}</strong>. Current rate: <strong>${viewAccount.interestRate}%</strong>
            </div>

            <div class="form-section">
                <h2>Update Interest Rate</h2>
                <form action="${pageContext.request.contextPath}/admin-dashboard" method="POST">
                    <input type="hidden" name="action" value="update-rate">
                    <input type="hidden" name="section" value="accounts">
                    <input type="hidden" name="accountId" value="${viewAccount.id}">
                    
                    <div class="form-group">
                        <label>New Interest Rate (%) *</label>
                        <input type="number" 
                               name="interestRate" 
                               value="${viewAccount.interestRate}" 
                               step="0.01" 
                               min="0" 
                               max="100" 
                               required
                               placeholder="Enter interest rate (e.g., 6.00)">
                        <div class="help-text">Enter a value between 0 and 100. This will be applied to the account immediately.</div>
                    </div>
                    
                    <div class="action-buttons">
                        <button type="submit" class="btn btn-success">💾 Update Interest Rate</button>
                        <a href="${pageContext.request.contextPath}/admin-dashboard?section=accounts" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>

            <div class="form-section">
                <h2>Account Details</h2>
                <div class="info-box">
                    <p><strong>Account Number:</strong> ${viewAccount.accountNumber}</p>
                    <p><strong>Member:</strong> ${viewAccount.member.fullName}</p>
                    <p><strong>Current Balance:</strong> KES ${viewAccount.balance}</p>
                    <p><strong>Current Interest Rate:</strong> ${viewAccount.interestRate}% per annum</p>
                    <p><strong>Total Deposits:</strong> KES ${viewAccount.totalDeposits}</p>
                    <p><strong>Total Interest Earned:</strong> KES ${viewAccount.totalInterestEarned}</p>
                </div>
            </div>
        </c:if>

        <c:if test="${empty viewAccount}">
            <div class="alert alert-error">
                <strong>Error:</strong> Account not found or invalid account ID.
            </div>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=accounts" class="btn btn-secondary">← Back to Accounts</a>
            </div>
        </c:if>
    </div>
</body>
</html>