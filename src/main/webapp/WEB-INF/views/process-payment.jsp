<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Process Loan Payment | Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 700px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 24px; }
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        .back-link:hover { color: #2980b9; }
        .info-box { background: #f8f9fa; padding: 18px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid #3498db; }
        .info-box p { margin: 5px 0; color: #555; }
        .info-box strong { color: #2c3e50; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; margin-bottom: 6px; color: #2c3e50; font-weight: 600; }
        .form-group input, .form-group textarea, .form-group select {
            width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px;
            font-size: 15px; transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #3498db; }
        .form-group textarea { resize: vertical; min-height: 80px; }
        .amount-display { background: #e8f5ed; padding: 15px; border-radius: 6px; margin-bottom: 20px; text-align: center; }
        .amount-display .label { font-size: 13px; color: #555; text-transform: uppercase; letter-spacing: 1px; }
        .amount-display .value { font-size: 28px; font-weight: bold; color: #27ae60; margin-top: 5px; }
        .btn { padding: 12px 24px; background: #27ae60; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 15px; font-weight: bold; }
        .btn:hover { background: #229954; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        .alert { padding: 12px; border-radius: 4px; margin-bottom: 20px; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .actions { display: flex; gap: 10px; margin-top: 25px; }
        .half { width: 48%; display: inline-block; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>💰 Process Loan Payment</h1>
            <a href="${pageContext.request.contextPath}/admin-dashboard?section=loans" class="back-link">← Back to Loans</a>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Payment processed successfully!</div>
        </c:if>

        <c:if test="${not empty viewLoan}">
            <div class="info-box">
                <p><strong>Member:</strong> ${viewLoan.member.fullName}</p>
                <p><strong>Loan Reference:</strong> ${viewLoan.loanReference}</p>
                <p><strong>Status:</strong> ${viewLoan.status}</p>
                <p><strong>Applied At:</strong> ${viewLoan.appliedAtFormatted}</p>
            </div>

            <div class="amount-display">
                <div class="label">Outstanding Balance</div>
                <div class="value">UGX ${viewLoan.outstandingBalance}</div>
            </div>

            <form method="POST" action="${pageContext.request.contextPath}/admin-dashboard" onsubmit="return validatePaymentForm()">
                <input type="hidden" name="action" value="process-loan-payment">
                <input type="hidden" name="loanId" value="${viewLoan.id}">
                <input type="hidden" name="section" value="loans">

                <div class="form-group">
                    <label for="amount">Payment Amount (UGX) *</label>
                    <input type="number" id="amount" name="amount" step="0.01"
                           value="${viewLoan.outstandingBalance}" required
                           min="1" max="${viewLoan.outstandingBalance}">
                    <small style="color: #7f8c8d;">Enter the amount the member has paid in cash. Max: UGX ${viewLoan.outstandingBalance}</small>
                </div>

                <div class="form-group">
                    <label for="notes">Notes / Receipt Reference *</label>
                    <textarea id="notes" name="notes" required
                              placeholder="E.g., Cash received at SACCO office. Receipt No: ...">Cash payment received at SACCO office</textarea>
                </div>

                <div class="actions">
                    <button type="submit" class="btn">Confirm Payment</button>
                    <a href="${pageContext.request.contextPath}/admin-dashboard?section=loans" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </c:if>

        <c:if test="${empty viewLoan}">
            <div class="alert alert-error">Loan not found. <a href="${pageContext.request.contextPath}/admin-dashboard?section=loans">Return to loans</a>.</div>
        </c:if>
    </div>

    <script>
        function validatePaymentForm() {
            const amountInput = document.getElementById('amount');
            const maxAmount = parseFloat(amountInput.getAttribute('max'));
            const enteredAmount = parseFloat(amountInput.value);

            if (isNaN(enteredAmount) || enteredAmount <= 0) {
                alert('Please enter a valid payment amount greater than 0.');
                return false;
            }
            if (enteredAmount > maxAmount) {
                alert('Payment amount cannot exceed the outstanding balance of UGX ' + maxAmount.toFixed(2));
                return false;
            }
            return confirm('Process cash payment of UGX ' + enteredAmount.toFixed(2) + '?\n\nThis will create a payment record, apply it to the loan, create an audit log entry, and send a notification to the member.');
        }
    </script>
</body>
</html>