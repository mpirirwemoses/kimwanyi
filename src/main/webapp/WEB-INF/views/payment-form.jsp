<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.example.model.Loan" %>
<%@ page import="java.math.BigDecimal" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Make Payment | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
    <style>
        .payment-container { max-width: 640px; margin: 0 auto; padding: 40px 24px; }
        .payment-card { background: #fff; padding: 36px; border-radius: 14px; border: 1px solid var(--line); }
        .loan-summary { background: var(--background); padding: 20px; border-radius: 10px; margin-bottom: 24px; }
        .loan-summary h3 { margin: 0 0 12px; font-size: 1.1rem; }
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: .92rem; }
        .summary-row span:first-child { color: var(--muted); }
        .summary-row span:last-child { font-weight: 700; }
        .payment-methods { display: grid; gap: 12px; margin-bottom: 24px; }
        .payment-method { display: flex; align-items: center; gap: 12px; padding: 16px; border: 2px solid var(--line); border-radius: 10px; cursor: pointer; transition: all .15s; }
        .payment-method:hover { border-color: var(--primary); }
        .payment-method input[type="radio"] { width: 18px; height: 18px; accent-color: var(--primary); }
        .payment-method.selected { border-color: var(--primary); background: #f8fbf9; }
        .method-icon { width: 24px; height: 24px; color: var(--primary); }
        .method-info { flex: 1; }
        .method-name { font-weight: 700; font-size: .95rem; }
        .method-desc { font-size: .82rem; color: var(--muted); }
        .card-fields { display: none; margin-top: 16px; padding-top: 16px; border-top: 1px solid var(--line); }
        .card-fields.visible { display: block; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; margin-bottom: 6px; font-size: .9rem; font-weight: 700; }
        .form-group input { width: 100%; padding: 12px; border: 1px solid #b9cbc0; border-radius: 8px; font: inherit; }
        .form-group input:focus { border-color: var(--primary); outline: 3px solid #bfe5cf; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .amount-display { font-size: 1.5rem; font-weight: 800; color: var(--primary); text-align: center; margin: 20px 0; }
        .error-message { background: #fff0ed; color: #a33426; padding: 12px; border-radius: 8px; margin-bottom: 20px; font-size: .92rem; }
        .success-message { background: #e8f7ed; color: #0c6738; padding: 12px; border-radius: 8px; margin-bottom: 20px; font-size: .92rem; }
    </style>
</head>
<body>
    <div class="payment-container">
        <div class="payment-card">
            <h2 style="margin: 0 0 24px; font-size: 1.5rem;">Make a Payment</h2>

            <% if (request.getParameter("error") != null) { %>
                <div class="error-message"><%= request.getParameter("error") %></div>
            <% } %>

            <%
                Loan loan = (Loan) request.getAttribute("loan");
                BigDecimal outstanding = loan.getOutstandingBalance();
                BigDecimal minPayment = outstanding.divide(new BigDecimal("3"), 2, BigDecimal.ROUND_CEILING);
                if (minPayment.compareTo(new BigDecimal("100")) < 0) minPayment = new BigDecimal("100");
            %>

            <div class="loan-summary">
                <h3>Loan Details</h3>
                <div class="summary-row">
                    <span>Loan Reference</span>
                    <span><%= loan.getLoanReference() %></span>
                </div>
                <div class="summary-row">
                    <span>Purpose</span>
                    <span><%= loan.getPurpose() %></span>
                </div>
                <div class="summary-row">
                    <span>Total Repayable</span>
                    <span>KES <%= loan.getTotalRepayable() %></span>
                </div>
                <div class="summary-row">
                    <span>Outstanding Balance</span>
                    <span style="color: #a33426; font-weight: 800;">KES <%= outstanding %></span>
                </div>
                <div class="summary-row">
                    <span>Due Date</span>
                    <span><%= loan.getDueDateFormatted() != null && !loan.getDueDateFormatted().isEmpty() ? loan.getDueDateFormatted() : "-" %></span>
                </div>
            </div>

            <div class="amount-display">
                Paying: KES <%= request.getParameter("amount") != null ? request.getParameter("amount") : "0.00" %>
            </div>

            <form method="post" action="<%= request.getContextPath() %>/payments" id="paymentForm">
                <input type="hidden" name="loanId" value="<%= loan.getId() %>"/>

                <div class="form-group">
                    <label for="amount">Payment Amount (KES)</label>
                    <input type="number" id="amount" name="amount" step="0.01" min="<%= minPayment %>" max="<%= outstanding %>" value="<%= request.getParameter("amount") != null ? request.getParameter("amount") : minPayment %>" required/>
                    <small style="color: var(--muted); margin-top: 4px;">Minimum: KES <%= minPayment %> | Maximum: KES <%= outstanding %></small>
                </div>

                <div class="form-group">
                    <label>Payment Method</label>
                    <div class="payment-methods">
                        <label class="payment-method selected" data-method="MPESA">
                            <input type="radio" name="paymentMethod" value="MPESA" checked/>
                            <svg class="method-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>
                            <div class="method-info">
                                <div class="method-name">M-Pesa</div>
                                <div class="method-desc">Pay instantly with M-Pesa mobile money</div>
                            </div>
                        </label>
                        <label class="payment-method" data-method="CARD">
                            <input type="radio" name="paymentMethod" value="CARD"/>
                            <svg class="method-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
                            <div class="method-info">
                                <div class="method-name">Credit/Debit Card</div>
                                <div class="method-desc">Visa, Mastercard, or other major cards</div>
                            </div>
                        </label>
                        <label class="payment-method" data-method="BANK_TRANSFER">
                            <input type="radio" name="paymentMethod" value="BANK_TRANSFER"/>
                            <svg class="method-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z"/></svg>
                            <div class="method-info">
                                <div class="method-name">Bank Transfer</div>
                                <div class="method-desc">Direct bank to bank transfer</div>
                            </div>
                        </label>
                    </div>
                </div>

                <div class="card-fields" id="cardFields">
                    <div class="form-group">
                        <label for="cardNumber">Card Number</label>
                        <input type="text" id="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19"/>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="expiry">Expiry Date</label>
                            <input type="text" id="expiry" placeholder="MM/YY" maxlength="5"/>
                        </div>
                        <div class="form-group">
                            <label for="cvv">CVV</label>
                            <input type="text" id="cvv" placeholder="123" maxlength="3"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="cardLastFour">Last 4 Digits (for reference)</label>
                        <input type="text" id="cardLastFour" name="cardLastFour" placeholder="1234" maxlength="4"/>
                    </div>
                </div>

                <div class="form-group">
                    <label for="notes">Notes (Optional)</label>
                    <input type="text" id="notes" name="notes" placeholder="Add a note about this payment" maxlength="500"/>
                </div>

                <button type="submit" class="button" style="width: 100%; margin-top: 8px;">Process Payment</button>
            </form>
        </div>
    </div>

    <script>
        const paymentMethods = document.querySelectorAll('.payment-method');
        const cardFields = document.getElementById('cardFields');
        const amountInput = document.getElementById('amount');
        const amountDisplay = document.querySelector('.amount-display');

        paymentMethods.forEach(method => {
            method.addEventListener('click', function() {
                paymentMethods.forEach(m => m.classList.remove('selected'));
                this.classList.add('selected');
                this.querySelector('input[type="radio"]').checked = true;

                if (this.dataset.method === 'CARD') {
                    cardFields.classList.add('visible');
                } else {
                    cardFields.classList.remove('visible');
                }
            });
        });

        amountInput.addEventListener('input', function() {
            const value = parseFloat(this.value) || 0;
            amountDisplay.textContent = 'Paying: KES ' + value.toLocaleString('en-KE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        });
    </script>
</body>
</html>