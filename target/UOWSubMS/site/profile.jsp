<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile | ISIT950</title>
    <style>
        /* Modern Font Stack & Base Colors */
        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 40px 20px;
            background-color: #f4f7f6;
            color: #333;
        }

        .container { max-width: 700px; margin: 0 auto; }

        .back-link {
            display: inline-block;
            color: #6c757d;
            text-decoration: none;
            font-weight: 600;
            margin-bottom: 20px;
            transition: color 0.2s;
        }
        .back-link:hover { color: #0d6efd; }

        /* Card Layout */
        .section-card {
            background: #ffffff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border: 1px solid #eef0f2;
            margin-bottom: 25px;
        }

        .section-header { border-bottom: 2px solid #f0f2f5; padding-bottom: 15px; margin-bottom: 20px; }
        .section-header h2 { margin: 0; color: #2c3e50; font-size: 1.5em; }

        /* Form Elements */
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #495057; }
        .form-control {
            width: 100%; padding: 10px 12px; border: 1px solid #ced4da; border-radius: 6px;
            font-family: inherit; font-size: 0.95em; box-sizing: border-box; transition: border-color 0.2s;
        }
        .form-control:focus { border-color: #86b7fe; outline: 0; box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1); }
        .form-control:disabled { background-color: #e9ecef; cursor: not-allowed; }

        .btn { padding: 10px 20px; border-radius: 6px; text-decoration: none; color: white; border: none; cursor: pointer; font-weight: 600; transition: all 0.2s ease; width: 100%; }
        .btn-primary { background-color: #0d6efd; }
        .btn-primary:hover { background-color: #0b5ed7; box-shadow: 0 4px 8px rgba(13, 110, 253, 0.2); }

        /* Badges */
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 0.85em; font-weight: bold; display: inline-block;}
        .badge-pro { background-color: #ffc107; color: #856404; }
        .badge-standard { background-color: #6c757d; color: white; }

        /* Alerts */
        .alert { padding: 15px; border-radius: 6px; margin-bottom: 20px; font-weight: 500; }
        .alert-success { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
    </style>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/site" class="back-link">&larr; Back to Dashboard</a>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <div class="section-card">
        <div class="section-header" style="display: flex; justify-content: space-between; align-items: center;">
            <h2>My Profile</h2>
            <c:choose>
                <c:when test="${user.membership}">
                    <span class="badge badge-pro">⭐ Pro Member</span>
                </c:when>
                <c:otherwise>
                    <span class="badge badge-standard">Standard User</span>
                </c:otherwise>
            </c:choose>
        </div>

        <form action="${pageContext.request.contextPath}/profile" method="post">

            <div style="display: flex; gap: 20px;">
                <div class="form-group" style="flex: 1;">
                    <label>Full Name</label>
                    <input type="text" class="form-control" value="${user.fullname}" disabled>
                </div>
                <div class="form-group" style="flex: 1;">
                    <label>Email Address</label>
                    <input type="email" class="form-control" value="${user.email}" disabled>
                </div>
            </div>

            <hr style="border-top: 1px solid #f0f2f5; margin: 25px 0;">
            <h3 style="color: #2c3e50; margin-top: 0; margin-bottom: 20px;">Collaboration Preferences</h3>
            <p style="color: #6c757d; font-size: 0.9em; margin-bottom: 20px;">Share your skills and availability to help form project groups easily.</p>

            <div class="form-group">
                <label>Skills / Expertise (e.g., Java, React, UI Design)</label>
                <input type="text" name="skills" class="form-control" value="${user.skills}" placeholder="What are you good at?">
            </div>

            <div class="form-group">
                <label>Preferred Collaboration Mode</label>
                <select name="collaborationMode" class="form-control">
                    <option value="Online" ${user.collaborationMode == 'Online' ? 'selected' : ''}>Online (Zoom, Teams)</option>
                    <option value="Offline" ${user.collaborationMode == 'Offline' ? 'selected' : ''}>Offline (In-Person)</option>
                    <option value="Hybrid" ${user.collaborationMode == 'Hybrid' ? 'selected' : ''}>Hybrid (Flexible)</option>
                </select>
            </div>

            <div class="form-group">
                <label>General Availability</label>
                <input type="text" name="availability" class="form-control" value="${user.availability}" placeholder="e.g., Weekends, Mon-Wed Evenings">
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top: 10px;">Save Profile Settings</button>
        </form>
    </div>
</div>

</body>
</html>