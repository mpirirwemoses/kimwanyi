<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign in | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
</head>
<body>
<main class="card" aria-labelledby="page-title">
    <p class="eyebrow">Credit SACCO</p>
    <h1 id="page-title">Welcome back</h1>
    <p>Sign in to view your member account.</p>

    <% if (request.getParameter("registered") != null) { %>
        <p class="message success" role="status">Account created. Please sign in.</p>
    <% } else if ("invalid".equals(request.getParameter("error"))) { %>
        <p class="message" role="alert">Incorrect email or password.</p>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/login">
        <label for="email">Email address</label>
        <input id="email" type="email" name="email" required autocomplete="email" autofocus>

        <label for="password">Password</label>
        <input id="password" type="password" name="password" required autocomplete="current-password">

        <button type="submit">Sign in</button>
    </form>
    <p class="switch">New to Credit SACCO? <a href="<%= request.getContextPath() %>/signup.jsp">Create an account</a></p>
</main>
</body>
</html>
