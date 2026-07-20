<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.example.model.User" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
    <style>
        .dashboard-layout { display: grid; grid-template-columns: 260px 1fr; min-height: 100vh; }
        .sidebar { background: #fff; border-right: 1px solid var(--line); padding: 24px 0; position: sticky; top: 0; height: 100vh; overflow-y: auto; }
        .sidebar-brand { padding: 0 24px 24px; border-bottom: 1px solid var(--line); margin-bottom: 16px; }
        .sidebar-brand a { color: var(--ink); font-size: 1.1rem; font-weight: 800; text-decoration: none; }
        .nav-section { padding: 0 12px; margin-bottom: 24px; }
        .nav-section-title { padding: 0 12px 8px; color: var(--muted); font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; }
        .nav-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 8px; color: var(--ink); text-decoration: none; font-size: .92rem; font-weight: 600; margin-bottom: 4px; transition: background .15s; }
        .nav-item:hover { background: var(--background); }
        .nav-item.active { background: #e8f5ed; color: var(--primary); }
        .nav-icon { width: 20px; height: 20px; flex-shrink: 0; }
        .main-content { padding: 32px; overflow-y: auto; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 18px; margin-bottom: 32px; }
        .stat-card { background: #fff; padding: 24px; border-radius: 14px; border: 1px solid var(--line); }
        .stat-label { color: var(--muted); font-size: .85rem; font-weight: 700; margin-bottom: 8px; }
        .stat-value { font-size: 1.75rem; font-weight: 800; color: var(--ink); margin-bottom: 4px; }
        .stat-change { font-size: .82rem; color: var(--muted); }
        .section-card { background: #fff; padding: 28px; border-radius: 14px; border: 1px solid var(--line); margin-bottom: 24px; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .section-title { font-size: 1.15rem; font-weight: 700; margin: 0; }
        .loan-list { display: grid; gap: 14px; }
        .loan-item { display: flex; justify-content: space-between; align-items: center; padding: 16px; background: var(--background); border-radius: 10px; border: 1px solid var(--line); }
        .loan-info h4 { margin: 0 0 6px; font-size: .95rem; }
        .loan-meta { color: var(--muted); font-size: .85rem; }
        .loan-amount { text-align: right; }
        .loan-amount strong { display: block; font-size: 1.05rem; margin-bottom: 4px; }
        .status-badge { display: inline-block; padding: 3px 10px; border-radius: 6px; font-size: .75rem; font-weight: 700; text-transform: uppercase; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-approved { background: #d1e7dd; color: #0f5132; }
        .status-rejected { background: #f8d7da; color: #721c24; }
        .status-repaid { background: #d1e7dd; color: #0f5132; }
        .quick-actions { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
        .action-btn { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; background: var(--background); border: 1px solid var(--line); border-radius: 10px; text-decoration: none; color: var(--ink); transition: all .15s; }
        .action-btn:hover { background: #e8f5ed; border-color: var(--primary); }
        .action-icon { width: 32px; height: 32px; margin-bottom: 8px; color: var(--primary); }
        .action-label { font-size: .85rem; font-weight: 600; }
        @media (max-width: 768px) {
            .dashboard-layout { grid-template-columns: 1fr; }
            .sidebar { display: none; }
            .main-content { padding: 20px; }
        }
    </style>
</head>
<body>
<div class="dashboard-layout">
    <aside class="sidebar">
        <div class="sidebar-brand">
            <a href="<%= request.getContextPath() %>/dashboard">Credit SACCO</a>
        </div>
        
        <nav class="nav-section">
            <div class="nav-section-title">Main Menu</div>
            <a href="<%= request.getContextPath() %>/dashboard" class="nav-item active">
                <svg class="nav-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                Dashboard
            </a>
            <a href="<%= request.getContextPath() %>/loans" class="nav-item">
                <svg class="nav-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                My Loans
            </a>
            <a href="<%= request.getContextPath() %>/payments?action=history" class="nav-item">
                <svg class="nav-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>
                Payment History
            </a>
        </nav>

        <nav class="nav-section">
            <div class="nav-section-title">Services</div>
            <a href="<%= request.getContextPath() %>/loans" class="nav-item">
                <svg class="nav-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>
                Apply for Loan
            </a>
            <a href="#" class="nav-item" style="opacity: .5; cursor: not-allowed;">
                <svg class="nav-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                Savings (Coming Soon)
            </a>
        </nav>

        <div style="margin-top: auto; padding: 0 12px; border-top: 1px solid var(--line); padding-top: 16px; margin-top: 24px;">
            <form method="post" action="<%= request.getContextPath() %>/logout">
                <button type="submit" class="nav-item" style="width: 100%; border: none; background: none; cursor: pointer; text-align: left;">
                    <svg class="nav-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                    Logout
                </button>
            </form>
        </div>
    </aside>

    <main class="main-content">
        <section class="welcome-panel" style="margin-bottom: 32px;">
            <p class="eyebrow">Member Dashboard</p>
            <h1 style="font-size: 1.85rem; margin-bottom: 8px;">Welcome back, <%= request.getAttribute("safeUserName") %>.</h1>
            <p style="color: var(--muted);">Manage your loans, track payments, and grow your financial future.</p>
        </section>

        <div class="stats-grid">
            <article class="stat-card">
                <div class="stat-label">Active Loans</div>
                <div class="stat-value" id="activeLoans">0</div>
                <div class="stat-change">Currently borrowing</div>
            </article>
            <article class="stat-card">
                <div class="stat-label">Total Outstanding</div>
                <div class="stat-value" id="totalOutstanding">KES 0</div>
                <div class="stat-change">Amount to repay</div>
            </article>
            <article class="stat-card">
                <div class="stat-label">Next Payment Due</div>
                <div class="stat-value" id="nextDue">-</div>
                <div class="stat-change">Upcoming repayment</div>
            </article>
            <article class="stat-card">
                <div class="stat-label">Total Repaid</div>
                <div class="stat-value" id="totalRepaid">KES 0</div>
                <div class="stat-change">Payment history</div>
            </article>
        </div>

        <div class="section-card">
            <div class="section-header">
                <h2 class="section-title">Quick Actions</h2>
            </div>
            <div class="quick-actions">
                <a href="<%= request.getContextPath() %>/loans" class="action-btn">
                    <svg class="action-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/></svg>
                    <span class="action-label">Apply for Loan</span>
                </a>
                <a href="<%= request.getContextPath() %>/payments?action=history" class="action-btn">
                    <svg class="action-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
                    <span class="action-label">Payment History</span>
                </a>
                <a href="<%= request.getContextPath() %>/loans" class="action-btn">
                    <svg class="action-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                    <span class="action-label">View Loans</span>
                </a>
                <a href="#" class="action-btn" style="opacity: .5; cursor: not-allowed;">
                    <svg class="action-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                    <span class="action-label">Savings (Soon)</span>
                </a>
            </div>
        </div>

        <div class="section-card">
            <div class="section-header">
                <h2 class="section-title">Recent Loans</h2>
                <a href="<%= request.getContextPath() %>/loans" class="button" style="padding: 8px 16px; font-size: .85rem;">View All</a>
            </div>
            <div class="loan-list" id="recentLoans">
                <p style="color: var(--muted); text-align: center; padding: 24px;">Loading your loans...</p>
            </div>
        </div>
    </main>
</div>

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
                    recentLoansContainer.innerHTML = '<p style="color: var(--muted); text-align: center; padding: 24px;">No loans yet. <a href="<%= request.getContextPath() %>/loans" style="color: var(--primary);">Apply for your first loan</a></p>';
                }
            })
            .catch(error => {
                console.error('Error loading dashboard data:', error);
                document.getElementById('recentLoans').innerHTML = '<p style="color: var(--muted); text-align: center; padding: 24px;">Unable to load data. Please refresh the page.</p>';
            });
    }
</script>
</body>
</html>