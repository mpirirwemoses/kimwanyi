<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.example.model.User" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard | Kimwanyi SACCO</title>
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

        /* Quick Actions */
        .quick-actions { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 15px; }
        .action-btn { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; background: #f8f9fa; border: 1px solid #ecf0f1; border-radius: 8px; text-decoration: none; color: #2c3e50; transition: all 0.3s; text-align: center; }
        .action-btn:hover { background: #e8f5ed; border-color: #27ae60; transform: translateY(-2px); }
        .action-icon { font-size: 32px; margin-bottom: 10px; }
        .action-label { font-size: 14px; font-weight: 600; color: #2c3e50; }

        /* Loan List */
        .loan-list { display: grid; gap: 14px; }
        .loan-item { display: flex; justify-content: space-between; align-items: center; padding: 16px; background: #f8f9fa; border-radius: 8px; border: 1px solid #ecf0f1; }
        .loan-info h4 { margin: 0 0 6px; font-size: 14px; color: #2c3e50; }
        .loan-meta { color: #7f8c8d; font-size: 13px; }
        .loan-amount { text-align: right; }
        .loan-amount strong { display: block; font-size: 16px; margin-bottom: 4px; color: #2c3e50; }
        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; text-transform: uppercase; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d1e7dd; color: #0f5132; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        .status-repaid { background: #d1e7dd; color: #0f5132; }

        /* Empty State */
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
            <p>Member Portal</p>
        </div>
        <ul class="nav-menu">
            <li class="nav-section">Main Menu</li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/dashboard" class="nav-link active">
                    <span class="icon">📊</span> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/loans" class="nav-link">
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
                <a href="<%= request.getContextPath() %>/loans" class="nav-link">
                    <span class="icon">➕</span> Apply for Loan
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/savings" class="nav-link">
                    <span class="icon">💰</span> My Savings
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
            <h1>Member Dashboard</h1>
            <div class="user-info">
                <span>Welcome, <strong><%= request.getAttribute("safeUserName") %></strong></span>
                <form method="post" action="<%= request.getContextPath() %>/logout" style="display: inline;">
                    <button type="submit" class="btn-logout">Logout</button>
                </form>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card info">
                <div class="stat-label">Active Loans</div>
                <div class="stat-value" id="activeLoans">0</div>
                <div class="stat-change">Currently borrowing</div>
            </div>
            <div class="stat-card warning">
                <div class="stat-label">Total Outstanding</div>
                <div class="stat-value" id="totalOutstanding">KES 0</div>
                <div class="stat-change">Amount to repay</div>
            </div>
            <div class="stat-card success">
                <div class="stat-label">Savings Balance</div>
                <div class="stat-value" id="savingsBalance">KES 0</div>
                <div class="stat-change positive">Your savings</div>
            </div>
            <div class="stat-card danger">
                <div class="stat-label">Next Due Date</div>
                <div class="stat-value" id="nextDue" style="font-size: 20px;">-</div>
                <div class="stat-change">Upcoming payment</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="content-section">
            <div class="section-header">
                <h2>Quick Actions</h2>
            </div>
            <div class="quick-actions">
                <a href="<%= request.getContextPath() %>/loans" class="action-btn">
                    <div class="action-icon">➕</div>
                    <span class="action-label">Apply for Loan</span>
                </a>
                <a href="<%= request.getContextPath() %>/payments?action=history" class="action-btn">
                    <div class="action-icon">💳</div>
                    <span class="action-label">Payment History</span>
                </a>
                <a href="<%= request.getContextPath() %>/loans" class="action-btn">
                    <div class="action-icon">📋</div>
                    <span class="action-label">View My Loans</span>
                </a>
                <a href="<%= request.getContextPath() %>/savings" class="action-btn">
                    <div class="action-icon">💰</div>
                    <span class="action-label">My Savings</span>
                </a>
            </div>
        </div>

        <!-- Recent Loans -->
        <div class="content-section">
            <div class="section-header">
                <h2>Recent Loans</h2>
                <a href="<%= request.getContextPath() %>/loans" class="btn btn-sm">View All</a>
            </div>
            <div class="loan-list" id="recentLoans">
                <div class="empty-state">
                    <div class="empty-state-icon">📋</div>
                    <p>Loading your loans...</p>
                </div>
            </div>
        </div>
    </main>

    <script>
        // Dashboard statistics and recent loans will be loaded here
        document.addEventListener('DOMContentLoaded', function() {
            loadDashboardData();
        });

        function loadDashboardData() {
            fetch('<%= request.getContextPath() %>/api/dashboard-data')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('activeLoans').textContent = data.activeLoans || 0;
                    document.getElementById('totalOutstanding').textContent = 'KES ' + (data.totalOutstanding || 0).toLocaleString();
                    document.getElementById('savingsBalance').textContent = 'KES ' + (data.savingsBalance || 0).toLocaleString();
                    document.getElementById('nextDue').textContent = data.nextDue || '-';
                    document.getElementById('totalRepaid').textContent = 'KES ' + (data.totalRepaid || 0).toLocaleString();

                    const recentLoansContainer = document.getElementById('recentLoans');
                    if (data.recentLoans && data.recentLoans.length > 0) {
                        recentLoansContainer.innerHTML = data.recentLoans.map(function(loan) {
                            return '<div class="loan-item">' +
                                '<div class="loan-info">' +
                                    '<h4>Loan #' + loan.id + ' - ' + loan.purpose + '</h4>' +
                                    '<div class="loan-meta">Applied: ' + new Date(loan.appliedAt).toLocaleDateString() + '</div>' +
                                '</div>' +
                                '<div class="loan-amount">' +
                                    '<strong>KES ' + loan.amount.toLocaleString() + '</strong>' +
                                    '<span class="status-badge status-' + loan.status.toLowerCase() + '">' + loan.status + '</span>' +
                                '</div>' +
                            '</div>';
                        }).join('');
                    } else {
                        recentLoansContainer.innerHTML =
                            '<div class="empty-state">' +
                                '<div class="empty-state-icon">📋</div>' +
                                '<p>No loans yet.</p>' +
                                '<p><a href="<%= request.getContextPath() %>/loans" style="color: #3498db;">Apply for your first loan</a></p>' +
                            '</div>';
                    }
                })
                .catch(error => {
                    console.error('Error loading dashboard data:', error);
                    document.getElementById('recentLoans').innerHTML =
                        '<div class="empty-state">' +
                            '<div class="empty-state-icon">⚠️</div>' +
                            '<p>Unable to load data. Please refresh the page.</p>' +
                        '</div>';
                });
        }
    </script>
</body>
</html>
