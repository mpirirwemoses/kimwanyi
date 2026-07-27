<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Kimwanyi SACCO</title>
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
        .btn-logout { padding: 8px 16px; background: #e74c3c; color: white; text-decoration: none; border-radius: 4px; font-size: 14px; }
        .btn-logout:hover { background: #c0392b; }
        
        /* Stats Cards */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #3498db; }
        .stat-card.warning { border-left-color: #f39c12; }
        .stat-card.danger { border-left-color: #e74c3c; }
        .stat-card.success { border-left-color: #27ae60; }
        .stat-card.info { border-left-color: #17a2b8; }
        .stat-label { color: #7f8c8d; font-size: 14px; margin-bottom: 8px; }
        .stat-value { color: #2c3e50; font-size: 28px; font-weight: bold; }
        .stat-change { font-size: 12px; margin-top: 5px; }
        .stat-change.positive { color: #27ae60; }
        .stat-change.negative { color: #e74c3c; }
        
        /* Content Sections */
        .content-section { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #ecf0f1; }
        .section-header h2 { color: #2c3e50; font-size: 22px; }
        .btn { padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }
        .btn-sm { padding: 6px 12px; font-size: 12px; }
        
        /* Tables */
        .data-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .data-table th { background: #2c3e50; color: white; padding: 12px; text-align: left; font-weight: 600; font-size: 14px; }
        .data-table td { padding: 12px; border-bottom: 1px solid #ecf0f1; color: #555; }
        .data-table tr:hover { background: #f8f9fa; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-warning { background: #fff3cd; color: #856404; }
        .badge-danger { background: #f8d7da; color: #721c24; }
        .badge-info { background: #d1ecf1; color: #0c5460; }
        .badge-primary { background: #cce5ff; color: #004085; }
        
        /* Notifications */
        .notification-item { padding: 15px; background: #f8f9fa; border-left: 4px solid #3498db; margin-bottom: 10px; border-radius: 4px; }
        .notification-item.unread { border-left-color: #e74c3c; background: #fff5f5; }
        .notification-item.warning { border-left-color: #f39c12; }
        .notification-header { display: flex; justify-content: space-between; margin-bottom: 5px; }
        .notification-title { font-weight: 600; color: #2c3e50; }
        .notification-time { font-size: 12px; color: #95a5a6; }
        .notification-body { color: #555; font-size: 14px; }
        
        /* Alerts */
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .alert-danger { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-warning { background: #fff3cd; color: #856404; border: 1px solid #ffc107; }
        .alert-info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        
        /* Modals */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; }
        .modal.active { display: flex; }
        .modal-content { background: white; padding: 30px; border-radius: 8px; width: 90%; max-width: 600px; max-height: 90vh; overflow-y: auto; }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .modal-header h3 { color: #2c3e50; }
        .close-modal { background: none; border: none; font-size: 24px; cursor: pointer; color: #95a5a6; }
        .close-modal:hover { color: #2c3e50; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; color: #555; font-weight: 500; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
        .form-group textarea { resize: vertical; min-height: 80px; }
        
        /* Empty States */
        .empty-state { text-align: center; padding: 40px; color: #95a5a6; }
        .empty-state-icon { font-size: 48px; margin-bottom: 15px; }
        
        /* Responsive */
        @media (max-width: 768px) {
            .sidebar { width: 100%; position: relative; }
            .main-content { margin-left: 0; }
            .stats-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h2>🏛️ Kimwanyi SACCO</h2>
            <p>Administration Panel</p>
        </div>
        <ul class="nav-menu">
            <li class="nav-section">Main Menu</li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard" class="nav-link active" data-section="dashboard">
                    <span class="icon">📊</span> Dashboard
                </a>
            </li>
            
            <li class="nav-section">Management</li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard?section=members" class="nav-link" data-section="members">
                    <span class="icon">👥</span> Members
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard?section=accounts" class="nav-link" data-section="accounts">
                    <span class="icon">💰</span> Savings Accounts
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard?section=loans" class="nav-link" data-section="loans">
                    <span class="icon">📋</span> Loan Requests
                </a>
            </li>
            
            <li class="nav-section">Monitoring</li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard?section=overdue" class="nav-link" data-section="overdue">
                    <span class="icon">⚠️</span> Overdue Loans
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard?section=notifications" class="nav-link" data-section="notifications">
                    <span class="icon">🔔</span> Notifications
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard?section=reports" class="nav-link" data-section="reports">
                    <span class="icon">📈</span> Reports
                </a>
            </li>
            
            <li class="nav-section">System</li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/admin-dashboard?section=audit" class="nav-link" data-section="audit">
                    <span class="icon">📝</span> Audit Trail
                </a>
            </li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <div class="page-header">
            <h1 id="pageTitle">Dashboard Overview</h1>
            <div class="user-info">
                <span>Welcome, <strong><%= request.getAttribute("safeUserName") %></strong></span>
                <form method="post" action="<%= request.getContextPath() %>/logout" style="display: inline;">
                    <button type="submit" class="btn-logout">Logout</button>
                </form>
            </div>
        </div>

        <!-- Dashboard Section -->
        <c:if test="${empty param.section || param.section == 'dashboard'}">
            <div class="stats-grid">
                <div class="stat-card info">
                    <div class="stat-label">Total Members</div>
                    <div class="stat-value" id="totalMembers">${totalMembers}</div>
                    <div class="stat-change positive">Active accounts</div>
                </div>
                <div class="stat-card success">
                    <div class="stat-label">Total Savings</div>
                    <div class="stat-value">KES ${totalSavings}</div>
                    <div class="stat-change positive">Across all accounts</div>
                </div>
                <div class="stat-card warning">
                    <div class="stat-label">Pending Loans</div>
                    <div class="stat-value" id="pendingLoans">${pendingLoans}</div>
                    <div class="stat-change">Awaiting review</div>
                </div>
                <div class="stat-card danger">
                    <div class="stat-label">Overdue Loans</div>
                    <div class="stat-value" id="overdueLoans">${overdueLoans}</div>
                    <div class="stat-change negative">Requires attention</div>
                </div>
            </div>

            <div class="content-section">
                <div class="section-header">
                    <h2>Recent Activities</h2>
                </div>
                <div id="recentActivities">
                    <!-- Will be populated by JavaScript -->
                </div>
            </div>
        </c:if>

        <!-- Members Section -->
        <c:if test="${param.section == 'members'}">
            <div class="content-section">
                <div class="section-header">
                    <h2>Member Management</h2>
                    <button class="btn btn-success" onclick="showAddMemberModal()">+ Add New Member</button>
                </div>
                <div class="alert alert-info">
                    <strong>💡 Tip:</strong> Use the search and filters below to find members quickly. All members must have a unique national ID and membership number.
                </div>
                <input type="text" id="memberSearch" placeholder="Search members..." class="form-control" style="width: 100%; padding: 10px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Member ID</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Membership No.</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="membersTableBody">
                        <c:forEach var="member" items="${members}">
                            <tr>
                                <td>${member.id}</td>
                                <td>${member.fullName}</td>
                                <td>${member.email}</td>
                                <td>${member.phoneNumber}</td>
                                <td>${member.membershipNumber}</td>
                                <td><span class="badge badge-${member.status == 'ACTIVE' ? 'success' : 'warning'}">${member.status}</span></td>
                                <td>
                                    <button class="btn btn-sm" onclick="editMember(${member.id})">Edit</button>
                                    <button class="btn btn-sm btn-danger" onclick="deleteMember(${member.id})">Delete</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>

        <!-- Accounts Section -->
        <c:if test="${param.section == 'accounts'}">
            <div class="content-section">
                <div class="section-header">
                    <h2>Savings Accounts Management</h2>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Account Number</th>
                            <th>Member</th>
                            <th>Balance</th>
                            <th>Interest Rate</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="account" items="${accounts}">
                            <tr>
                                <td>${account.accountNumber}</td>
                                <td>${account.member.fullName}</td>
                                <td><strong>KES ${account.balance}</strong></td>
                                <td>${account.interestRate}%</td>
                                <td><span class="badge badge-${account.status == 'ACTIVE' ? 'success' : 'warning'}">${account.status}</span></td>
                                <td>
                                    <button class="btn btn-sm" onclick="viewAccountDetails(${account.id})">View</button>
                                    <button class="btn btn-sm btn-warning" onclick="updateInterestRate(${account.id})">Update Rate</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>

        <!-- Loans Section -->
        <c:if test="${param.section == 'loans'}">
            <div class="content-section">
                <div class="section-header">
                    <h2>Loan Applications</h2>
                </div>
                <div class="alert alert-warning">
                    <strong>⚠️ Review Required:</strong> Review and approve or reject loan applications. All decisions are logged in the audit trail.
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Reference</th>
                            <th>Member</th>
                            <th>Amount</th>
                            <th>Purpose</th>
                            <th>Applied Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="loan" items="${loans}">
                            <tr>
                                <td>${loan.loanReference}</td>
                                <td>${loan.member.fullName}</td>
                                <td><strong>KES ${loan.requestedAmount}</strong></td>
                                <td>${fn:substring(loan.purpose, 0, 30)}...</td>
                                <td>${loan.appliedAtFormatted}</td>
                                <td>
                                    <span class="badge badge-${loan.status == 'PENDING' ? 'warning' : loan.status == 'APPROVED' ? 'success' : 'danger'}">
                                        ${loan.status}
                                    </span>
                                </td>
                                <td>
                                    <c:if test="${loan.status == 'PENDING'}">
                                        <button class="btn btn-sm btn-success" onclick="approveLoan(${loan.id})">Approve</button>
                                        <button class="btn btn-sm btn-danger" onclick="rejectLoan(${loan.id})">Reject</button>
                                    </c:if>
                                    <button class="btn btn-sm" onclick="viewLoanDetails(${loan.id})">View</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>

        <!-- Overdue Loans Section -->
        <c:if test="${param.section == 'overdue'}">
            <div class="content-section">
                <div class="section-header">
                    <h2>Overdue Loans</h2>
                    <button class="btn btn-warning" onclick="sendOverdueNotifications()">📧 Send Notifications</button>
                </div>
                <div class="alert alert-danger">
                    <strong>⚠️ Action Required:</strong> These loans have passed their due date. Click "View Details" to see full information and approve cash payments.
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Reference</th>
                            <th>Member</th>
                            <th>Outstanding Balance</th>
                            <th>Due Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="loan" items="${overdueLoans}">
                            <tr>
                                <td>${loan.loanReference}</td>
                                <td>${loan.member.fullName}</td>
                                <td><strong class="text-danger">KES ${loan.outstandingBalance}</strong></td>
                                <td>${loan.dueDateFormatted}</td>
                                <td>
                                    <button class="btn btn-sm" onclick="viewLoanDetails(${loan.id})">View Details</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>

        <!-- Notifications Section -->
        <c:if test="${param.section == 'notifications'}">
            <div class="content-section">
                <div class="section-header">
                    <h2>Notifications</h2>
                    <button class="btn btn-primary" onclick="showSendNotificationModal()">+ Send Notification</button>
                </div>
                <div id="notificationsList">
                    <c:forEach var="notification" items="${notifications}">
                        <div class="notification-item ${notification.read ? '' : 'unread'}">
                            <div class="notification-header">
                                <span class="notification-title">${notification.title}</span>
                                <span class="notification-time">${notification.createdAt}</span>
                            </div>
                            <div class="notification-body">${notification.message}</div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- Reports Section -->
        <c:if test="${param.section == 'reports'}">
            <div class="content-section">
                <div class="section-header">
                    <h2>Financial Reports</h2>
                </div>
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-label">Monthly Savings</div>
                        <div class="stat-value">KES ${monthlySavings}</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-label">Monthly Loans Issued</div>
                        <div class="stat-value">KES ${monthlyLoans}</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-label">Total Members</div>
                        <div class="stat-value">${totalMembers}</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-label">Active Loans</div>
                        <div class="stat-value">${activeLoans}</div>
                    </div>
                </div>
                <button class="btn" onclick="generateReport('savings')">📊 Savings Report</button>
                <button class="btn" onclick="generateReport('loans')">📊 Loans Report</button>
                <button class="btn" onclick="generateReport('members')">📊 Members Report</button>
            </div>
        </c:if>

        <!-- Audit Trail Section -->
        <c:if test="${param.section == 'audit'}">
            <div class="content-section">
                <div class="section-header">
                    <h2>Audit Trail</h2>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Timestamp</th>
                            <th>User</th>
                            <th>Action</th>
                            <th>Details</th>
                            <th>IP Address</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${auditLogs}">
                            <tr>
                                <td>${log.timestamp}</td>
                                <td>${log.userName}</td>
                                <td><span class="badge badge-info">${log.action}</span></td>
                                <td>${log.details}</td>
                                <td>${log.ipAddress}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </main>

    <!-- Add/Edit Member Modal -->
    <div id="memberModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="memberModalTitle">Add New Member</h3>
                <button class="close-modal" onclick="closeMemberModal()">&times;</button>
            </div>
            <form id="memberForm" onsubmit="saveMember(event)">
                <input type="hidden" id="memberId">
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" id="memberName" required>
                </div>
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" id="memberEmail" required>
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="tel" id="memberPhone">
                </div>
                <div class="form-group">
                    <label>National ID *</label>
                    <input type="text" id="memberNationalId" required>
                </div>
                <div class="form-group">
                    <label>Physical Address</label>
                    <textarea id="memberAddress"></textarea>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select id="memberStatus">
                        <option value="ACTIVE">Active</option>
                        <option value="INACTIVE">Inactive</option>
                        <option value="SUSPENDED">Suspended</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-success">Save Member</button>
                <button type="button" class="btn" onclick="closeMemberModal()">Cancel</button>
            </form>
        </div>
    </div>

    <script>
        // Context path for building correct URLs
        var contextPath = '${pageContext.request.contextPath}';

        // Search functionality
        document.getElementById('memberSearch')?.addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const rows = document.querySelectorAll('#membersTableBody tr');
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });

        // Modal functions
        function showAddMemberModal() {
            document.getElementById('memberModalTitle').textContent = 'Add New Member';
            document.getElementById('memberForm').reset();
            document.getElementById('memberId').value = '';
            document.getElementById('memberModal').classList.add('active');
        }

        function closeMemberModal() {
            document.getElementById('memberModal').classList.remove('active');
        }

        function editMember(memberId) {
            // Fetch member data from server and populate form
            showAddMemberModal();
            document.getElementById('memberModalTitle').textContent = 'Edit Member';
            
            // Create a form to fetch member data
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = contextPath + '/admin-dashboard';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'get-member';
            
            const memberIdInput = document.createElement('input');
            memberIdInput.type = 'hidden';
            memberIdInput.name = 'memberId';
            memberIdInput.value = memberId;
            
            const sectionInput = document.createElement('input');
            sectionInput.type = 'hidden';
            sectionInput.name = 'section';
            sectionInput.value = 'members';
            
            form.appendChild(actionInput);
            form.appendChild(memberIdInput);
            form.appendChild(sectionInput);
            document.body.appendChild(form);
            form.submit();
        }

        function saveMember(event) {
            event.preventDefault();
            const memberId = document.getElementById('memberId').value;
            const formData = {
                action: memberId ? 'update-member' : 'add-member',
                memberId: memberId,
                fullName: document.getElementById('memberName').value,
                email: document.getElementById('memberEmail').value,
                phoneNumber: document.getElementById('memberPhone').value,
                nationalId: document.getElementById('memberNationalId').value,
                physicalAddress: document.getElementById('memberAddress').value,
                status: document.getElementById('memberStatus').value,
                section: 'members'
            };
            
            submitForm(contextPath + '/admin-dashboard', formData);
            closeMemberModal();
        }

        function deleteMember(memberId) {
            if (confirm('Are you sure you want to deactivate this member? This action cannot be undone.')) {
                const formData = {
                    action: 'delete-member',
                    memberId: memberId,
                    section: 'members'
                };
                submitForm(contextPath + '/admin-dashboard', formData);
            }
        }

        function approveLoan(loanId) {
            const comment = prompt('Enter approval comment (optional):');
            if (comment !== null) {
                const formData = {
                    action: 'approve-loan',
                    loanId: loanId,
                    comment: comment || 'Approved',
                    section: 'loans'
                };
                submitForm(contextPath + '/admin-dashboard', formData);
            }
        }

        function rejectLoan(loanId) {
            const reason = prompt('Enter rejection reason:');
            if (reason && reason.trim() !== '') {
                const formData = {
                    action: 'reject-loan',
                    loanId: loanId,
                    comment: reason,
                    section: 'loans'
                };
                submitForm(contextPath + '/admin-dashboard', formData);
            }
        }

        function updateInterestRate(accountId) {
            const currentRate = prompt('Enter new interest rate (%):');
            if (currentRate && !isNaN(currentRate) && parseFloat(currentRate) > 0 && parseFloat(currentRate) <= 100) {
                const formData = {
                    action: 'update-rate',
                    accountId: accountId,
                    interestRate: currentRate,
                    section: 'accounts'
                };
                submitForm(contextPath + '/admin-dashboard', formData);
            } else {
                alert('Please enter a valid interest rate between 0 and 100.');
            }
        }

        function viewAccountDetails(accountId) {
            // Navigate to account details page
            window.location.href = contextPath + '/admin-dashboard?section=accounts&action=view&id=' + accountId;
        }

        function viewLoanDetails(loanId) {
            // Navigate to loan details page
            window.location.href = contextPath + '/admin-dashboard?section=loans&action=view&id=' + loanId;
        }

        function contactMember(memberId) {
            // Navigate to contact member page
            window.location.href = contextPath + '/admin-dashboard?section=members&action=contact&memberId=' + memberId;
        }

        function sendOverdueNotifications() {
            if (confirm('Send email notifications to all members with overdue loans?\n\nThis will send urgent reminders to all members with overdue loans.')) {
                const formData = {
                    action: 'send-overdue-notifications',
                    section: 'overdue'
                };
                submitForm(contextPath + '/admin-dashboard', formData);
            }
        }

        function showSendNotificationModal() {
            const title = prompt('Enter notification title:');
            if (!title) return;
            
            const message = prompt('Enter notification message:');
            if (!message) return;
            
            const recipientType = prompt('Enter recipient type (MEMBER, ADMIN, or ALL):', 'ALL');
            
            const formData = {
                action: 'send-notification',
                title: title,
                message: message,
                recipientType: recipientType.toUpperCase(),
                section: 'notifications'
            };
            submitForm(contextPath + '/admin-dashboard', formData);
        }

        function generateReport(type) {
            // Generate actual report by creating a form submission
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = contextPath + '/admin-dashboard';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'generate-report';
            
            const reportTypeInput = document.createElement('input');
            reportTypeInput.type = 'hidden';
            reportTypeInput.name = 'reportType';
            reportTypeInput.value = type;
            
            const sectionInput = document.createElement('input');
            sectionInput.type = 'hidden';
            sectionInput.name = 'section';
            sectionInput.value = 'reports';
            
            form.appendChild(actionInput);
            form.appendChild(reportTypeInput);
            form.appendChild(sectionInput);
            document.body.appendChild(form);
            form.submit();
        }

        function submitForm(url, data) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = url;
            
            for (const key in data) {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = key;
                input.value = data[key];
                form.appendChild(input);
            }
            
            document.body.appendChild(form);
            form.submit();
        }

        // Load dashboard data
        document.addEventListener('DOMContentLoaded', function() {
            // Set active nav link
            const section = '${param.section}' || 'dashboard';
            document.querySelectorAll('.nav-link').forEach(link => {
                link.classList.remove('active');
                if (link.dataset.section === section) {
                    link.classList.add('active');
                }
            });
            
            // Load recent activities
            loadRecentActivities();
        });
        
        function loadRecentActivities() {
            const activities = [
                { type: 'deposit', message: 'New deposit of KES 10,000 by John Doe', time: '2 minutes ago' },
                { type: 'loan', message: 'New loan application from Jane Smith', time: '15 minutes ago' },
                { type: 'withdrawal', message: 'Withdrawal of KES 5,000 by Bob Johnson', time: '1 hour ago' }
            ];
            
            const container = document.getElementById('recentActivities');
            if (container) {
                container.innerHTML = activities.map(activity => 
                    '<div class="notification-item">' +
                    '<div class="notification-header">' +
                    '<span class="notification-title">' + activity.message + '</span>' +
                    '<span class="notification-time">' + activity.time + '</span>' +
                    '</div></div>'
                ).join('');
            }
        }
    </script>
</body>
</html>
