<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="org.example.model.SavingsAccount" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Loan | Kimwanyi SACCO</title>
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

        /* Application Card */
        .application-container { max-width: 900px; margin: 0 auto; padding: 0; }
        .application-card { background: #fff; padding: 40px; border-radius: 14px; border: 1px solid #ecf0f1; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .form-section { margin-bottom: 32px; padding-bottom: 32px; border-bottom: 1px solid #ecf0f1; }
        .form-section:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
        .section-title { font-size: 1.15rem; font-weight: 700; margin-bottom: 20px; color: #2c3e50; }
        .form-grid { display: grid; gap: 20px; }
        .form-group { display: flex; flex-direction: column; gap: 8px; }
        .form-group label { font-size: .92rem; font-weight: 700; color: #2c3e50; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 12px 16px; border: 1px solid #b9cbc0; border-radius: 8px;
            font: inherit; font-size: .95rem; transition: all .15s; background: #fff;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: #27ae60; outline: 3px solid #bfe5cf;
        }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-hint { font-size: .82rem; color: #95a5a6; margin-top: 4px; }
        .amount-preview {
            background: linear-gradient(135deg, #e8f5ed 0%, #f0f9f4 100%);
            padding: 24px; border-radius: 12px; margin-bottom: 24px;
            border: 2px solid #27ae60;
        }
        .amount-preview-label { font-size: .85rem; color: #95a5a6; font-weight: 700; margin-bottom: 8px; }
        .amount-preview-value { font-size: 2rem; font-weight: 800; color: #27ae60; }
        .amount-preview-note { font-size: .85rem; color: #95a5a6; margin-top: 8px; }
        .info-box {
            background: #e8f5ed; border-left: 4px solid #27ae60;
            padding: 16px 20px; border-radius: 8px; margin-bottom: 24px;
        }
        .info-box-title { font-weight: 700; color: #229954; margin-bottom: 6px; font-size: .95rem; }
        .info-box-text { color: #155724; font-size: .88rem; line-height: 1.6; }
        .error-message { background: #fff0ed; color: #a33426; padding: 14px 18px; border-radius: 8px; margin-bottom: 24px; font-size: .92rem; }
        .button-group { display: flex; gap: 12px; margin-top: 32px; }
        .button-group .button { flex: 1; }
        .loan-purpose-examples { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; margin-top: 12px; }
        .purpose-example {
            padding: 10px 14px; background: #f8f9fa; border: 1px solid #ecf0f1;
            border-radius: 8px; font-size: .85rem; color: #7f8c8d; cursor: pointer;
            transition: all .15s;
        }
        .purpose-example:hover { border-color: #27ae60; color: #27ae60; background: #f8fbf9; }
        .savings-info { background: #f8f9fa; padding: 16px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #3498db; }
        .savings-info strong { color: #2c3e50; }

        @media (max-width: 768px) {
            .sidebar { width: 100%; position: relative; }
            .main-content { margin-left: 0; }
            .application-container { padding: 20px 16px; }
            .application-card { padding: 24px; }
            .form-row { grid-template-columns: 1fr; }
            .loan-purpose-examples { grid-template-columns: 1fr; }
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
            <h1>Apply for a Loan</h1>
            <div class="user-info">
                <span>Welcome, <strong><%= session.getAttribute("fullName") %></strong></span>
                <form method="post" action="<%= request.getContextPath() %>/logout" style="display: inline;">
                    <button type="submit" class="btn-logout">Logout</button>
                </form>
            </div>
        </div>

        <div class="application-container">
            <div class="application-card">
                <p style="color: #95a5a6; margin-bottom: 24px;">Fill in the details below to submit your loan application</p>

                <% if (request.getParameter("error") != null) { %>
                    <div class="error-message">
                        <strong>Error:</strong> <%= request.getParameter("error") %>
                    </div>
                <% } %>

                <%
                    BigDecimal savingsBalance = (BigDecimal) request.getAttribute("savingsBalance");
                    List<SavingsAccount> accounts = (List<SavingsAccount>) request.getAttribute("savingsAccounts");
                    String phoneNumber = (String) session.getAttribute("phoneNumber");
                    if (phoneNumber == null) phoneNumber = "";
                    if (savingsBalance == null) savingsBalance = BigDecimal.ZERO;
                    BigDecimal maxLoan = savingsBalance.multiply(new BigDecimal("3"));
                %>

                <div class="info-box">
                    <div class="info-box-title">💡 Loan Information</div>
                    <div class="info-box-text">
                        • Your savings balance: <strong>UGX <%= savingsBalance.toPlainString() %></strong><br>
                        • Maximum loan amount: <strong>UGX <%= maxLoan.toPlainString() %> (3x savings balance)</strong><br>
                        • Interest rate: <strong>10% flat rate of principal</strong><br>
                        • Repayment period: <strong>1-60 months</strong> (1 month to 5 years)<br>
                        • Minimum repayment: <strong>UGX 100</strong> or 1/3 of outstanding balance
                    </div>
                </div>

            <form method="post" action="<%= request.getContextPath() %>/loans" id="loanApplicationForm">
                <input type="hidden" name="action" value="apply"/>

                <div class="form-section">
                    <h2 class="section-title">Loan Details</h2>
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="amount">Loan Amount (UGX) *</label>
                            <input type="number" id="amount" name="amount" step="0.01" min="100" max="<%= maxLoan.longValue() %>" required placeholder="Enter amount in UGX"/>
                            <span class="form-hint">Enter the amount you need (minimum UGX 100, maximum UGX <%= maxLoan.toPlainString() %>)</span>
                        </div>

                        <div class="form-group">
                            <label for="purpose">Loan Purpose *</label>
                            <textarea id="purpose" name="purpose" maxlength="500" required placeholder="Describe what you need the loan for"></textarea>
                            <span class="form-hint">Maximum 500 characters</span>
                        </div>

                        <div class="form-group">
                            <label for="loanType">Type of Loan</label>
                            <select id="loanType" name="loanType">
                                <option value="PERSONAL">Personal</option>
                                <option value="BUSINESS">Business</option>
                                <option value="EMERGENCY">Emergency</option>
                                <option value="AGRICULTURE">Agriculture</option>
                            </select>
                            <span class="form-hint">Choose the loan type that best matches your purpose</span>
                        </div>

                        <div class="loan-purpose-examples">
                            <div class="purpose-example" onclick="setPurpose('Business expansion and inventory purchase')">🏪 Business expansion</div>
                            <div class="purpose-example" onclick="setPurpose('School fees payment for children')">🎓 School fees</div>
                            <div class="purpose-example" onclick="setPurpose('Home renovation and improvements')">🏠 Home renovation</div>
                            <div class="purpose-example" onclick="setPurpose('Medical expenses and healthcare')">🏥 Medical expenses</div>
                            <div class="purpose-example" onclick="setPurpose('Purchase of equipment or machinery')">⚙️ Equipment purchase</div>
                            <div class="purpose-example" onclick="setPurpose('Agricultural inputs and farming')">🌾 Agriculture</div>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h2 class="section-title">Repayment & Account</h2>
                    <div class="form-grid">
                        <div class="savings-info">
                            <strong>Select Savings Account</strong>
                            <select id="savingsAccountId" name="savingsAccountId" onchange="autoFillAccount()" style="width: 100%; padding: 10px; border: 1px solid #b9cbc0; border-radius: 8px; margin-top: 8px;">
                                <option value="">-- Select an account --</option>
                                <c:if test="${not empty savingsAccounts}">
                                    <c:forEach var="acc" items="${savingsAccounts}">
                                        <option value="${acc.id}" data-account-number="${acc.accountNumber}">${acc.accountNumber} - UGX ${acc.balance} (${acc.status})</option>
                                    </c:forEach>
                                </c:if>
                            </select>
                            <div style="font-size: .82rem; color: #95a5a6; margin-top: 6px;">Select a savings account to autofill payment fields below</div>
                        </div>

                        <div class="form-group">
                            <label for="accountNumber">Account Number (for bank transfers)</label>
                            <input type="text" id="accountNumber" name="accountNumber" value="" placeholder="Enter account number (optional)"/>
                            <span class="form-hint">Used when selecting bank transfer as payment mode</span>
                        </div>

                        <div class="form-group">
                            <label for="phoneNumber">Phone Number (for MPESA/Airtel)</label>
                            <input type="text" id="phoneNumber" name="phoneNumber" value="<%= phoneNumber != null ? phoneNumber : "" %>" placeholder="Enter phone number (optional)"/>
                            <span class="form-hint">Used when selecting MPESA, MTN, or Airtel as payment mode</span>
                        </div>

                        <div class="form-group">
                            <label for="repaymentMonths">Repayment Period (months)</label>
                            <input type="number" id="repaymentMonths" name="repaymentMonths" min="1" max="60" step="1" value="6" placeholder="Enter repayment months (e.g., 6)"/>
                            <span class="form-hint">Number of months over which you'll repay (1 month to 5 years / 60 months, default 6)</span>
                        </div>

                        <div class="form-group">
                            <label for="paymentMode">Preferred Payment Mode</label>
                            <select id="paymentMode" name="paymentMode">
                                <option value="MPESA">MPESA</option>
                                <option value="BANK_TRANSFER">Bank transfer</option>
                                <option value="CARD">Card</option>
                                <option value="CASH">Cash</option>
                            </select>
                            <span class="form-hint">Choose how you prefer to receive/repay the loan</span>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h2 class="section-title">Loan Rules & Guidance</h2>
                    <div style="background: transparent; padding: 0; border-left: none; color: #7f8c8d;">
                        <ul>
                            <li><strong>Personal:</strong> For household and personal expenses. Interest 10% p.a. Typical term 6 months - 2 years.</li>
                            <li><strong>Business:</strong> For working capital and inventory. Interest 10% p.a. Term 6 months - 2 years; may require additional verification.</li>
                            <li><strong>Emergency:</strong> Fast-tracked small loans for urgent needs. Higher fees may apply.</li>
                            <li><strong>Agriculture:</strong> For seasonal inputs and equipment. Terms may align to planting cycles.</li>
                        </ul>
                        <p class="form-hint">These are guidance rules; final terms are set at approval. Make sure purpose and repayment plan are realistic.</p>
                    </div>
                </div>

                <div class="amount-preview" id="amountPreview" style="display: none;">
                    <div class="amount-preview-label">Estimated Total Repayment (with 10% flat rate of principal)</div>
                    <div class="amount-preview-value" id="previewValue">UGX 0.00</div>
                    <div class="amount-preview-note">This is an estimate. Final amount will be calculated upon approval.</div>
                </div>

                <div class="button-group">
                    <a href="<%= request.getContextPath() %>/loans" class="button secondary" style="background: #95a5a6; color: white; text-align: center; padding: 12px 20px; border-radius: 8px; text-decoration: none; font-size: .95rem;">Cancel</a>
                    <button type="submit" class="button" style="background: #27ae60; color: white; padding: 12px 20px; border-radius: 8px; border: none; cursor: pointer; font-size: .95rem; font-weight: 600;">Submit Application</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        const amountInput = document.getElementById('amount');
        const purposeInput = document.getElementById('purpose');
        const amountPreview = document.getElementById('amountPreview');
        const previewValue = document.getElementById('previewValue');
        const maxInput = amountInput.getAttribute('max');
        const maxLoan = maxInput ? parseFloat(maxInput) : 0;

        function setPurpose(text) {
            purposeInput.value = text;
            purposeInput.focus();
        }

        function updatePreview() {
            let amount = parseFloat(amountInput.value) || 0;
            if (amount > maxLoan) amount = maxLoan;
            if (amount > 0) {
                const total = amount * 1.10;
                previewValue.textContent = 'UGX ' + total.toLocaleString('en-KE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                amountPreview.style.display = 'block';
            } else {
                amountPreview.style.display = 'none';
            }
        }

        function autoFillAccount() {
            const select = document.getElementById('savingsAccountId');
            const selectedOption = select.options[select.selectedIndex];
            const accountNumber = selectedOption.getAttribute('data-account-number') || '';
            if (accountNumber) {
                document.getElementById('accountNumber').value = accountNumber;
            }
        }

        amountInput.addEventListener('input', updatePreview);
        amountInput.addEventListener('blur', updatePreview);

        // Form validation
        document.getElementById('loanApplicationForm').addEventListener('submit', function(e) {
            const amount = parseFloat(amountInput.value);
            const purpose = purposeInput.value.trim();

            if (!amount || amount < 100) {
                alert('Please enter a valid loan amount (minimum UGX 100)');
                e.preventDefault();
                return false;
            }

            if (amount > maxLoan) {
                alert('Requested loan exceeds the maximum allowed amount of UGX ' + maxLoan);
                e.preventDefault();
                return false;
            }

            if (!purpose || purpose.length < 10) {
                alert('Please provide a detailed purpose for your loan (at least 10 characters)');
                e.preventDefault();
                return false;
            }

            return true;
        });
    </script>
</body>
</html>
