<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Make Deposit | Kimwanyi SACCO</title>
    <style>
        :root {
            --gray-50: #fafafa; --gray-100: #f5f5f5; --gray-200: #e5e7eb; --gray-300: #d1d5db;
            --gray-400: #9ca3af; --gray-500: #6b7280; --gray-600: #4b5563; --gray-700: #374151;
            --gray-800: #1f2937; --gray-900: #111827;
            --green-500: #27ae60; --green-600: #229954; --green-50: #ecfdf5;
            --sidebar-bg: #1e293b; --sidebar-hover: #334155;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; font-size: 16px; line-height: 1.5; }
        body { background-color: var(--gray-100); display: flex; min-height: 100vh; color: var(--gray-700); }
        .sidebar { width: 260px; background: var(--sidebar-bg); color: white; padding: 20px 0; position: fixed; height: 100vh; overflow-y: auto; }
        .sidebar-header { padding: 0 20px 20px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 20px; }
        .sidebar-header h2 { font-size: 18px; font-weight: 700; }
        .sidebar-header p { font-size: 13px; color: var(--gray-400); margin-top: 4px; }
        .nav-menu { list-style: none; }
        .nav-item { margin-bottom: 4px; }
        .nav-link { display: flex; align-items: center; padding: 12px 20px; color: #e2e8f0; text-decoration: none; transition: all 0.2s; border-radius: 0 6px 6px 0; }
        .nav-link:hover, .nav-link.active { background: var(--sidebar-hover); border-left: 3px solid var(--green-500); }
        .nav-link .icon { margin-right: 10px; font-size: 17px; }
        .nav-section { padding: 15px 20px 5px; font-size: 11px; text-transform: uppercase; color: var(--gray-400); font-weight: 600; letter-spacing: 0.5px; }
        .main-content { flex: 1; margin-left: 260px; padding: 32px; overflow-y: auto; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; }
        .page-header h1 { color: var(--gray-800); font-size: 26px; font-weight: 700; }
        .user-info { display: flex; align-items: center; gap: 16px; }
        .user-info span { color: var(--gray-500); font-size: 15px; }
        .btn-logout { padding: 8px 18px; background: var(--gray-600); color: white; border-radius: 6px; font-size: 14px; border: none; cursor: pointer; transition: background 0.2s; }
        .btn-logout:hover { background: var(--gray-700); }
        .container { max-width: 800px; margin: 0 auto; }
        .card { background: white; padding: 28px; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 24px; }
        .card-header { margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid var(--gray-200); }
        .card-header h2 { color: var(--gray-800); font-size: 20px; font-weight: 600; }
        .alert { padding: 14px 18px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; }
        .alert-success { background-color: #dcfce7; color: #166534; border: 1px solid #86efac; }
        .alert-error { background-color: #fee2e2; color: #991b2b; border: 1px solid #fca5a5; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: var(--gray-700); font-weight: 600; font-size: 14px; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 12px 14px; border: 1px solid var(--gray-300); border-radius: 8px;
            font-size: 15px; transition: border-color 0.2s; background: white;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline: none; border-color: var(--green-500); }
        .form-group textarea { resize: vertical; min-height: 80px; }
        .btn { display: inline-block; padding: 14px 28px; background: var(--green-500); color: white; border-radius: 8px; font-weight: 600; border: none; cursor: pointer; font-size: 15px; transition: background 0.2s; }
        .btn:hover { background: var(--green-600); }
        .btn-secondary { background: var(--gray-500); }
        .btn-secondary:hover { background: var(--gray-600); }
        .account-info { background: var(--gray-50); padding: 18px; border-radius: 8px; margin-bottom: 24px; border: 1px solid var(--gray-200); }
        .account-info p { margin: 6px 0; color: var(--gray-600); font-size: 14px; }
        .account-info strong { color: var(--gray-800); font-weight: 600; }
        .balance-card { background: linear-gradient(135deg, var(--green-500) 0%, var(--green-600) 100%); color: white; padding: 32px; border-radius: 12px; margin-bottom: 24px; text-align: center; }
        .balance-card h3 { font-size: 15px; opacity: 0.9; margin-bottom: 12px; font-weight: 500; }
        .balance-card .amount { font-size: 36px; font-weight: 700; }
        .payment-methods { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin-bottom: 20px; }
        .payment-method { padding: 20px; border: 2px solid var(--gray-200); border-radius: 8px; text-align: center; cursor: pointer; transition: all 0.2s; }
        .payment-method:hover { border-color: var(--green-500); }
        .payment-method.selected { border-color: var(--green-500); background: var(--green-50); }
        .payment-method input { display: none; }
        .payment-method label { cursor: pointer; font-weight: 600; color: var(--gray-700); display: block; margin-bottom: 6px; }
        .payment-method .icon { font-size: 24px; margin-bottom: 6px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }
        .form-fields { display: none; background: var(--gray-50); padding: 20px; border-radius: 8px; margin-top: 16px; border: 1px solid var(--gray-200); }
        .form-fields.active { display: block; }
        .info-box { background: var(--green-50); border-left: 4px solid var(--green-500); padding: 16px; margin-bottom: 24px; border-radius: 0 8px 8px 0; }
        .info-box p { margin: 6px 0; color: var(--gray-600); font-size: 14px; }
        .info-box strong { color: var(--green-600); font-weight: 600; }
        @media (max-width: 768px) { .sidebar { width: 100%; position: relative; } .main-content { margin-left: 0; } }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-header"><h2>🏛️ Kimwanyi SACCO</h2><p>Member Portal</p></div>
        <ul class="nav-menu">
            <li class="nav-section">Main Menu</li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/dashboard" class="nav-link"><span class="icon">📊</span> Dashboard</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/loans" class="nav-link"><span class="icon">📋</span> My Loans</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/payments?action=history" class="nav-link"><span class="icon">💳</span> Payment History</a></li>
            <li class="nav-section">Services</li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/loans?action=apply" class="nav-link"><span class="icon">➕</span> Apply for Loan</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/savings" class="nav-link"><span class="icon">💰</span> My Savings</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/savings?action=deposit" class="nav-link active"><span class="icon">➕</span> Make Deposit</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/savings?action=withdraw" class="nav-link"><span class="icon">➖</span> Withdraw</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/savings?action=calculate-interest" class="nav-link"><span class="icon">📈</span> Calculate Interest</a></li>
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
    <main class="main-content">
        <div class="page-header">
            <h1>➕ Make Deposit</h1>
            <div class="user-info">
                <span>Welcome, <strong><%= session.getAttribute("fullName") %></strong></span>
                <form method="post" action="<%= request.getContextPath() %>/logout" style="display: inline;">
                    <button type="submit" class="btn-logout">Logout</button>
                </form>
            </div>
        </div>
        <div class="container">
            <c:if test="${not empty param.error}"><div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div></c:if>
            <c:if test="${not empty account}">
                <div class="balance-card">
                    <h3>Current Balance</h3>
                    <div class="amount">UGX ${account.balance}</div>
                </div>
                <div class="account-info">
                    <p><strong>Account Number:</strong> ${account.accountNumber}</p>
                    <p><strong>Account Holder:</strong> ${sessionScope.fullName}</p>
                    <p><strong>Account Status:</strong> ${account.status}</p>
                </div>
                <div class="info-box">
                    <p><strong>ℹ️ Deposit Information:</strong></p>
                    <p>• Minimum deposit amount: UGX 100</p>
                    <p>• Maximum deposit per transaction: UGX 500,000</p>
                    <p>• Deposits are processed instantly</p>
                </div>
                <div class="card">
                    <div class="card-header"><h2>Deposit Details</h2></div>
                    <form method="POST" action="${pageContext.request.contextPath}/savings">
                        <input type="hidden" name="action" value="deposit">
                        <input type="hidden" name="accountId" value="${account.id}">
                        <div class="form-group">
                            <label for="amount">Deposit Amount (UGX) *</label>
                            <input type="number" id="amount" name="amount" step="0.01" min="100" max="500000" required placeholder="Enter amount to deposit" autofocus>
                        </div>
                        <div class="form-group">
                            <label>Payment Method *</label>
                            <div class="payment-methods">
                                <div class="payment-method" onclick="selectPaymentMethod(this, 'mpesa')">
                                    <input type="radio" id="mpesa" name="paymentMethod" value="MPESA" checked>
                                    <div class="icon">📱</div><label for="mpesa">M-Pesa</label>
                                </div>
                                <div class="payment-method" onclick="selectPaymentMethod(this, 'card')">
                                    <input type="radio" id="card" name="paymentMethod" value="CARD">
                                    <div class="icon">💳</div><label for="card">Card</label>
                                </div>
                                <div class="payment-method" onclick="selectPaymentMethod(this, 'bank')">
                                    <input type="radio" id="bank" name="paymentMethod" value="BANK_TRANSFER">
                                    <div class="icon">🏦</div><label for="bank">Bank Transfer</label>
                                </div>
                            </div>
                        </div>
                        <div id="mpesaFields" class="form-fields active">
                            <div class="form-group">
                                <label for="mpesaPhone">Phone Number *</label>
                                <input type="tel" id="mpesaPhone" name="mpesaPhone" value="<%= session.getAttribute("phoneNumber") != null ? session.getAttribute("phoneNumber") : "" %>" placeholder="e.g., 254712345678" maxlength="13">
                            </div>
                            <div class="form-group">
                                <label for="mpesaCode">M-Pesa Transaction Code *</label>
                                <input type="text" id="mpesaCode" name="transactionId" placeholder="e.g., SFE8X7Y9" maxlength="20">
                            </div>
                        </div>
                        <div id="cardFields" class="form-fields">
                            <div class="form-group">
                                <label for="cardNumber">Card Number *</label>
                                <input type="text" id="cardNumber" name="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="expiryDate">Expiry Date *</label>
                                    <input type="text" id="expiryDate" name="expiryDate" placeholder="MM/YY" maxlength="5">
                                </div>
                                <div class="form-group">
                                    <label for="cvv">CVV *</label>
                                    <input type="text" id="cvv" name="cvv" placeholder="123" maxlength="3">
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="cardLastFour">Last 4 Digits of Card *</label>
                                <input type="text" id="cardLastFour" name="cardLastFour" placeholder="XXXX" maxlength="4">
                            </div>
                        </div>
                        <div id="bankFields" class="form-fields">
                            <div class="form-group">
                                <label for="bankReference">Bank Reference Number *</label>
                                <input type="text" id="bankReference" name="transactionId" placeholder="e.g., TXN123456789">
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
                        <div style="display: flex; gap: 12px;">
                            <button type="submit" class="btn">Confirm Deposit</button>
                            <a href="${pageContext.request.contextPath}/savings?accountId=${account.id}" class="btn btn-secondary">Cancel</a>
                        </div>
                    </form>
                </div>
            </c:if>
        </div>
    </main>
    <script>
        function selectPaymentMethod(element, method) {
            document.querySelectorAll('.payment-method').forEach(m => m.classList.remove('selected'));
            element.classList.add('selected');
            element.querySelector('input[type="radio"]').checked = true;
            document.getElementById('mpesaFields').classList.remove('active');
            document.getElementById('cardFields').classList.remove('active');
            document.getElementById('bankFields').classList.remove('active');
            if (method === 'mpesa') document.getElementById('mpesaFields').classList.add('active');
            else if (method === 'card') document.getElementById('cardFields').classList.add('active');
            else if (method === 'bank') document.getElementById('bankFields').classList.add('active');
        }
        document.getElementById('cardNumber')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s/g, '');
            let formatted = value.match(/.{1,4}/g)?.join(' ') || value;
            e.target.value = formatted;
        });
        document.getElementById('expiryDate')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) value = value.substring(0, 2) + '/' + value.substring(2, 4);
            e.target.value = value;
        });
        document.getElementById('cvv')?.addEventListener('input', function(e) { e.target.value = e.target.value.replace(/\D/g, ''); });
        if (document.querySelector('.payment-method input:checked')) {
            document.querySelector('.payment-method input:checked').closest('.payment-method').classList.add('selected');
        }
    </script>
</body>
</html>
