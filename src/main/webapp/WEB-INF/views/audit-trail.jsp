<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Trail | Kimwanyi SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 1400px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .btn { padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; }
        .btn:hover { background: #2980b9; }
        .filter-bar { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .filter-row { display: flex; gap: 15px; flex-wrap: wrap; align-items: center; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-group label { font-size: 12px; color: #555; font-weight: 600; text-transform: uppercase; }
        .filter-group select, .filter-group input { padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; min-width: 200px; }
        .filter-group input { min-width: 250px; }
        .stats-bar { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 20px; }
        .stat-box { background: #f8f9fa; padding: 15px; border-radius: 6px; border-left: 4px solid #3498db; }
        .stat-box.loans { border-left-color: #f39c12; }
        .stat-box.payments { border-left-color: #27ae60; }
        .stat-box.members { border-left-color: #9b59b6; }
        .stat-label { font-size: 12px; color: #555; text-transform: uppercase; font-weight: 600; }
        .stat-value { font-size: 24px; color: #2c3e50; font-weight: bold; margin-top: 5px; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #2c3e50; color: white; padding: 12px; text-align: left; font-weight: 600; font-size: 14px; }
        td { padding: 12px; border-bottom: 1px solid #ecf0f1; color: #555; }
        tr:hover { background: #f8f9fa; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
        .badge-loan { background: #fff3cd; color: #856404; }
        .badge-payment { background: #d1e7dd; color: #0f5132; }
        .badge-member { background: #d1ecf1; color: #0c5460; }
        .badge-system { background: #e2e3e5; color: #41464b; }
        .badge-other { background: #f8d7da; color: #721c24; }
        .empty-state { text-align: center; padding: 40px; color: #95a5a6; }
        .timestamp { font-size: 12px; color: #777; white-space: nowrap; }
        .user-cell { font-weight: 500; }
        .details-cell { max-width: 400px; }
        .action-links { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 10px; }
        .quick-filter { padding: 6px 12px; background: white; border: 1px solid #ddd; border-radius: 4px; font-size: 12px; cursor: pointer; text-decoration: none; color: #555; }
        .quick-filter:hover { background: #f8f9fa; }
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        .back-link:hover { color: #2980b9; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 Audit Trail</h1>
            <div>
                <a href="<%= request.getContextPath() %>/admin-dashboard" class="back-link">← Back to Dashboard</a>
            </div>
        </div>

        <div class="stats-bar">
            <div class="stat-box">
                <div class="stat-label">Total Logs</div>
                <div class="stat-value">${fn:length(auditLogs)}</div>
            </div>
            <c:if test="${not empty filterModule}">
                <div class="stat-box ${filterModule == 'loan' ? 'loans' : filterModule == 'payment' ? 'payments' : 'members'}">
                    <div class="stat-label">Filtered by ${filterModule}</div>
                    <div class="stat-value">${fn:length(auditLogs)}</div>
                </div>
            </c:if>
        </div>

        <div class="filter-bar">
            <div class="filter-row">
                <div class="filter-group">
                    <label for="moduleFilter">Filter by Module</label>
                    <select id="moduleFilter" onchange="applyFilter()">
                        <option value="">All Modules</option>
                        <option value="loan" ${filterModule == 'loan' ? 'selected' : ''}>Loan Requests</option>
                        <option value="payment" ${filterModule == 'payment' ? 'selected' : ''}>Payments</option>
                        <option value="member" ${filterModule == 'member' ? 'selected' : ''}>Members</option>
                        <option value="overdue" ${filterModule == 'overdue' ? 'selected' : ''}>Overdue</option>
                        <option value="rate" ${filterModule == 'rate' ? 'selected' : ''}>Rates</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="actionFilter">Filter by Action</label>
                    <select id="actionFilter" onchange="applyFilter()">
                        <option value="">All Actions</option>
                        <option value="LOAN_APPROVE" ${param.action == 'LOAN_APPROVE' ? 'selected' : ''}>Loan Approve</option>
                        <option value="LOAN_REJECT" ${param.action == 'LOAN_REJECT' ? 'selected' : ''}>Loan Reject</option>
                        <option value="LOAN_STATUS_CHANGE" ${param.action == 'LOAN_STATUS_CHANGE' ? 'selected' : ''}>Status Change</option>
                        <option value="LOAN_PAYMENT_PROCESSED" ${param.action == 'LOAN_PAYMENT_PROCESSED' ? 'selected' : ''}>Payment Processed</option>
                        <option value="CASH_PAYMENT_APPROVED" ${param.action == 'CASH_PAYMENT_APPROVED' ? 'selected' : ''}>Cash Payment Approved</option>
                        <option value="OVERDUE_NOTIFICATIONS" ${param.action == 'OVERDUE_NOTIFICATIONS' ? 'selected' : ''}>Overdue Notifications</option>
                        <option value="MEMBER_UPDATE" ${param.action == 'MEMBER_UPDATE' ? 'selected' : ''}>Member Update</option>
                        <option value="RATE_UPDATE" ${param.action == 'RATE_UPDATE' ? 'selected' : ''}>Rate Update</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="searchInput">Search</label>
                    <input type="text" id="searchInput" placeholder="Search details..." oninput="applyFilter()">
                </div>
                <div class="filter-group" style="justify-content: flex-end;">
                    <label>&nbsp;</label>
                    <a href="<%= request.getContextPath() %>/admin-dashboard?section=audit" class="btn btn-secondary">Reset Filters</a>
                </div>
            </div>
        </div>

        <div class="action-links">
            <strong>Quick Filters:</strong>
            <a href="<%= request.getContextPath() %>/admin-dashboard?section=audit&module=loan" class="quick-filter">📋 Loans</a>
            <a href="<%= request.getContextPath() %>/admin-dashboard?section=audit&module=payment" class="quick-filter">💰 Payments</a>
            <a href="<%= request.getContextPath() %>/admin-dashboard?section=audit&module=member" class="quick-filter">👥 Members</a>
            <a href="<%= request.getContextPath() %>/admin-dashboard?section=audit&module=overdue" class="quick-filter">⚠️ Overdue</a>
            <a href="<%= request.getContextPath() %>/admin-dashboard?section=audit" class="quick-filter">🔄 All</a>
        </div>

        <div style="overflow-x: auto;">
            <table>
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>User</th>
                        <th>Action</th>
                        <th>Details</th>
                        <th>IP Address</th>
                    </tr>
                </thead>
                <tbody id="auditTableBody">
                    <c:forEach var="log" items="${auditLogs}">
                        <tr class="log-row" 
                            data-action="${fn:toLowerCase(log.action)}"
                            data-details="${fn:toLowerCase(log.details)}"
                            data-module="<c:choose>
                                <c:when test="${fn:startsWith(log.action, 'LOAN_')}">loan</c:when>
                                <c:when test="${fn:startsWith(log.action, 'PAYMENT_') || fn:startsWith(log.action, 'CASH_')}">payment</c:when>
                                <c:when test="${fn:startsWith(log.action, 'MEMBER_')}">member</c:when>
                                <c:when test="${fn:startsWith(log.action, 'OVERDUE_')}">overdue</c:when>
                                <c:when test="${fn:startsWith(log.action, 'RATE_')}">rate</c:when>
                                <c:otherwise>other</c:otherwise>
                            </c:choose>">
                            <td class="timestamp">${log.timestamp}</td>
                            <td class="user-cell">
                                <c:choose>
                                    <c:when test="${not empty log.user}">${log.user.fullName}</c:when>
                                    <c:otherwise>System</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${fn:startsWith(log.action, 'LOAN_APPROVE')}">
                                        <span class="badge badge-loan">✅ Approve</span>
                                    </c:when>
                                    <c:when test="${fn:startsWith(log.action, 'LOAN_REJECT')}">
                                        <span class="badge badge-loan">❌ Reject</span>
                                    </c:when>
                                    <c:when test="${fn:startsWith(log.action, 'LOAN_STATUS_CHANGE')}">
                                        <span class="badge badge-loan">🔄 Status</span>
                                    </c:when>
                                    <c:when test="${fn:startsWith(log.action, 'LOAN_PAYMENT_PROCESSED') || fn:startsWith(log.action, 'CASH_PAYMENT')}">
                                        <span class="badge badge-payment">💳 Payment</span>
                                    </c:when>
                                    <c:when test="${fn:startsWith(log.action, 'MEMBER_')}">
                                        <span class="badge badge-member">👤 Member</span>
                                    </c:when>
                                    <c:when test="${fn:startsWith(log.action, 'OVERDUE_')}">
                                        <span class="badge badge-loan">⚠️ Overdue</span>
                                    </c:when>
                                    <c:when test="${fn:startsWith(log.action, 'RATE_')}">
                                        <span class="badge badge-system">📊 Rate</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-other">📝 ${log.action}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="details-cell">${log.details}</td>
                            <td>${log.ipAddress}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty auditLogs}">
                        <tr>
                            <td colspan="5" class="empty-state">
                                <div style="font-size: 48px; margin-bottom: 10px;">📭</div>
                                <h3>No audit logs found</h3>
                                <p>Try adjusting your filters or check back later.</p>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function applyFilter() {
            const module = document.getElementById('moduleFilter').value;
            const action = document.getElementById('actionFilter').value;
            const search = document.getElementById('searchInput').value.toLowerCase();
            
            // Build URL with filters
            let url = '<%= request.getContextPath() %>/admin-dashboard?section=audit';
            if (module) url += '&module=' + module;
            if (action) url += '&action=' + action;
            
            window.location.href = url;
        }
        
        // Client-side filtering for search
        document.getElementById('searchInput')?.addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const rows = document.querySelectorAll('#auditTableBody .log-row');
            
            rows.forEach(row => {
                const details = row.getAttribute('data-details');
                const action = row.getAttribute('data-action');
                const matchesSearch = !searchTerm || 
                                     details.includes(searchTerm) || 
                                     action.includes(searchTerm);
                row.style.display = matchesSearch ? '' : 'none';
            });
        });
    </script>
</body>
</html>