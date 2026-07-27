<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Withdraw Funds - Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .nav-links a { margin-left: 15px; text-decoration: none; color: #3498db; font-weight: bold; }
        .nav-links a:hover { color: #2980b9; }
        .alert { padding: 12px; margin-bottom: 20px; border-radius: 4px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-warning { background-color: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #2c3e50; font-weight: bold; }
        .form-group input, .form-group select, .form-group textarea { 
            width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; 
            font-size: 16px; transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { 
            outline: none; border-color: #3498db; 
        }
        .form-group textarea { resize: vertical; min-height: 80px; }
        .btn { 
            display: inline-block; padding: 15px 30px; background: #e74c3c; color: white; 
            text-decoration: none; border-radius: 6px; text-align: center; font-weight: bold; 
            border: none; cursor: pointer; font-size: 16px; 
        }
        .btn:hover { background: #c0392b; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        .account-info { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 25px; }
        .account-info p { margin: 5px 0; color: #555; }
        .account-info strong { color: #2c3e50; }
        .balance-display { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; margin-bottom: 25px; text-align: center; }
        .balance-display h3 { font-size: 14px; opacity: 0.9; margin-bottom: 10px; }
        .balance-display .amount { font-size: 32px; font-weight: bold; }
        .payment-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin-bottom: 20px; }
        .payment-method { 
            padding: 15px; border: 2px solid #ddd; border-radius: 6px; text-align: center; 
            cursor: pointer; transition: all 0.3s;
        }
        .payment-method:hover { border-color: #3498db; }
        .payment-method.selected { border-color: #e74c3c; background: #f8d7da; }
        .payment-method input { display: none; }
        .payment-method label { cursor: pointer; font-weight: bold; color: #2c3e50; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }
        .info-box { background: #e3f2fd; border-left: 4px solid #2196f3; padding: 15px; margin-bottom: 20px; border-radius: 4px; }
        .info-box p { margin: 5px 0; color: #555; }
        .info-box strong { color: #1976d2; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>➖ Withdraw Funds</h1>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/savings">Back to Savings</a>
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            </div>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>

        <c:if test="${not empty account}">
            <div class="balance-display">
                <h3>Available Balance</h3>
                <div class="amount">KES ${account.balance}</div>
            </div>

            <div class="account-info">
                <p><strong>Account Number:</strong> ${account.accountNumber}</p>
                <p><strong>Account Holder:</strong> ${sessionScope.fullName}</p>
                <p><strong>Account Status:</strong> ${account.status}</p>
            </div>

            <div class="info-box">
                <p><strong>ℹ️ Important Information:</strong></p>
                <p>• Minimum withdrawal amount: KES 100</p>
                <p>• Maximum withdrawal amount: KES ${account.balance.subtract(account.minimumBalance)}</p>
                <p>• Daily withdrawal limit: KES ${account.dailyWithdrawalLimit}</p>
                <p>• Minimum balance to maintain: KES ${account.minimumBalance}</p>
                <p>• Withdrawals are processed instantly</p>
            </div>

            <form method="POST" action="${pageContext.request.contextPath}/savings">
                <input type="hidden" name="action" value="withdraw">
                <input type="hidden" name="accountId" value="${account.id}">
                
                <div class="form-group">
                    <label for="amount">Withdrawal Amount (KES) *</label>
                    <input type="number" id="amount" name="amount" step="0.01" min="100" max="${account.balance}" required 
                           placeholder="Enter amount to withdraw" autofocus>
                </div>

                <div class="form-group">
                    <label>Withdrawal Method *</label>
                    <div class="payment-methods">
                        <div class="payment-method">
                            <input type="radio" id="mpesa" name="paymentMethod" value="MPESA" checked>
                            <label for="mpesa">📱 M-Pesa</label>
                        </div>
                        <div class="payment-method">
                            <input type="radio" id="cash" name="paymentMethod" value="CASH">
                            <label for="cash">💵 Cash</label>
                        </div>
                        <div class="payment-method">
                            <input type="radio" id="bank" name="paymentMethod" value="BANK_TRANSFER">
                            <label for="bank">🏦 Bank Transfer</label>
                        </div>
                        <div class="payment-method">
                            <input type="radio" id="cheque" name="paymentMethod" value="CHEQUE">
                            <label for="cheque">📝 Cheque</label>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="transactionId">Transaction ID / Reference</label>
                        <input type="text" id="transactionId" name="transactionId" 
                               placeholder="e.g., M-Pesa code or bank reference">
                    </div>
                    <div class="form-group">
                        <label for="cardLastFour">Last 4 Digits (if card payment)</label>
                        <input type="text" id="cardLastFour" name="cardLastFour" maxlength="4" 
                               placeholder="XXXX">
                    </div>
                </div>

                <div class="form-group">
                    <label for="notes">Notes (Optional)</label>
                    <textarea id="notes" name="notes" placeholder="Add any additional notes about this withdrawal"></textarea>
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn">Confirm Withdrawal</button>
                    <a href="${pageContext.request.contextPath}/savings" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </c:if>
    </div>

    <script>
        // Highlight selected payment method
        document.querySelectorAll('.payment-method input').forEach(input => {
            input.addEventListener('change', function() {
                document.querySelectorAll('.payment-method').forEach(m => m.classList.remove('selected'));
                if (this.checked) {
                    this.closest('.payment-method').classList.add('selected');
                }
            });
        });
        // Initialize first selection
        document.querySelector('.payment-method input:checked').closest('.payment-method').classList.add('selected');
        
        // Set max attribute for amount input
        document.getElementById('amount').max = '${account.balance}';
    </script>
</body>
</html>