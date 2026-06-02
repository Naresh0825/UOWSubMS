<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%
    boolean isInstructor = request.isUserInRole("teacher");
    boolean isStudent = request.isUserInRole("student");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Discussion Thread | ISIT950</title>
    <style>
        /* Modern Font Stack & Base Colors */
        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 40px 20px;
            background-color: #f4f7f6;
            color: #333;
        }

        .container { max-width: 850px; margin: 0 auto; }

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
        .card {
            background: #ffffff;
            padding: 25px 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border: 1px solid #eef0f2;
            margin-bottom: 20px;
        }

        /* Buttons */
        .btn { padding: 8px 16px; border-radius: 6px; text-decoration: none; color: white; border: none; cursor: pointer; font-weight: 600; font-size: 0.9em; transition: all 0.2s ease; }
        .btn-primary { background-color: #0d6efd; }
        .btn-primary:hover { background-color: #0b5ed7; box-shadow: 0 4px 8px rgba(13, 110, 253, 0.2); }
        .btn-danger { background-color: #dc3545; }
        .btn-danger:hover { background-color: #c82333; }

        /* Topic & Reply Styles */
        .topic-header {
            background: linear-gradient(135deg, #6f42c1 0%, #46198f 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 12px;
            margin-bottom: 25px;
        }
        .topic-header h2 { margin: 0 0 10px 0; font-size: 1.6em; line-height: 1.4; }

        .reply-card {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            background: #fff;
            transition: box-shadow 0.2s;
        }
        .reply-card:hover { box-shadow: 0 4px 10px rgba(0,0,0,0.04); }
        .reply-header {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #f0f2f5;
            padding-bottom: 12px;
            margin-bottom: 15px;
        }
        .reply-content { margin: 0; line-height: 1.6; color: #495057; white-space: pre-wrap; font-size: 1.05em; }

        /* Forms */
        .form-control { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 6px; font-family: inherit; font-size: 1em; box-sizing: border-box; transition: border-color 0.2s;}
        .form-control:focus { border-color: #86b7fe; outline: 0; box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1); }

        /* Alerts/Dialogs */
        .alert { padding: 15px 20px; border-radius: 8px; margin-bottom: 25px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
        .alert-error { background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
        .alert-success { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
    </style>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/course-details?id=${topic.course.courseId}" class="back-link">&larr; Back to Course Details</a>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">
            ✅ <span>${sessionScope.successMessage}</span>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-error">
            🔒 <span>${sessionScope.errorMessage}</span>
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <div class="topic-header">
        <h2>💬 ${topic.content}</h2>
        <div style="opacity: 0.9; font-size: 0.9em; margin-top: 15px; background: rgba(0,0,0,0.15); padding: 8px 15px; border-radius: 20px; display: inline-block;">
            Started by <strong>${topic.author.fullname} ${topic.author.role == 'teacher' ? '(Instructor)' : ''}</strong> on ${topic.created_at}
        </div>
    </div>

    <h3 style="color: #2c3e50; margin-bottom: 20px; border-bottom: 2px solid #eef0f2; padding-bottom: 10px;">Discussion Replies</h3>

    <c:choose>
        <c:when test="${empty replies}">
            <div style="background: #f8f9fa; border: 2px dashed #ced4da; padding: 40px; text-align: center; border-radius: 8px; color: #6c757d; margin-bottom: 25px;">
                No replies yet. Be the first to answer or ask for clarification!
            </div>
        </c:when>
        <c:otherwise>
            <div style="display: flex; flex-direction: column;">
                <c:forEach var="reply" items="${replies}">
                    <div class="reply-card" style="border-left: 4px solid ${reply.author.role == 'teacher' ? '#dc3545' : '#20c997'};">
                        <div class="reply-header">
                            <div>
                                <strong style="color: #2c3e50; font-size: 1.1em;">${reply.author.fullname}</strong>
                                <c:if test="${reply.author.role == 'teacher'}">
                                    <span style="color: #dc3545; font-weight: bold; font-size: 0.85em; margin-left: 5px;">(Instructor)</span>
                                </c:if>
                                <br><small style="color: #888; font-weight: 500;">📅 ${reply.created_at}</small>
                            </div>

                            <% if (isInstructor) { %>
                            <form action="${pageContext.request.contextPath}/discussion-details" method="post" style="margin: 0;">
                                <input type="hidden" name="topicId" value="${topic.post_id}">
                                <input type="hidden" name="replyId" value="${reply.post_id}">
                                <input type="hidden" name="action" value="delete_reply">
                                <button type="submit" class="btn btn-danger" style="padding: 5px 10px; font-size: 0.85em;" onclick="return confirm('Are you sure you want to delete this reply?');">Delete</button>
                            </form>
                            <% } %>
                        </div>
                        <p class="reply-content">${reply.content}</p>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

    <div class="card" style="margin-top: 30px; background: #f8f9fa; border: 1px solid #ced4da;">
        <h4 style="margin-top: 0; color: #2c3e50; margin-bottom: 15px;">Post a Reply</h4>
        <form action="${pageContext.request.contextPath}/discussion-details" method="post" style="display: flex; flex-direction: column; gap: 15px;">
            <input type="hidden" name="topicId" value="${topic.post_id}">
            <input type="hidden" name="action" value="post_reply">

            <textarea name="content" rows="4" class="form-control" placeholder="Write your reply here..." required style="resize: vertical;"></textarea>
            <button type="submit" class="btn btn-primary" style="align-self: flex-start; padding: 10px 20px;">Submit Reply</button>
        </form>
    </div>

</div>

</body>
</html>