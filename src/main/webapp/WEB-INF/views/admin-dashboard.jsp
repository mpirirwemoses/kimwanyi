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
            <article class="summary-card"><span class="summary-label">Registered members</span><strong>—</strong><span class="summary-note">Available when the member module is completed.</span></article>
            <article class="summary-card"><span class="summary-label">Total savings</span><strong>—</strong><span class="summary-note">Available when deposits are recorded.</span></article>
            <article class="summary-card"><span class="summary-label">Pending loans</span><strong>—</strong><span class="summary-note">Available when the loan module is completed.</span></article>
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
                <button type="button" disabled>Manage members</button>
                <a class="button secondary" href="<%= request.getContextPath() %>/loans">Review loans</a>
                <p class="muted">More admin tools will be added soon.</p>
            </aside>
        </section>
    </main>
</div>
</body>
</html>
