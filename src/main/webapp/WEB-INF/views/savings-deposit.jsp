<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Make Deposit - Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .nav-links a { margin-left: 15px; text-decoration: none; color: #3498db; font-weight: bold; }
        .nav-links a:hover { color: #2980b9; }
        .alert { padding: 12px; margin-bottom: 20px; border-radius: 4px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
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
            display: inline-block; padding: 15px 30px; background: #27ae60; color: white; 
            text-decoration: none; border-radius: 6px; text-align: center; font-weight: bold; 
            border: none; cursor: pointer; font-size: 16px; 
        }
        .btn:hover { background: #229954; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        .account-info { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 25px; }
        .account-info p { margin: 5px 0; color: #555; }
        .account-info strong { color: #2c3e50; }
        .balance-display { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; margin-bottom: 25px; text-align: center; }
        .balance-display h3 { font-size: 14px; opacity: 0.9; margin-bottom: 10px; }
        .balance-display .amount { font-size: 32px; font-weight: bold; }
        .payment-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 20px; }
        .payment-method { 
            padding: 20px; border: 2px solid #ddd; border-radius: 6px; text-align: center; 
            cursor: pointer; transition: all 0.3s;
        }
        .payment-method:hover { border-color: #3498db; }
        .payment-method.selected { border-color: #27ae60; background: #d4edda; }
        .payment-method input { display: none; }
        .payment-method label { cursor: pointer; font-weight: bold; color: #2c3e50; display: block; }
        .payment-method .icon { font-size: 24px; margin-bottom: 8px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }
        .card-fields { display: none; background: #f8f9fa; padding: 20px; border-radius: 6px; margin-top: 15px; }
        .card-fields.active { display: block; }
        .mpesa-fields { display: none; background: #f8f9fa; padding: 20px; border-radius: 6px; margin-top: 15px; }
        .mpesa-fields.active { display: block; }
        .info-box { background: #e3f2fd; border-left: 4px solid #2196f3; padding: 15px; margin-bottom: 20px; border-radius: 4px; }
        .info-box p { margin: 5px 0; color: #555; }
        .info-box strong { color: #1976d2; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>➕ Make Deposit</h1>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/savings${account.id != null ? '?accountId='.concat(account.id) : ''}">Back to Savings</a>
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            </div>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>

        <c:if test="${not empty account}">
            <div class="balance-display">
                <h3>Current Balance</h3>
                <div class="amount">KES ${account.balance}</div>
            </div>

            <div class="account-info">
                <p><strong>Account Number:</strong> ${account.accountNumber}</p>
                <p><strong>Account Holder:</strong> ${sessionScope.fullName}</p>
                <p><strong>Account Status:</strong> ${account.status}</p>
            </div>

            <div class="info-box">
                <p><strong>ℹ️ Deposit Information:</strong></p>
                <p>• Minimum deposit amount: KES 100</p>
                <p>• Maximum deposit per transaction: KES 500,000</p>
                <p>• Deposits are processed instantly</p>
            </div>

            <form method="POST" action="${pageContext.request.contextPath}/savings">
                <input type="hidden" name="action" value="deposit">
                <input type="hidden" name="accountId" value="${account.id}">
                
                <div class="form-group">
                    <label for="amount">Deposit Amount (KES) *</label>
                    <input type="number" id="amount" name="amount" step="0.01" min="100" max="500000" required 
                           placeholder="Enter amount to deposit" autofocus>
                </div>

                <div class="form-group">
                    <label>Payment Method *</label>
                    <div class="payment-methods">
                        <div class="payment-method" onclick="selectPaymentMethod(this, 'mpesa')">
                            <input type="radio" id="mpesa" name="paymentMethod" value="MPESA" checked>
                            <div class="icon">📱</div>
                            <label for="mpesa">M-Pesa</label>
                        </div>
                        <div class="payment-method" onclick="selectPaymentMethod(this, 'card')">
                            <input type="radio" id="card" name="paymentMethod" value="CARD">
                            <div class="icon">💳</div>
                            <label for="card">Credit/Debit Card</label>
                        </div>
                        <div class="payment-method" onclick="selectPaymentMethod(this, 'bank')">
                            <input type="radio" id="bank" name="paymentMethod" value="BANK_TRANSFER">
                            <div class="icon">🏦</div>
                            <label for="bank">Bank Transfer</label>
                        </div>
                    </div>
                </div>

                <!-- M-Pesa Fields -->
                <div id="mpesaFields" class="mpesa-fields active">
                    <div class="form-group">
                        <label for="mpesaCode">M-Pesa Transaction Code *</label>
                        <input type="text" id="mpesaCode" name="transactionId" 
                               placeholder="e.g., SFE8X7Y9" maxlength="20">
                    </div>
                    <div class="form-group">
                        <label for="mpesaPhone">Phone Number Used *</label>
                        <input type="tel" id="mpesaPhone" name="mpesaPhone" 
                               placeholder="e.g., 254712345678" maxlength="13">
                    </div>
                </div>

                <!-- Card Fields -->
                <div id="cardFields" class="card-fields">
                    <div class="form-group">
                        <label for="cardNumber">Card Number *</label>
                        <input type="text" id="cardNumber" name="cardNumber" 
                               placeholder="1234 5678 9012 3456" maxlength="19">
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="expiryDate">Expiry Date *</label>
                            <input type="text" id="expiryDate" name="expiryDate" 
                                   placeholder="MM/YY" maxlength="5">
                        </div>
                        <div class="form-group">
                            <label for="cvv">CVV *</label>
                            <input type="text" id="cvv" name="cvv" 
                                   placeholder="123" maxlength="3">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="cardLastFour">Last 4 Digits of Card *</label>
                        <input type="text" id="cardLastFour" name="cardLastFour" 
                               placeholder="XXXX" maxlength="4">
                    </div>
                </div>

                <!-- Bank Transfer Fields -->
                <div id="bankFields" class="mpesa-fields">
                    <div class="form-group">
                        <label for="bankReference">Bank Reference Number *</label>
                        <input type="text" id="bankReference" name="transactionId" 
                               placeholder="e.g., TXN123456789">
                    </div>
                    <div class="form-group">
                        <label for="bankName">Bank Name *</label>
                        <select id="bankName" name="bankName">
                            <option value="">Select Bank</option>
                            <option value="KCB">KCB Bank</option>
                            <option value="Equity">Equity Bank</option>
                            <option value="Coop">Co-operative Bank</option>
                            <option value="Barclays">Absa Bank</option>
                            <option value="Stanbic">Stanbic Bank</option>
                            <option value="NCBA">NCBA Bank</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="notes">Notes (Optional)</label>
                    <textarea id="notes" name="notes" placeholder="Add any additional notes about this deposit"></textarea>
                </div>

                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn">Confirm Deposit</button>
                    <a href="${pageContext.request.contextPath}/savings${account.id != null ? '?accountId=' + account.id : ''}" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </c:if>
    </div>

    <script>
        function selectPaymentMethod(element, method) {
            // Remove selected class from all payment methods
            document.querySelectorAll('.payment-method').forEach(m => m.classList.remove('selected'));
            // Add selected class to clicked element
            element.classList.add('selected');
            // Check the radio button
            element.querySelector('input[type="radio"]').checked = true;
            
            // Hide all conditional fields
            document.getElementById('mpesaFields').classList.remove('active');
            document.getElementById('cardFields').classList.remove('active');
            document.getElementById('bankFields').classList.remove('active');
            
            // Show relevant fields
            if (method === 'mpesa') {
                document.getElementById('mpesaFields').classList.add('active');
            } else if (method === 'card') {
                document.getElementById('cardFields').classList.add('active');
            } else if (method === 'bank') {
                document.getElementById('bankFields').classList.add('active');
            }
        }

        // Format card number input
        document.getElementById('cardNumber')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s/g, '');
            let formatted = value.match(/.{1,4}/g)?.join(' ') || value;
            e.target.value = formatted;
        });

        // Format expiry date
        document.getElementById('expiryDate')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            e.target.value = value;
        });

        // Format CVV (numbers only)
        document.getElementById('cvv')?.addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '');
        });

        // Initialize first selection
        document.querySelector('.payment-method input:checked')?.closest('.payment-method').classList.add('selected');
    </script>
</body>
</html>