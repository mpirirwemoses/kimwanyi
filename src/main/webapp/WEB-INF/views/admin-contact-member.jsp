<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Member | Kimwanyi SACCO</title>
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
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #d68910; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; }
        
        .contact-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .contact-section h2 { color: #2c3e50; margin-bottom: 15px; font-size: 20px; }
        .contact-info { display: grid; gap: 15px; }
        .contact-item { display: flex; align-items: center; gap: 15px; padding: 15px; background: white; border-radius: 6px; border-left: 4px solid #3498db; }
        .contact-icon { font-size: 24px; }
        .contact-details h3 { color: #2c3e50; margin-bottom: 5px; }
        .contact-details p { color: #555; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; color: #555; font-weight: 500; }
        .form-group input, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
        .form-group textarea { resize: vertical; min-height: 120px; }
        
        .action-buttons { display: flex; gap: 10px; margin-top: 20px; }
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📞 Contact Member</h1>
            <a href="${pageContext.request.contextPath}/admin-dashboard?section=members" class="btn btn-secondary">← Back to Members</a>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Operation completed successfully!</div>
        </c:if>

        <c:if test="${not empty editMember}">
            <div class="contact-section">
                <h2>Member Information</h2>
                <div class="contact-info">
                    <div class="contact-item">
                        <div class="contact-icon">👤</div>
                        <div class="contact-details">
                            <h3>${editMember.fullName}</h3>
                            <p>Member ID: ${editMember.id} | Membership: ${editMember.membershipNumber}</p>
                        </div>
                    </div>
                    <div class="contact-item">
                        <div class="contact-icon">📧</div>
                        <div class="contact-details">
                            <h3>Email</h3>
                            <p>${editMember.email}</p>
                        </div>
                    </div>
                    <c:if test="${not empty editMember.phoneNumber}">
                        <div class="contact-item">
                            <div class="contact-icon">📱</div>
                            <div class="contact-details">
                                <h3>Phone</h3>
                                <p>${editMember.phoneNumber}</p>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${not empty editMember.physicalAddress}">
                        <div class="contact-item">
                            <div class="contact-icon">📍</div>
                            <div class="contact-details">
                                <h3>Address</h3>
                                <p>${editMember.physicalAddress}</p>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>

            <div class="contact-section">
                <h2>Send Notification</h2>
                <form action="${pageContext.request.contextPath}/admin-dashboard" method="POST">
                    <input type="hidden" name="action" value="send-notification">
                    <input type="hidden" name="section" value="notifications">
                    <input type="hidden" name="recipientId" value="${editMember.id}">
                    <input type="hidden" name="recipientType" value="MEMBER">
                    
                    <div class="form-group">
                        <label>Title *</label>
                        <input type="text" name="title" required placeholder="Enter notification title">
                    </div>
                    
                    <div class="form-group">
                        <label>Message *</label>
                        <textarea name="message" required placeholder="Enter your message to the member..."></textarea>
                    </div>
                    
                    <div class="action-buttons">
                        <button type="submit" class="btn btn-success">📤 Send Notification</button>
                        <a href="${pageContext.request.contextPath}/admin-dashboard?section=members" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>

            <div class="contact-section">
                <h2>Quick Actions</h2>
                <div class="action-buttons">
                    <a href="mailto:${editMember.email}" class="btn btn-success">📧 Send Email</a>
                    <c:if test="${not empty editMember.phoneNumber}">
                        <a href="tel:${editMember.phoneNumber}" class="btn btn-warning">📱 Call Member</a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/admin-dashboard?section=members&action=get-member&memberId=${editMember.id}" class="btn btn-info">✏️ Edit Member</a>
                </div>
            </div>
        </c:if>

        <c:if test="${empty editMember}">
            <div class="contact-section">
                <p style="text-align: center; color: #7f8c8d; padding: 40px;">Member not found or invalid member ID.</p>
            </div>
            <div class="action-buttons" style="justify-content: center;">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=members" class="btn btn-secondary">← Back to Members</a>
            </div>
        </c:if>
    </div>
</body>
</html>