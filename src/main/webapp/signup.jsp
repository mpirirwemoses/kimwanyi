<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create account | Credit SACCO</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
</head>
<body>
<main class="card" aria-labelledby="page-title">
    <p class="eyebrow">Credit SACCO</p>
    <h1 id="page-title">Create your account</h1>
    <p>Register to get started with Credit SACCO.</p>

    <% if ("exists".equals(request.getParameter("error"))) { %>
        <p class="message" role="alert">An account with that email already exists.</p>
    <% } else if ("validation".equals(request.getParameter("error"))) { %>
        <p class="message" role="alert">Enter a valid name and email, use a password of at least 8 characters, and make sure both passwords match.</p>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/signup">
        <label for="fullName">Full name</label>
        <input id="fullName" type="text" name="fullName" required maxlength="100" autocomplete="name" autofocus>

        <label for="email">Email address</label>
        <input id="email" type="email" name="email" required maxlength="150" autocomplete="email">

        <label for="password">Password</label>
        <input id="password" type="password" name="password" required minlength="8" autocomplete="new-password" aria-describedby="password-help">
        <small id="password-help">Use at least 8 characters.</small>

        <label for="confirmPassword">Confirm password</label>
        <input id="confirmPassword" type="password" name="confirmPassword" required minlength="8" autocomplete="new-password">

        <button type="submit">Create account</button>
    </form>
    <p class="switch">Already registered? <a href="<%= request.getContextPath() %>/login.jsp">Sign in</a></p>
</main>
</body>
</html>
