<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Loan | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
    <style>
        .application-container { max-width: 800px; margin: 0 auto; padding: 40px 24px; }
        .application-card { background: #fff; padding: 40px; border-radius: 14px; border: 1px solid var(--line); }
        .form-section { margin-bottom: 32px; padding-bottom: 32px; border-bottom: 1px solid var(--line); }
        .form-section:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
        .section-title { font-size: 1.15rem; font-weight: 700; margin-bottom: 20px; color: var(--ink); }
        .form-grid { display: grid; gap: 20px; }
        .form-group { display: flex; flex-direction: column; gap: 8px; }
        .form-group label { font-size: .92rem; font-weight: 700; color: var(--ink); }
        .form-group input, .form-group select, .form-group textarea { 
            width: 100%; padding: 12px 16px; border: 1px solid #b9cbc0; border-radius: 8px; 
            font: inherit; font-size: .95rem; transition: all .15s;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { 
            border-color: var(--primary); outline: 3px solid #bfe5cf; 
        }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-hint { font-size: .82rem; color: var(--muted); margin-top: 4px; }
        .amount-preview { 
            background: linear-gradient(135deg, #e8f5ed 0%, #f0f9f4 100%); 
            padding: 24px; border-radius: 12px; margin-bottom: 24px; 
            border: 2px solid var(--primary);
        }
        .amount-preview-label { font-size: .85rem; color: var(--muted); font-weight: 700; margin-bottom: 8px; }
        .amount-preview-value { font-size: 2rem; font-weight: 800; color: var(--primary); }
        .amount-preview-note { font-size: .85rem; color: var(--muted); margin-top: 8px; }
        .info-box { 
            background: #e3f2fd; border-left: 4px solid #1565c0; 
            padding: 16px 20px; border-radius: 8px; margin-bottom: 24px; 
        }
        .info-box-title { font-weight: 700; color: #1565c0; margin-bottom: 6px; font-size: .95rem; }
        .info-box-text { color: #0d47a1; font-size: .88rem; line-height: 1.5; }
        .error-message { background: #fff0ed; color: #a33426; padding: 14px 18px; border-radius: 8px; margin-bottom: 24px; font-size: .92rem; }
        .button-group { display: flex; gap: 12px; margin-top: 32px; }
        .button-group .button { flex: 1; }
        .loan-purpose-examples { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; margin-top: 12px; }
        .purpose-example { 
            padding: 10px 14px; background: var(--background); border: 1px solid var(--line); 
            border-radius: 8px; font-size: .85rem; color: var(--muted); cursor: pointer; 
            transition: all .15s;
        }
        .purpose-example:hover { border-color: var(--primary); color: var(--primary); background: #f8fbf9; }
        @media (max-width: 768px) {
            .application-container { padding: 20px 16px; }
            .application-card { padding: 24px; }
            .form-row { grid-template-columns: 1fr; }
            .loan-purpose-examples { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="application-container">
        <div class="application-card">
            <div style="margin-bottom: 32px;">
                <h1 style="font-size: 1.85rem; margin-bottom: 8px;">Apply for a Loan</h1>
                <p style="color: var(--muted); margin: 0;">Fill in the details below to submit your loan application</p>
            </div>

            <% if (request.getParameter("error") != null) { %>
                <div class="error-message">
                    <strong>Error:</strong> <%= request.getParameter("error") %>
                </div>
            <% } %>

            <div class="info-box">
                <div class="info-box-title">💡 Loan Information</div>
                <div class="info-box-text">
                    • Interest rate: <strong>10%</strong> per annum<br>
                    • Maximum loan amount: <strong>3x</strong> your savings balance<br>
                    • Repayment period: <strong>6 months</strong><br>
                    • Minimum repayment: <strong>KES 100</strong> or 1/3 of outstanding balance
                </div>
            </div>

            <form method="post" action="<%= request.getContextPath() %>/loans" id="loanApplicationForm">
                <input type="hidden" name="action" value="apply"/>

                <div class="form-section">
                    <h2 class="section-title">Loan Details</h2>
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="amount">Loan Amount (KES) *</label>
                            <input type="number" id="amount" name="amount" step="0.01" min="100" max="1000000" required placeholder="Enter amount in KES"/>
                            <span class="form-hint">Enter the amount you need (minimum KES 100)</span>
                        </div>

                        <div class="form-group">
                            <label for="purpose">Loan Purpose *</label>
                            <textarea id="purpose" name="purpose" maxlength="500" required placeholder="Describe what you need the loan for"></textarea>
                            <span class="form-hint">Maximum 500 characters</span>
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

                <div class="amount-preview" id="amountPreview" style="display: none;">
                    <div class="amount-preview-label">Estimated Total Repayment (with 10% interest)</div>
                    <div class="amount-preview-value" id="previewValue">KES 0.00</div>
                    <div class="amount-preview-note">This is an estimate. Final amount will be calculated upon approval.</div>
                </div>

                <div class="button-group">
                    <a href="<%= request.getContextPath() %>/loans" class="button secondary">Cancel</a>
                    <button type="submit" class="button">Submit Application</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        const amountInput = document.getElementById('amount');
        const purposeInput = document.getElementById('purpose');
        const amountPreview = document.getElementById('amountPreview');
        const previewValue = document.getElementById('previewValue');

        function setPurpose(text) {
            purposeInput.value = text;
            purposeInput.focus();
        }

        function updatePreview() {
            const amount = parseFloat(amountInput.value) || 0;
            if (amount > 0) {
                const total = amount * 1.10;
                previewValue.textContent = 'KES ' + total.toLocaleString('en-KE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                amountPreview.style.display = 'block';
            } else {
                amountPreview.style.display = 'none';
            }
        }

        amountInput.addEventListener('input', updatePreview);
        amountInput.addEventListener('blur', updatePreview);

        // Form validation
        document.getElementById('loanApplicationForm').addEventListener('submit', function(e) {
            const amount = parseFloat(amountInput.value);
            const purpose = purposeInput.value.trim();

            if (!amount || amount < 100) {
                alert('Please enter a valid loan amount (minimum KES 100)');
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