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
    <title>${course.title} Details | ISIT950</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f5f7; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .section { margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
        .btn { padding: 8px 15px; border-radius: 4px; text-decoration: none; color: white; border: none; cursor: pointer; font-weight: bold; }
        .btn-primary { background-color: #0d6efd; }
        .btn-danger { background-color: #dc3545; }
        .file-box { background: #f8f9fa; padding: 15px; border: 1px solid #ddd; border-radius: 5px; display: flex; justify-content: space-between; align-items: center; }
        .admin-controls { margin-top: 15px; padding: 15px; background: #fff3cd; border-left: 4px solid #ffc107; }
    </style>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/site" style="color: #666; text-decoration: none;">&larr; Back to Dashboard</a>

    <div class="section" style="margin-top: 20px;">
        <h1 style="margin: 0; color: #333;">${course.title}</h1>
        <p style="color: #666; font-size: 1.1em;">${course.description}</p>
        <span style="background: ${course.active ? '#198754' : '#6c757d'}; color: white; padding: 3px 8px; border-radius: 3px; font-size: 0.8em;">
            ${course.active ? 'Active' : 'Draft'}
        </span>
    </div>

    <div class="section">
        <h2>Subject Outline</h2>

        <c:choose>
            <c:when test="${not empty course.outlineFilename}">
                <div class="file-box">
                    <span>📄 <strong>${course.outlineFilename}</strong></span>
                    <a href="${pageContext.request.contextPath}/download-syllabus?courseId=${course.courseId}" class="btn btn-primary">Download</a>
                </div>

                <% if (isInstructor) { %>
                <div class="admin-controls">
                    <h4>Instructor Tools: Replace or Delete Outline</h4>
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <form action="${pageContext.request.contextPath}/course-details" method="post" enctype="multipart/form-data" style="margin: 0; display: flex; gap: 10px;">
                            <input type="hidden" name="courseId" value="${course.courseId}">
                            <input type="hidden" name="action" value="replace">
                            <input type="file" name="newSyllabus" required>
                            <button type="submit" class="btn btn-primary">Upload Replacement</button>
                        </form>

                        <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0;">
                            <input type="hidden" name="courseId" value="${course.courseId}">
                            <input type="hidden" name="action" value="delete">
                            <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete the outline?');">Delete Outline</button>
                        </form>
                    </div>
                </div>
                <% } %>
            </c:when>

            <c:otherwise>
                <p style="color: #666;">No subject outline has been uploaded yet.</p>
                <% if (isInstructor) { %>
                <form action="${pageContext.request.contextPath}/course-details" method="post" enctype="multipart/form-data" class="admin-controls">
                    <input type="hidden" name="courseId" value="${course.courseId}">
                    <input type="hidden" name="action" value="replace">
                    <input type="file" name="newSyllabus" required>
                    <button type="submit" class="btn btn-primary">Upload Outline</button>
                </form>
                <% } %>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h2>Course Announcements</h2>
        </div>

        <% if (isInstructor) { %>
        <div class="admin-controls" style="margin-bottom: 20px;">
            <h4 style="margin-top: 0;">Post New Announcement</h4>
            <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0; display: flex; flex-direction: column; gap: 10px;">
                <input type="hidden" name="courseId" value="${course.courseId}">
                <input type="hidden" name="action" value="post_announcement">

                <input type="text" name="title" placeholder="Announcement Title" required style="padding: 8px; border: 1px solid #ccc; border-radius: 4px;">
                <textarea name="content" rows="3" placeholder="Type your announcement here..." required style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; resize: vertical;"></textarea>

                <button type="submit" class="btn btn-primary" style="align-self: flex-start;">Post Announcement</button>
            </form>
        </div>
        <% } %>

        <c:choose>
            <c:when test="${empty announcements}">
                <p style="color: #666; background: #f8f9fa; padding: 15px; border-radius: 5px; text-align: center;">No announcements have been posted yet.</p>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 15px;">
                    <c:forEach var="announcement" items="${announcements}">
                        <div style="border: 1px solid #e0e0e0; border-radius: 6px; padding: 15px; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                <h3 style="margin: 0; color: #0d6efd; font-size: 1.1em;">${announcement.title}</h3>
                                <small style="color: #888;">${announcement.postedAt}</small>
                            </div>
                            <p style="margin: 0; color: #333; line-height: 1.5; white-space: pre-wrap;">${announcement.content}</p>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section">
        <h2>Course Materials</h2>
        <p style="color: #666;">Materials will be listed here...</p>
    </div>

</div>

</body>
</html>