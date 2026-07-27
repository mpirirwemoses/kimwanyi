<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Loan Details | Kimwanyi SACCO</title>
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
        
        .action-buttons { display: flex; gap: 10px; margin-top: 20px; flex-wrap: wrap; }
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        
        .amount-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px; margin-bottom: 20px; text-align: center; }
        .amount-card h2 { font-size: 18px; margin-bottom: 10px; opacity: 0.9; }
        .amount-card .amount { font-size: 42px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 Loan Details "${pageContext.request.contextPath}"</h1>
            <a href="${pageContext.request.contextPath}/admin-dashboard?section=loans" class="btn btn-secondary">← Back to Loans</a>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Operation completed successfully!</div>
        </c:if>

        <c:if test="${not empty viewLoan}">
            <div class="amount-card">
                <h2>Loan Amount</h2>
                <div class="amount">UGX ${viewLoan.requestedAmount}</div>
            </div>

            <div class="details-section">
                <h2>Loan Information</h2>
                <div class="detail-row">
                    <span class="detail-label">Loan Reference:</span>
                    <span class="detail-value">${viewLoan.loanReference}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Loan ID:</span>
                    <span class="detail-value">${viewLoan.id}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Member Name:</span>
                    <span class="detail-value">${viewLoan.member.fullName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Member Email:</span>
                    <span class="detail-value">${viewLoan.member.email}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Purpose:</span>
                    <span class="detail-value">${viewLoan.purpose}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="badge badge-${viewLoan.status == 'PENDING' ? 'warning' : viewLoan.status == 'APPROVED' ? 'success' : 'danger'}">${viewLoan.status}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Applied Date:</span>
                    <span class="detail-value">${viewLoan.appliedAtFormatted}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Interest Rate:</span>
                    <span class="detail-value">${viewLoan.interestRate}%</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Payment Mode:</span>
                    <span class="detail-value">${viewLoan.paymentMode}</span>
                </div>
            </div>

            <c:if test="${not empty viewLoan.totalRepayable}">
                <div class="details-section">
                    <h2>Repayment Information</h2>
                    <div class="detail-row">
                        <span class="detail-label">Total Repayable:</span>
                        <span class="detail-value">UGX ${viewLoan.totalRepayable}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Outstanding Balance:</span>
                        <span class="detail-value">UGX ${viewLoan.outstandingBalance}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Due Date:</span>
                        <span class="detail-value">${viewLoan.dueDateFormatted}</span>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty viewLoan.reviewComment}">
                <div class="details-section">
                    <h2>Review Information</h2>
                    <div class="detail-row">
                        <span class="detail-label">Reviewed By:</span>
                        <span class="detail-value">${viewLoan.reviewedBy.fullName}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Reviewed At:</span>
                        <span class="detail-value">${viewLoan.reviewedAtFormatted}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Comment:</span>
                        <span class="detail-value">${viewLoan.reviewComment}</span>
                    </div>
                </div>
            </c:if>

            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=audit&module=loan" class="btn btn-info">📋 View Audit Trail</a>
                <c:if test="${viewLoan.status == 'PENDING'}">
                    <form action="${pageContext.request.contextPath}/admin-dashboard" method="POST" style="display: inline;" onsubmit="return confirm('Approve this loan?')">
                        <input type="hidden" name="action" value="approve-loan">
                        <input type="hidden" name="loanId" value="${viewLoan.id}">
                        <input type="hidden" name="section" value="loans">
                        <button type="submit" class="btn btn-success">✅ Approve Loan</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/admin-dashboard" method="POST" style="display: inline;" onsubmit="return confirm('Reject this loan?')">
                        <input type="hidden" name="action" value="reject-loan">
                        <input type="hidden" name="loanId" value="${viewLoan.id}">
                        <input type="hidden" name="section" value="loans">
                        <button type="submit" class="btn btn-danger">❌ Reject Loan</button>
                    </form>
                </c:if>
                
                <c:if test="${viewLoan.status == 'APPROVED' || viewLoan.status == 'OVERDUE'}">
                    <button type="button" class="btn btn-warning" onclick="showCashPaymentForm(${viewLoan.id})">Approve Cash Payment</button>
                </c:if>
                
                <form action="${pageContext.request.contextPath}/admin-dashboard" method="POST" style="display: inline;" id="statusChangeForm" onsubmit="return confirmStatusChange()">
                    <input type="hidden" name="action" value="change-loan-status">
                    <input type="hidden" name="loanId" value="${viewLoan.id}">
                    <input type="hidden" name="section" value="loans">
                    <input type="hidden" name="newStatus" id="newStatusInput" value="">
                    <select id="statusChangeSelect" onchange="document.getElementById('newStatusInput').value=this.value" style="padding: 10px; border: 1px solid #b9cbc0; border-radius: 4px; font: inherit;">
                        <option value="">Change Status To...</option>
                        <c:if test="${viewLoan.status != 'PENDING' && viewLoan.status != 'REJECTED' && viewLoan.status != 'CANCELLED' && viewLoan.status != 'REPAID'}">
                            <option value="APPROVED">Approved</option>
                        </c:if>
                        <c:if test="${viewLoan.status == 'APPROVED' || viewLoan.status == 'OVERDUE'}">
                            <option value="OVERDUE">Overdue</option>
                            <option value="REPAID">Repaid</option>
                        </c:if>
                        <c:if test="${viewLoan.status == 'PENDING'}">
                            <option value="CANCELLED">Cancelled</option>
                        </c:if>
                        <c:if test="${viewLoan.status == 'APPROVED'}">
                            <option value="CANCELLED">Cancelled</option>
                        </c:if>
                    </select>
                    <button type="submit" class="btn btn-secondary">Change Status</button>
                </form>
                
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=members&action=get-member&memberId=${viewLoan.member.id}" class="btn btn-info">👤 View Member</a>
            </div>
        </c:if>

        <c:if test="${empty viewLoan}">
            <div class="details-section">
                <p style="text-align: center; color: #7f8c8d; padding: 40px;">Loan not found or invalid loan ID.</p>
            </div>
            <div class="action-buttons" style="justify-content: center;">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=loans" class="btn btn-secondary">← Back to Loans</a>
            </div>
        </c:if>
</div>

    <!-- Cash Payment Modal -->
    <div id="cashPaymentModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; justify-content:center; align-items:center;">
        <div style="background:white; padding:30px; border-radius:8px; width:90%; max-width:500px; margin:auto; position:relative; top:50%; transform:translateY(-50%);">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                <h3 style="color:#2c3e50; margin:0;">💰 Cash Payment</h3>
                <button type="button" onclick="closeCashPaymentForm()" style="background:none; border:none; font-size:24px; cursor:pointer; color:#95a5a6;">&times;</button>
            </div>
            <form id="cashPaymentForm" action="${pageContext.request.contextPath}/admin-dashboard" method="POST" onsubmit="return confirmCashPayment(event)">
                <input type="hidden" name="action" value="approve-cash-payment">
                <input type="hidden" name="loanId" id="cashPaymentLoanId" value="">
                <input type="hidden" name="section" value="loans">
                
                <div style="background:#f8f9fa; padding:15px; border-radius:6px; margin-bottom:20px;">
                    <p style="margin:5px 0; color:#555;"><strong>Member:</strong> ${viewLoan.member.fullName}</p>
                    <p style="margin:5px 0; color:#555;"><strong>Loan Reference:</strong> ${viewLoan.loanReference}</p>
                    <p style="margin:5px 0; color:#555;"><strong>Outstanding:</strong> UGX ${viewLoan.outstandingBalance}</p>
                </div>
                
                <div style="margin-bottom:15px;">
                    <label style="display:block; margin-bottom:5px; color:#555; font-weight:500;">Payment Amount (UGX) *</label>
                    <input type="number" id="cashPaymentAmount" name="amount" step="0.01" 
                           value="${viewLoan.outstandingBalance}" required
                           style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px; font-size:14px;">
                </div>
                
                <div style="margin-bottom:15px;">
                    <label style="display:block; margin-bottom:5px; color:#555; font-weight:500;">Notes / Receipt Reference</label>
                    <textarea id="cashPaymentNotes" name="notes" rows="3" 
                              placeholder="Enter receipt number or notes about this cash payment..."
                              style="width:100%; padding:10px; border:1px solid #ddd; border-radius:4px; font-size:14px; resize:vertical;">Cash payment received at SACCO office</textarea>
                </div>
                
                <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:18px;">
                    <button type="button" class="btn btn-secondary" onclick="closeCashPaymentForm()">Cancel</button>
                    <button type="submit" class="btn btn-warning">Confirm Cash Payment</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function showCashPaymentForm(loanId) {
            document.getElementById('cashPaymentLoanId').value = loanId;
            document.getElementById('cashPaymentModal').style.display = 'block';
        }

        function closeCashPaymentForm() {
            document.getElementById('cashPaymentModal').style.display = 'none';
        }

        function confirmCashPayment(event) {
            var amount = document.getElementById('cashPaymentAmount').value;
            if (!amount || parseFloat(amount) <= 0) {
                alert('Please enter a valid payment amount greater than 0.');
                event.preventDefault();
                return false;
            }
            return confirm('Record cash payment of UGX ' + parseFloat(amount).toFixed(2) + ' for this loan?\n\nThis will create a payment record and update the loan balance.');
        }

        function confirmStatusChange() {
            var select = document.getElementById('statusChangeSelect');
            var newStatus = select.value;
            if (!newStatus) {
                alert('Please select a status to change to.');
                return false;
            }
            return confirm('Change loan status to ' + newStatus.toUpperCase() + '?');
        }
    </script>
</body>
</html>
