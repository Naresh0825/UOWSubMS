<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.security.Principal" %>
<%@ page import="com.subms.student.model.Course" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<%
    // Get the OIDC Principal
    Principal userPrincipal = request.getUserPrincipal();
    String username = (userPrincipal != null) ? userPrincipal.getName() : "Guest";

    // Check roles for conditional UI rendering
    boolean isInstructor = request.isUserInRole("teacher");
    boolean isStudent = request.isUserInRole("student");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Course Dashboard | ISIT950</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        .header { border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 20px; }
        .card-container { display: flex; gap: 20px; flex-wrap: wrap; }
        .card { border: 1px solid #ddd; padding: 15px; border-radius: 8px; width: 280px; background-color: #f8f9fa; }
        .instructor-badge { color: darkred; font-weight: bold; }
        .student-badge { color: darkblue; font-weight: bold; }
        .btn-action { background-color: #0d6efd; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block; }
        .btn-action:hover { background-color: #0b5ed7; }
        .dashboard-section-header { display: flex; justify-content: space-between; align-items: center; width: 100%; max-width: 900px; }
        .course-links a { display: block; margin-top: 8px; color: #0d6efd; text-decoration: none; }
        .course-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
<div class="header">
    <h1>Course Collaboration Platform</h1>
    <p>Welcome, <strong><%= username %></strong>!
        <% if(isInstructor) { %><span class="instructor-badge">(Instructor View)</span><% } %>
        <% if(isStudent) { %><span class="student-badge">(Student View)</span><% } %>
    </p>
</div>

<div class="content">

    <%-- INSTRUCTOR VIEW --%>
    <% if (isInstructor) { %>
    <div class="dashboard-section-header">
        <h2>Instructor Tools: My Courses</h2>
        <a href="${pageContext.request.contextPath}/createcourse" class="btn-action">+ Create Course Space</a>
    </div>

    <div class="card-container" style="max-width: 900px; margin-top: 15px;">
        <c:choose>
            <c:when test="${empty courses}">
                <p style="color: #666; width: 100%;">You haven't created any courses yet. Click "+ Create Course Space" to get started.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="course" items="${courses}">
                    <div class="card">
                        <h3 style="margin-top: 0; color: #333;">${course.title}</h3>
                        <p>${course.description}</p>
                        <hr style="border-top: 1px solid #ddd;">
                        <div class="course-links">
                            <a href="managecourse?id=${course.courseId}">Manage Course Materials &rarr;</a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
    <% } %>

    <%-- STUDENT VIEW --%>
    <% if (isStudent) { %>
    <div class="dashboard-section-header">
        <h2>My Enrolled Subjects</h2>
        <a href="${pageContext.request.contextPath}/enroll" class="btn-action">Enroll into subjects</a>
    </div>

    <div class="card-container" style="max-width: 900px; margin-top: 15px;">
        <c:choose>
            <c:when test="${empty enrolledCourses}">
                <p style="color: #666; width: 100%;">You are not enrolled in any of the subject.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="course" items="${enrolledCourses}">
                    <div class="card">
                        <h3 style="margin-top: 0; color: #333;">${course.title}</h3>
                        <p>${course.description}</p>
                        <hr style="border-top: 1px solid #ddd;">
                        <div class="course-links">
                            <a href="course-materials?id=${course.courseId}">View Course Materials &rarr;</a>
                            <a href="discussions?id=${course.courseId}">Participate in Discussions &rarr;</a>
                            <a href="assignments?id=${course.courseId}">Submit Assignments &rarr;</a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
    <% } %>

</div>

<br><br>
<a href="<%= request.getContextPath() %>/logout" style="color: red;">Logout</a>

<dialog id="successDialog" style="border: none; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 20px; max-width: 400px; text-align: center;">
    <h3 style="color: #2e7d32; margin-top: 0;">Success!</h3>
    <p id="dialogMessage">Operation completed successfully.</p>
    <button onclick="closeDialog()" style="background-color: #4CAF50; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer;">Awesome</button>
</dialog>

<script>
    const urlParams = new URLSearchParams(window.location.search);
    const status = urlParams.get('status');
    const dialog = document.getElementById('successDialog');
    const dialogMessage = document.getElementById('dialogMessage');

    // Dynamic success messages based on the URL parameter
    if (status === 'course_created') {
        dialogMessage.innerText = "The course space has been created successfully.";
        dialog.showModal();
        window.history.replaceState({}, document.title, window.location.pathname);
    } else if (status === 'enrolled') {
        dialogMessage.innerText = "You have successfully enrolled in the subject!";
        dialog.showModal();
        window.history.replaceState({}, document.title, window.location.pathname);
    }

    function closeDialog() {
        dialog.close();
    }
</script>

</body>
</html>