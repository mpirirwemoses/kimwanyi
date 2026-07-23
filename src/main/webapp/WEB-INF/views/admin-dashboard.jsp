<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin dashboard | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
</head>
<body class="dashboard-body">
<div class="dashboard-shell">
    <header class="topbar">
        <a class="brand" href="<%= request.getContextPath() %>/dashboard">Credit SACCO <span>Admin</span></a>
        <form method="post" action="<%= request.getContextPath() %>/logout">
            <button class="button secondary" type="submit">Log out</button>
        </form>
    </header>

    <main class="dashboard-content">
        <section class="welcome-panel">
            <p class="eyebrow">Administration</p>
            <h1>Welcome, <%= request.getAttribute("safeUserName") %>.</h1>
            <p>Use this dashboard to oversee members, savings activity, and loan applications.</p>
        </section>

        <section class="summary-grid" aria-label="SACCO overview">
            <article class="summary-card">
                <span class="summary-label">Registered members</span>
                <strong id="totalMembers">—</strong>
                <span class="summary-note">Active SACCO members</span>
            </article>
            <article class="summary-card">
                <span class="summary-label">Total savings</span>
                <strong id="totalSavings">—</strong>
                <span class="summary-note">Across all accounts</span>
            </article>
            <article class="summary-card">
                <span class="summary-label">Pending loans</span>
                <strong id="pendingLoans">—</strong>
                <span class="summary-note">Awaiting review</span>
            </article>
        </section>

        <section class="content-grid">
            <article class="panel">
                <p class="eyebrow">Administration queue</p>
                <h2>Pending work</h2>
                <div class="empty-state"><h3>No items to review</h3><p>Member approvals and loan applications will appear here as those modules are added.</p></div>
            </article>
            <aside class="panel quick-actions">
                <p class="eyebrow">Admin actions</p>
                <h2>Manage SACCO</h2>
                <a class="button" href="<%= request.getContextPath() %>/savings">Manage savings</a>
                <a class="button secondary" href="<%= request.getContextPath() %>/loans">Review loans</a>
                <p class="muted">Use the links above to manage members, savings, and loans.</p>
            </aside>
        </section>
    </main>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        loadDashboardData();
    });

    function loadDashboardData() {
        fetch('<%= request.getContextPath() %>/api/dashboard-data')
            .then(response => response.json())
            .then(data => {
                document.getElementById('totalMembers').textContent = data.totalMembers || 0;
                document.getElementById('totalSavings').textContent = 'UGX ' + (data.totalSavings || 0).toLocaleString();
                document.getElementById('pendingLoans').textContent = data.pendingLoans || 0;
            })
            .catch(error => {
                console.error('Error loading dashboard data:', error);
            });
    }
</script>
</body>
</html>
