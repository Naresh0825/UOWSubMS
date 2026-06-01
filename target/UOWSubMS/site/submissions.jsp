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
    <title>Submissions: ${assignment.title}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f5f7; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header-box { background: #e9ecef; padding: 15px; border-radius: 6px; margin-bottom: 20px; border-left: 5px solid #0d6efd; }
        .btn { padding: 6px 12px; border-radius: 4px; text-decoration: none; color: white; border: none; cursor: pointer; font-size: 0.9em; }
        .btn-primary { background-color: #0d6efd; }
        .btn-success { background-color: #198754; }
        .btn-secondary { background-color: #6c757d; }

        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }

        .status-badge { padding: 4px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; color: white; }
        .bg-warning { background-color: #ffc107; color: #000; }
        .bg-success { background-color: #198754; }
    </style>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/assignments?courseId=${assignment.course.courseId}" style="color: #666; text-decoration: none;">&larr; Back to Assignments</a>

    <div class="header-box">
        <h2 style="margin-top: 0;">${assignment.title}</h2>
        <p style="margin: 5px 0;"><strong>Deadline:</strong> ${assignment.deadline}</p>
    </div>

    <% if (isInstructor) { %>
    <c:if test="${not empty errorMessage}">
        <p style="color: red; font-weight: bold;">${errorMessage}</p>
    </c:if>

    <h3>Student Submissions</h3>
    <c:choose>
        <c:when test="${empty submissions}">
            <p style="color: #666;">No students have submitted work for this assignment yet.</p>
        </c:when>
        <c:otherwise>
            <table>
                <thead>
                <tr>
                    <th>Student</th>
                    <th>Submitted At</th>
                    <th>File</th>
                    <th>Grade</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="sub" items="${submissions}">
                    <tr>
                        <td><strong>${sub.student.fullname}</strong></td>
                        <td>${sub.submitted_at}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/download-file?type=submission&id=${sub.submission_id}" class="btn btn-secondary">Download</a>
                        </td>

                        <td>
                            <form action="${pageContext.request.contextPath}/submissions" method="post" style="margin: 0; display: flex; gap: 5px;">
                                <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
                                <input type="hidden" name="submissionId" value="${sub.submission_id}">

                                <input type="text" name="grade" value="${sub.grade}" placeholder="e.g. 85/100" required style="width: 80px; padding: 5px;">
                                <button type="submit" class="btn btn-success">Save</button>
                            </form>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${not empty sub.grade}">
                                    <span class="status-badge bg-success">Graded</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge bg-warning">Needs Grading</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:otherwise>
    </c:choose>
    <% } %>

    <% if (isStudent) { %>
    <h3>My Submission</h3>
    <c:choose>
        <c:when test="${empty mySubmission}">
            <div style="padding: 20px; border: 1px dashed #ccc; border-radius: 6px; text-align: center; background: #fafafa;">
                <p style="color: #666;">You have not submitted anything for this assignment yet.</p>
                <a href="${pageContext.request.contextPath}/assignments?courseId=${assignment.course.courseId}" class="btn btn-primary">Go to Upload Page</a>
            </div>
        </c:when>
        <c:otherwise>
            <table style="width: 100%; border: 1px solid #eee; border-radius: 6px;">
                <tr style="background: #f8f9fa;">
                    <th style="width: 25%;">Status</th>
                    <td>
                        <span class="status-badge bg-success">Submitted successfully</span>
                    </td>
                </tr>
                <tr>
                    <th>Submitted At</th>
                    <td>${mySubmission.submitted_at}</td>
                </tr>
                <tr style="background: #f8f9fa;">
                    <th>My File</th>
                    <td>
                            ${mySubmission.file_name}
                        <a href="${pageContext.request.contextPath}/download-file?type=submission&id=${mySubmission.submission_id}" style="margin-left: 10px; font-weight: bold; color: #0d6efd;">(Download Copy)</a>
                    </td>
                </tr>
                <tr>
                    <th>Grade</th>
                    <td>
                        <c:choose>
                            <c:when test="${not empty mySubmission.grade}">
                                <strong style="color: #198754; font-size: 1.2em;">${mySubmission.grade}</strong>
                            </c:when>
                            <c:otherwise>
                                <em style="color: #666;">Not graded yet</em>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </table>
        </c:otherwise>
    </c:choose>
    <% } %>

</div>

</body>
</html>