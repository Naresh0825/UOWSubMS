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
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f5f7; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .btn { padding: 8px 15px; border-radius: 4px; text-decoration: none; color: white; border: none; cursor: pointer; font-weight: bold; }
        .btn-primary { background-color: #0d6efd; }
        .btn-danger { background-color: #dc3545; }

        /* Topic styles */
        .topic-header { background-color: #e9ecef; padding: 20px; border-radius: 6px; margin-top: 15px; margin-bottom: 30px; border-left: 5px solid #0d6efd; }
        .topic-content { font-size: 1.2em; color: #333; margin: 0 0 10px 0; white-space: pre-wrap; }

        /* Reply styles */
        .reply-card { border: 1px solid #e0e0e0; border-radius: 6px; padding: 15px; margin-bottom: 15px; background: #fff; display: flex; flex-direction: column; }
        .reply-header { display: flex; justify-content: space-between; border-bottom: 1px solid #eee; padding-bottom: 8px; margin-bottom: 10px; }
        .reply-content { margin: 0; line-height: 1.5; white-space: pre-wrap; }

        .instructor-tag { color: #dc3545; font-weight: bold; font-size: 0.9em; }
        .student-tag { color: #0d6efd; font-weight: bold; font-size: 0.9em; }
    </style>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/course-details?id=${topic.course.courseId}" style="color: #666; text-decoration: none;">&larr; Back to Course Details</a>

    <div class="topic-header">
        <h2 class="topic-content">${topic.content}</h2>
        <small style="color: #666;">
            Posted by <span class="instructor-tag">${topic.author.fullname} (Instructor)</span> on ${topic.created_at}
        </small>
    </div>

    <h3>Discussion Replies</h3>

    <c:choose>
        <c:when test="${empty replies}">
            <p style="color: #666; font-style: italic;">No replies yet. Be the first to answer or ask for clarification!</p>
        </c:when>
        <c:otherwise>
            <c:forEach var="reply" items="${replies}">
                <div class="reply-card">
                    <div class="reply-header">
                        <div>
                            <strong>${reply.author.fullname}</strong>
                            <c:choose>
                                <c:when test="${reply.author.role == 'teacher'}"><span class="instructor-tag">(Instructor)</span></c:when>

                            </c:choose>
                            <br><small style="color: #888;">${reply.created_at}</small>
                        </div>

                        <% if (isInstructor) { %>
                        <form action="${pageContext.request.contextPath}/discussion-details" method="post" style="margin: 0;">
                            <input type="hidden" name="topicId" value="${topic.post_id}">
                            <input type="hidden" name="replyId" value="${reply.post_id}">
                            <input type="hidden" name="action" value="delete_reply">
                            <button type="submit" class="btn btn-danger" style="padding: 4px 8px; font-size: 0.8em;" onclick="return confirm('Delete this reply?');">Delete</button>
                        </form>
                        <% } %>
                    </div>
                    <p class="reply-content">${reply.content}</p>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>

    <div style="margin-top: 30px; background: #f8f9fa; padding: 20px; border-radius: 6px; border: 1px solid #ddd;">
        <h4 style="margin-top: 0;">Post a Reply</h4>
        <form action="${pageContext.request.contextPath}/discussion-details" method="post" style="display: flex; flex-direction: column; gap: 10px;">

            <input type="hidden" name="topicId" value="${topic.post_id}">
            <input type="hidden" name="action" value="post_reply">

            <textarea name="content" rows="4" placeholder="Write your reply here..." required style="padding: 10px; border: 1px solid #ccc; border-radius: 4px; resize: vertical;"></textarea>
            <button type="submit" class="btn btn-primary" style="align-self: flex-start;">Submit Reply</button>
        </form>
    </div>

</div>

</body>
</html>