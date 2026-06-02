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
        /* Modern Font Stack & Base Colors */
        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            background-color: #f4f7f6;
            color: #333;
        }

        /* Top Navigation Bar */
        .navbar {
            background-color: #ffffff;
            padding: 15px 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eef0f2;
        }
        .nav-brand { font-size: 1.5em; font-weight: bold; color: #2c3e50; margin: 0; }
        .nav-user { display: flex; align-items: center; gap: 20px; font-weight: 500; }

        /* Badges */
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 0.85em; font-weight: bold; display: inline-block; }
        .badge-instructor { background-color: #ffe6e6; color: #dc3545; border: 1px solid #f5c2c7; }
        .badge-student { background-color: #e7f1ff; color: #0d6efd; border: 1px solid #b6d4fe; }

        /* Main Container */
        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }

        /* Section Headers */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 2px solid #eef0f2;
            padding-bottom: 15px;
        }
        .section-header h2 { margin: 0; color: #2c3e50; font-size: 1.8em; }

        /* Buttons */
        .btn { padding: 8px 16px; border-radius: 6px; text-decoration: none; color: white; border: none; cursor: pointer; font-weight: 600; font-size: 0.95em; transition: all 0.2s ease; display: inline-block; }
        .btn-primary { background-color: #0d6efd; }
        .btn-primary:hover { background-color: #0b5ed7; box-shadow: 0 4px 8px rgba(13, 110, 253, 0.2); }
        .btn-success { background-color: #198754; }
        .btn-success:hover { background-color: #157347; box-shadow: 0 4px 8px rgba(25, 135, 84, 0.2); }
        .btn-secondary { background-color: #f8f9fa; color: #495057; border: 1px solid #ced4da; }
        .btn-secondary:hover { background-color: #e9ecef; }
        .btn-danger-outline { color: #dc3545; border: 1px solid #dc3545; background: transparent; padding: 6px 12px; }
        .btn-danger-outline:hover { background: #dc3545; color: white; }

        /* Course Cards Grid */
        .card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 25px;
            margin-top: 20px;
            margin-bottom: 50px;
        }

        .course-card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border: 1px solid #eef0f2;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .course-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
        }

        .card-banner {
            height: 12px;
            background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
        }
        .card-banner-student {
            background: linear-gradient(135deg, #20c997 0%, #198754 100%);
        }

        .card-body { padding: 25px; flex-grow: 1; display: flex; flex-direction: column; }
        .card-body h3 { margin: 0 0 10px 0; color: #2c3e50; font-size: 1.4em; }
        .card-body p { color: #6c757d; margin: 0 0 20px 0; line-height: 1.5; flex-grow: 1; }

        .card-footer {
            border-top: 1px solid #f0f2f5;
            padding: 15px 25px;
            background: #f8f9fa;
            text-align: right;
        }

        /* Empty State */
        .empty-state {
            grid-column: 1 / -1;
            background: #ffffff;
            border: 2px dashed #ced4da;
            border-radius: 12px;
            padding: 40px;
            text-align: center;
            color: #6c757d;
            font-size: 1.1em;
        }

        /* Dialog / Modal Styling */
        dialog {
            border: none;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            padding: 30px;
            max-width: 400px;
            text-align: center;
            color: #333;
        }
        dialog::backdrop { background: rgba(0,0,0,0.4); backdrop-filter: blur(4px); }
        dialog h3 { color: #198754; margin-top: 0; font-size: 1.8em; }
    </style>
</head>
<body>

<div class="navbar">
    <div class="nav-brand">📚 SubMS Platform</div>
    <div class="nav-user">
        <span>Welcome, <strong><%= username %></strong></span>

        <% if(isInstructor) { %><span class="badge badge-instructor">Instructor</span><% } %>
        <% if(isStudent) { %><span class="badge badge-student">Student</span><% } %>

        <div style="border-left: 2px solid #eef0f2; height: 24px; margin: 0 5px;"></div>

        <% if (isStudent) { %>
        <a href="${pageContext.request.contextPath}/profile" class="btn btn-secondary">My Profile</a>
        <% } %>
        <a href="<%= request.getContextPath() %>/logout" class="btn btn-danger-outline">Logout</a>
    </div>
</div>

<div class="container">

    <%-- INSTRUCTOR VIEW --%>
    <% if (isInstructor) { %>
    <div class="section-header">
        <h2>👨‍🏫 Instructor: My Courses</h2>
        <a href="${pageContext.request.contextPath}/createcourse" class="btn btn-primary">+ Create Course Space</a>
    </div>

    <div class="card-grid">
        <c:choose>
            <c:when test="${empty courses}">
                <div class="empty-state">
                    You haven't created any courses yet.<br>Click <strong>"+ Create Course Space"</strong> to get started.
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="course" items="${courses}">
                    <div class="course-card">
                        <div class="card-banner"></div>
                        <div class="card-body">
                            <h3>${course.title}</h3>
                            <p>${course.description}</p>
                            <span style="align-self: flex-start; background: ${course.active ? '#d1e7dd' : '#e2e3e5'}; color: ${course.active ? '#0f5132' : '#41464b'}; padding: 4px 10px; border-radius: 4px; font-size: 0.8em; font-weight: bold;">
                                    ${course.active ? 'Active' : 'Draft'}
                            </span>
                        </div>
                        <div class="card-footer">
                            <a href="course-details?id=${course.courseId}" class="btn btn-primary">Manage Course &rarr;</a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
    <% } %>


    <%-- STUDENT VIEW --%>
    <% if (isStudent) { %>
    <div class="section-header">
        <h2>🎓 My Enrolled Subjects</h2>
        <a href="${pageContext.request.contextPath}/enroll" class="btn btn-success">+ Enroll in Subject</a>
    </div>

    <div class="card-grid">
        <c:choose>
            <c:when test="${empty enrolledCourses}">
                <div class="empty-state">
                    You are not enrolled in any subjects.<br>Click <strong>"+ Enroll in Subject"</strong> to browse available courses.
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="course" items="${enrolledCourses}">
                    <div class="course-card">
                        <div class="card-banner card-banner-student"></div>
                        <div class="card-body">
                            <h3>${course.title}</h3>
                            <p>${course.description}</p>
                        </div>
                        <div class="card-footer">
                            <a href="course-details?id=${course.courseId}" class="btn btn-success">Enter Classroom &rarr;</a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
    <% } %>

</div>

<dialog id="successDialog">
    <h3>✅ Success!</h3>
    <p id="dialogMessage" style="font-size: 1.1em; margin-bottom: 25px; color: #495057;">Operation completed successfully.</p>
    <button onclick="closeDialog()" class="btn btn-success" style="width: 100%; padding: 12px;">Awesome, let's go!</button>
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