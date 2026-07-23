<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send Notification | Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #2c3e50; }
        .header h1 { color: #2c3e50; font-size: 28px; }
        .btn { padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; }
        .btn:hover { background: #2980b9; }
        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #2c3e50; font-weight: 600; font-size: 14px; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; transition: border-color 0.3s; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline: none; border-color: #3498db; }
        .form-group textarea { resize: vertical; min-height: 120px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        
        .info-box { background: #d1ecf1; padding: 15px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid #0c5460; }
        .info-box p { margin: 5px 0; color: #0c5460; }
        .info-box strong { color: #0c5460; }
        
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        
        .checkbox-group { display: flex; align-items: center; gap: 10px; margin-top: 10px; }
        .checkbox-group input[type="checkbox"] { width: auto; }
        
        .back-link { color: #3498db; text-decoration: none; font-weight: bold; }
        .back-link:hover { color: #2980b9; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📧 Send Notification</h1>
            <div>
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=notifications" class="back-link">← Back to Notifications</a>
            </div>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Notification sent successfully!</div>
        </c:if>

        <div class="info-box">
            <p><strong>ℹ️ Information:</strong></p>
            <p>• In-app notifications will be visible to recipients in their notification center</p>
            <p>• Email notifications will be sent to the configured email address</p>
            <p>• All notifications are logged in the audit trail</p>
        </div>

        <form method="POST" action="${pageContext.request.contextPath}/admin-dashboard">
            <input type="hidden" name="action" value="send-notification">
            <input type="hidden" name="section" value="notifications">

            <div class="form-row">
                <div class="form-group">
                    <label for="recipientType">Recipient Type *</label>
                    <select id="recipientType" name="recipientType" required onchange="toggleRecipientFields()">
                        <option value="ALL">All Users</option>
                        <option value="MEMBER">Specific Member</option>
                        <option value="ADMIN">All Admins</option>
                    </select>
                </div>
                <div class="form-group" id="recipientIdGroup" style="display: none;">
                    <label for="recipientId">Select Member *</label>
                    <select id="recipientId" name="recipientId">
                        <option value="">-- Select Member --</option>
                        <c:forEach var="member" items="${members}">
                            <option value="${member.id}">${member.fullName} (${member.email})</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="title">Notification Title *</label>
                <input type="text" id="title" name="title" required maxlength="200" placeholder="Enter notification title...">
            </div>

            <div class="form-group">
                <label for="message">Message *</label>
                <textarea id="message" name="message" required maxlength="1000" placeholder="Enter your notification message here..."></textarea>
            </div>

            <div class="checkbox-group">
                <input type="checkbox" id="sendEmail" name="sendEmail" checked>
                <label for="sendEmail" style="margin: 0; font-weight: normal;">Send as email notification</label>
            </div>

            <div class="form-group" style="margin-top: 30px; display: flex; gap: 10px;">
                <button type="submit" class="btn btn-success">📤 Send Notification</button>
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=notifications" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>

    <script>
        function toggleRecipientFields() {
            const recipientType = document.getElementById('recipientType').value;
            const recipientIdGroup = document.getElementById('recipientIdGroup');
            const recipientIdSelect = document.getElementById('recipientId');
            
            if (recipientType === 'MEMBER') {
                recipientIdGroup.style.display = 'block';
                recipientIdSelect.setAttribute('required', 'required');
            } else {
                recipientIdGroup.style.display = 'none';
                recipientIdSelect.removeAttribute('required');
            }
        }

        // Initial setup
        toggleRecipientFields();
    </script>
</body>
</html>