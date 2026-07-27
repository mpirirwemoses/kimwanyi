<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
</head>
<body class="dashboard-body">
<div class="dashboard-shell">
    <header class="topbar">
        <a class="brand" href="<%= request.getContextPath() %>/dashboard">Credit SACCO</a>
        <form method="post" action="<%= request.getContextPath() %>/logout">
            <button class="button secondary" type="submit">Log out</button>
        </form>
    </header>

    <main class="dashboard-content">
        <section class="welcome-panel">
            <p class="eyebrow">Member dashboard</p>
            <h1>Good to see you, <%= request.getAttribute("safeUserName") %>.</h1>
            <p>Track your SACCO membership and manage your financial goals in one place.</p>
        </section>

        <section class="summary-grid" aria-label="Account overview">
            <article class="summary-card">
                <span class="summary-label">Savings balance</span>
                <strong>UGX 0.00</strong>
                <span class="summary-note">Your deposits will appear here.</span>
            </article>
            <article class="summary-card">
                <span class="summary-label">Active loans</span>
                <strong>0</strong>
                <span class="summary-note">You have no active loans.</span>
            </article>
            <article class="summary-card">
                <span class="summary-label">Next action</span>
                <strong>Get started</strong>
                <span class="summary-note">Complete your member profile.</span>
            </article>
        </section>

        <section class="content-grid">
            <article class="panel">
                <div class="panel-heading">
                    <div><p class="eyebrow">Activity</p><h2>Recent activity</h2></div>
                </div>
                <div class="empty-state">
                    <h3>No activity yet</h3>
                    <p>Your savings contributions, loan applications, and repayments will be shown here.</p>
                </div>
            </article>
            <aside class="panel quick-actions">
                <p class="eyebrow">Quick actions</p>
                <h2>Member services</h2>
                <button type="button" disabled>Make a contribution</button>
                <a class="button secondary" href="<%= request.getContextPath() %>/loans">Apply for a loan</a>
                <p class="muted">More services will be added soon.</p>
            </aside>
        </section>
    </main>
</div>
</body>
</html>
