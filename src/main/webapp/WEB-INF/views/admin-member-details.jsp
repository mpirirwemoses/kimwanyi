<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Details | Kimwanyi SACCO</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #f5f5f5; padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
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
        
        .details-section { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .details-section h2 { color: #2c3e50; margin-bottom: 15px; font-size: 20px; }
        .detail-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #ddd; }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { color: #555; font-weight: 500; }
        .detail-value { color: #2c3e50; font-weight: bold; }
        
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-warning { background: #fff3cd; color: #856404; }
        .badge-danger { background: #f8d7da; color: #721c24; }
        
        .action-buttons { display: flex; gap: 10px; margin-top: 20px; }
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👤 Member Details</h1>
            <a href="${pageContext.request.contextPath}/admin-dashboard?section=members" class="btn btn-secondary">← Back to Members</a>
        </div>

        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${fn:replace(param.error, '+', ' ')}</div>
        </c:if>
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">Operation completed successfully!</div>
        </c:if>

        <c:if test="${not empty editMember}">
            <div class="details-section">
                <h2>Personal Information</h2>
                <div class="detail-row">
                    <span class="detail-label">Member ID:</span>
                    <span class="detail-value">${editMember.id}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Full Name:</span>
                    <span class="detail-value">${editMember.fullName}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Email:</span>
                    <span class="detail-value">${editMember.email}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Phone Number:</span>
                    <span class="detail-value">${editMember.phoneNumber}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">National ID:</span>
                    <span class="detail-value">${editMember.nationalId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Physical Address:</span>
                    <span class="detail-value">${editMember.physicalAddress}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Membership Number:</span>
                    <span class="detail-value">${editMember.membershipNumber}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="badge badge-${editMember.status == 'ACTIVE' ? 'success' : 'warning'}">${editMember.status}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Member Since:</span>
                    <span class="detail-value">${editMember.createdAtFormatted}</span>
                </div>
            </div>

            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=members&action=get-member&memberId=${editMember.id}" class="btn btn-success">✏️ Edit Member</a>
                <form action="${pageContext.request.contextPath}/admin-dashboard" method="POST" style="display: inline;" onsubmit="return confirm('Are you sure you want to deactivate this member? This action cannot be undone.')">
                    <input type="hidden" name="action" value="delete-member">
                    <input type="hidden" name="memberId" value="${editMember.id}">
                    <input type="hidden" name="section" value="members">
                    <button type="submit" class="btn btn-danger">🗑️ Deactivate Member</button>
                </form>
            </div>
        </c:if>

        <c:if test="${empty editMember}">
            <div class="details-section">
                <p style="text-align: center; color: #7f8c8d; padding: 40px;">Member not found or invalid member ID.</p>
            </div>
            <div class="action-buttons" style="justify-content: center;">
                <a href="${pageContext.request.contextPath}/admin-dashboard?section=members" class="btn btn-secondary">← Back to Members</a>
            </div>
        </c:if>
    </div>
</body>
</html>