<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Interest Calculation - Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .nav-links a { margin-left: 15px; text-decoration: none; color: #3498db; font-weight: bold; }
        .nav-links a:hover { color: #2980b9; }
        .alert { padding: 12px; margin-bottom: 20px; border-radius: 4px; }
        .alert-info { background-color: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .calculation-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px; margin-bottom: 30px; text-align: center; }
        .calculation-card h2 { font-size: 18px; margin-bottom: 15px; opacity: 0.9; }
        .calculation-card .amount { font-size: 48px; font-weight: bold; margin-bottom: 10px; }
        .calculation-card .label { font-size: 14px; opacity: 0.9; }
        .details-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .details-section h3 { color: #2c3e50; margin-bottom: 15px; font-size: 20px; }
        .detail-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #ddd; }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { color: #555; font-weight: 500; }
        .detail-value { color: #2c3e50; font-weight: bold; }
        .detail-value.positive { color: #27ae60; }
        .formula-box { background: #fff3cd; border: 1px solid #ffc107; padding: 15px; border-radius: 6px; margin-top: 15px; }
        .formula-box h4 { color: #856404; margin-bottom: 10px; }
        .formula-box code { display: block; color: #856404; font-family: 'Courier New', monospace; line-height: 1.6; }
        .btn { display: inline-block; padding: 12px 24px; background: #3498db; color: white; text-decoration: none; border-radius: 6px; text-align: center; font-weight: bold; border: none; cursor: pointer; font-size: 16px; margin: 5px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .action-buttons { margin-top: 30px; text-align: center; }
        .info-box { background: #d1ecf1; border: 1px solid #bee5eb; padding: 15px; border-radius: 6px; margin-bottom: 20px; color: #0c5460; }
        .info-box strong { color: #0c5460; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📈 Interest Calculation</h1>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/savings">Back to Savings</a>
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            </div>
        </div>

        <c:if test="${not empty account}">
            <div class="info-box">
                <strong>ℹ️ Information:</strong> This is a preview of the interest that will be calculated. 
                Interest is calculated automatically on a monthly basis and will be applied to your account automatically.
                You cannot apply interest manually.
            </div>

            <div class="calculation-card">
                <h2>Projected Interest Earnings</h2>
                <div class="amount">UGX <fmt:formatNumber value="${calculatedInterest}" minFractionDigits="2" maxFractionDigits="2" /></div>
                <div class="label">Monthly Interest at <fmt:formatNumber value="${interestRate}" minFractionDigits="2" maxFractionDigits="2" />% per annum</div>
            </div>

            <div class="details-section">
                <h3>Calculation Details</h3>
                <div class="detail-row">
                    <span class="detail-label">Current Balance:</span>
                    <span class="detail-value">UGX <fmt:formatNumber value="${currentBalance}" minFractionDigits="2" maxFractionDigits="2" /></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Interest Rate:</span>
                    <span class="detail-value"><fmt:formatNumber value="${interestRate}" minFractionDigits="2" maxFractionDigits="2" />% per annum</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Monthly Rate:</span>
                    <span class="detail-value"><fmt:formatNumber value="${interestRate / 12}" minFractionDigits="2" maxFractionDigits="4" />% per month</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Calculated Interest:</span>
                    <span class="detail-value positive">+ UGX <fmt:formatNumber value="${calculatedInterest}" minFractionDigits="2" maxFractionDigits="2" /></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Projected Balance After Interest:</span>
                    <span class="detail-value positive">UGX <fmt:formatNumber value="${projectedBalance}" minFractionDigits="2" maxFractionDigits="2" /></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Last Interest Calculation:</span>
                    <span class="detail-value">
                        <c:choose>
                            <c:when test="${not empty lastInterestCalculation}">
                                ${lastInterestCalculation}
                            </c:when>
                            <c:otherwise>
                                Never
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>

            <div class="details-section">
                <h3>How Interest is Calculated</h3>
                <p style="color: #555; margin-bottom: 15px; line-height: 1.6;">
                    Interest is calculated using simple interest formula on a monthly basis. 
                    The calculation is performed automatically by the system every month.
                </p>
                <div class="formula-box">
                    <h4>Formula:</h4>
                    <code>
                        Monthly Interest = Current Balance × (Annual Rate ÷ 12 ÷ 100)<br><br>
                        Example:<br>
                        Balance: UGX <fmt:formatNumber value="${currentBalance}" minFractionDigits="2" maxFractionDigits="2" /><br>
                        Annual Rate: <fmt:formatNumber value="${interestRate}" minFractionDigits="2" maxFractionDigits="2" />%<br>
                        Monthly Rate: <fmt:formatNumber value="${interestRate}" minFractionDigits="2" maxFractionDigits="2" />% ÷ 12 = <fmt:formatNumber value="${interestRate / 12}" minFractionDigits="2" maxFractionDigits="4" />%<br>
                        Interest = UGX <fmt:formatNumber value="${currentBalance}" minFractionDigits="2" maxFractionDigits="2" /> × (<fmt:formatNumber value="${interestRate}" minFractionDigits="2" maxFractionDigits="2" />% ÷ 12 ÷ 100) = UGX <fmt:formatNumber value="${calculatedInterest}" minFractionDigits="2" maxFractionDigits="2" />
                    </code>
                </div>
            </div>

            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/savings" class="btn btn-success">← Back to Savings</a>
                <a href="${pageContext.request.contextPath}/savings?action=deposit" class="btn">➕ Make Deposit</a>
                <a href="${pageContext.request.contextPath}/savings?action=withdraw" class="btn btn-warning">➖ Withdraw</a>
            </div>
        </c:if>

        <c:if test="${empty account}">
            <div class="alert alert-info">
                <strong>No Account Selected</strong><br>
                Please select a savings account to view interest calculation.
            </div>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/savings" class="btn btn-success">← Back to Savings</a>
            </div>
        </c:if>
    </div>
</body>
</html>