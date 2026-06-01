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
    <title>Manage Assignments</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f5f7; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .card { border: 1px solid #ddd; padding: 20px; margin-bottom: 20px; border-radius: 8px; background-color: #fafafa; }
        .btn { padding: 8px 15px; border-radius: 4px; text-decoration: none; color: white; border: none; cursor: pointer; font-weight: bold; }
        .btn-primary { background-color: #0d6efd; }
        .btn-success { background-color: #198754; }
        .btn-secondary { background-color: #6c757d; }
        .form-control { width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    </style>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/course-details?id=${courseId}" style="color: #666; text-decoration: none;">&larr; Back to Course</a>

    <h2>Course Assignments</h2>

    <% if (isInstructor) { %>
    <div class="card" style="border-left: 5px solid #dc3545;">
        <h3>Create New Assignment</h3>
        <form action="${pageContext.request.contextPath}/assignments" method="post" enctype="multipart/form-data">
            <input type="hidden" name="courseId" value="${courseId}">
            <input type="hidden" name="action" value="create_assignment">

            <label>Title:</label>
            <input type="text" name="title" class="form-control" required>

            <label>Instructions/Description:</label>
            <textarea name="description" class="form-control" rows="3" required></textarea>

            <label>Deadline:</label>
            <input type="datetime-local" name="deadline" class="form-control" required>

            <label>Attach Resource File (Optional, e.g., brief or starter code):</label>
            <input type="file" name="resourceFile" class="form-control">

            <button type="submit" class="btn btn-primary">Publish Assignment</button>
        </form>
    </div>
    <% } %>

    <c:forEach var="assignment" items="${assignments}">
        <div class="card">
            <h3 style="margin-top:0; color:#0d6efd;">${assignment.title}</h3>
            <p><strong>Deadline:</strong> ${assignment.deadline}</p>
            <p style="white-space: pre-wrap;">${assignment.description}</p>

            <c:if test="${not empty assignment.resourceFilename}">
                <div style="background: #e9ecef; padding: 10px; border-radius: 4px; margin-bottom: 15px;">
                    📄 <strong>Attached Resource:</strong> ${assignment.resourceFilename}
                    <a href="${pageContext.request.contextPath}/download-file?type=assignment&id=${assignment.assignmentId}" style="float: right;">Download</a>
                </div>
            </c:if>

            <% if (isStudent) { %>
            <hr style="border-top: 1px solid #ccc;">
            <form action="${pageContext.request.contextPath}/assignments" method="post" enctype="multipart/form-data" style="margin-top: 15px; margin-bottom: 15px;">
                <input type="hidden" name="courseId" value="${courseId}">
                <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
                <input type="hidden" name="action" value="submit_work">

                <label><strong>Upload your submission:</strong></label><br>
                <input type="file" name="submissionFile" required style="margin-top: 5px; margin-bottom: 10px;">
                <button type="submit" class="btn btn-success">Submit Work</button>
            </form>

            <a href="${pageContext.request.contextPath}/submissions?assignmentId=${assignment.assignmentId}" class="btn btn-secondary" style="display: inline-block;">View My Submission & Grade &rarr;</a>
            <% } %>

            <% if (isInstructor) { %>
            <a href="${pageContext.request.contextPath}/submissions?assignmentId=${assignment.assignmentId}" class="btn btn-primary" style="display: inline-block; margin-top: 10px;">View Student Submissions &rarr;</a>
            <% } %>
        </div>
    </c:forEach>

</div>

</body>
</html>