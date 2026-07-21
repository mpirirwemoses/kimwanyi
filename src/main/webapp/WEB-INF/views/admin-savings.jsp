<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Savings - Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 1400px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .nav-links a { margin-left: 15px; text-decoration: none; color: #3498db; font-weight: bold; }
        .nav-links a:hover { color: #2980b9; }
        .alert { padding: 12px; margin-bottom: 20px; border-radius: 4px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 25px; border-radius: 8px; text-align: center; }
        .stat-card h3 { font-size: 14px; opacity: 0.9; margin-bottom: 10px; }
        .stat-card .value { font-size: 28px; font-weight: bold; }
        .stat-card .icon { font-size: 36px; margin-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; font-size: 14px; }
        th { background-color: #2c3e50; color: white; font-weight: bold; }
        tr:hover { background-color: #f5f5f5; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-active { background: #d4edda; color: #155724; }
        .badge-dormant { background: #fff3cd; color: #856404; }
        .badge-closed { background: #f8d7da; color: #721c24; }
        .btn { display: inline-block; padding: 8px 16px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; text-align: center; font-weight: bold; border: none; cursor: pointer; font-size: 14px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }
        .btn-sm { padding: 6px 12px; font-size: 12px; }
        .action-buttons { display: flex; gap: 10px; margin-top: 10px; }
        .no-data { text-align: center; padding: 40px; color: #7f8c8d; font-style: italic; }
        .search-box { margin-bottom: 20px; }
        .search-box input { padding: 10px; width: 300px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        .modal-content { background-color: white; margin: 5% auto; padding: 30px; border-radius: 8px; width: 90%; max-width: 500px; }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .modal-header h2 { color: #2c3e50; }
        .close { color: #aaa; font-size: 28px; font-weight: bold; cursor: pointer; }
        .close:hover { color: #000; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; color: #2c3e50; font-weight: bold; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏦 Manage Savings Accounts</h1>
            <div class="nav-links">
                <a href="${pageContext.request.contextPath}/admin-dashboard">Admin Dashboard</a>
                <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                <a href="${pageContext.request.contextPath}/logout">Logout</a>
            </div>
        </div>

        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Operation completed successfully!</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="icon">💰</div>
                <h3>Total Savings</h3>
                <div class="value">KES ${totalSavings}</div>
            </div>
            <div class="stat-card">
                <div class="icon">👥</div>
                <h3>Active Members</h3>
                <div class="value">${totalMembers}</div>
            </div>
            <div class="stat-card">
                <div class="icon">📊</div>
                <h3>Total Accounts</h3>
                <div class="value">${accounts.size()}</div>
            </div>
        </div>

        <div class="search-box">
            <input type="text" id="searchInput" placeholder="Search by account number or member name..." onkeyup="searchTable()">
        </div>

        <c:choose>
            <c:when test="${not empty accounts}">
                <table>
                    <thead>
                        <tr>
                            <th>Account Number</th>
                            <th>Member Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Balance</th>
                            <th>Total Deposits</th>
                            <th>Interest Rate</th>
                            <th>Status</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="account" items="${accounts}">
                            <tr>
                                <td><strong>${account.accountNumber}</strong></td>
                                <td>${account.member.fullName}</td>
                                <td>${account.member.email}</td>
                                <td>${account.member.phoneNumber}</td>
                                <td><strong>KES ${account.balance}</strong></td>
                                <td>KES ${account.totalDeposits}</td>
                                <td>${account.interestRate}%</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${account.status == 'ACTIVE'}">
                                            <span class="badge badge-active">${account.status}</span>
                                        </c:when>
                                        <c:when test="${account.status == 'DORMANT'}">
                                            <span class="badge badge-dormant">${account.status}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-closed">${account.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${account.createdAtFormatted}</td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="${pageContext.request.contextPath}/savings?action=statement&accountId=${account.id}" class="btn btn-sm btn-success" target="_blank">View</a>
                                        <button onclick="openRateModal(${account.id}, ${account.interestRate})" class="btn btn-sm btn-warning">Rate</button>
                                        <c:if test="${account.status == 'ACTIVE'}">
                                            <button onclick="closeAccount(${account.id})" class="btn btn-sm btn-danger">Close</button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="no-data">No savings accounts found.</div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Update Interest Rate Modal -->
    <div id="rateModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Update Interest Rate</h2>
                <span class="close" onclick="closeRateModal()">&times;</span>
            </div>
            <form id="rateForm" method="POST" action="${pageContext.request.contextPath}/savings">
                <input type="hidden" name="action" value="update-rate">
                <input type="hidden" name="accountId" id="rateAccountId">
                <div class="form-group">
                    <label for="interestRate">Interest Rate (% per annum) *</label>
                    <input type="number" id="interestRate" name="interestRate" step="0.01" min="0" max="100" required>
                </div>
                <button type="submit" class="btn btn-success">Update Rate</button>
                <button type="button" class="btn btn-secondary" onclick="closeRateModal()">Cancel</button>
            </form>
        </div>
    </div>

    <script>
        function searchTable() {
            let input = document.getElementById("searchInput");
            let filter = input.value.toLowerCase();
            let table = document.querySelector("table");
            let tr = table.getElementsByTagName("tr");
            
            for (let i = 1; i < tr.length; i++) {
                let td = tr[i].getElementsByTagName("td");
                let found = false;
                for (let j = 0; j < td.length; j++) {
                    if (td[j]) {
                        if (td[j].textContent.toLowerCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                tr[i].style.display = found ? "" : "none";
            }
        }

        function openRateModal(accountId, currentRate) {
            document.getElementById("rateAccountId").value = accountId;
            document.getElementById("interestRate").value = currentRate;
            document.getElementById("rateModal").style.display = "block";
        }

        function closeRateModal() {
            document.getElementById("rateModal").style.display = "none";
        }

        function closeAccount(accountId) {
            if (confirm("Are you sure you want to close this account? This action cannot be undone.")) {
                let form = document.createElement("form");
                form.method = "POST";
                form.action = "${pageContext.request.contextPath}/savings";
                let actionInput = document.createElement("input");
                actionInput.type = "hidden";
                actionInput.name = "action";
                actionInput.value = "close-account";
                let accountInput = document.createElement("input");
                accountInput.type = "hidden";
                accountInput.name = "accountId";
                accountInput.value = accountId;
                form.appendChild(actionInput);
                form.appendChild(accountInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        window.onclick = function(event) {
            let modal = document.getElementById("rateModal");
            if (event.target == modal) {
                closeRateModal();
            }
        }
    </script>
</body>
</html>