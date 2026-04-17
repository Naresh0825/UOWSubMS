<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.security.Principal" %>
<%
    // Get the OIDC Principal (configured as preferred_username in your oidc.json)
    Principal userPrincipal = request.getUserPrincipal();
    String username = (userPrincipal != null) ? userPrincipal.getName() : "Guest";

    // Check roles for conditional UI rendering
    boolean isInstructor = request.isUserInRole("admin");
    boolean isStudent = request.isUserInRole("user");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Course Dashboard | ISIT950</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        .header { border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 20px; }
        .card-container { display: flex; gap: 20px; flex-wrap: wrap; }
        .card { border: 1px solid #ddd; padding: 15px; border-radius: 8px; width: 250px; }
        .instructor-badge { color: darkred; font-weight: bold; }
        .student-badge { color: darkblue; font-weight: bold; }
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
    <% if (isInstructor) { %>
    <h2>Instructor Tools</h2>
    <div class="card-container">
        <div class="card">
            <h3>Course Setup</h3>
            <p>Upload syllabus and organize sections [cite: 32-33].</p>
            <a href="setup.jsp">Go to Setup</a>
        </div>
        <div class="card">
            <h3>Assignments</h3>
            <p>Create and grade submissions [cite: 36-37].</p>
            <a href="manage-assignments.jsp">Manage</a>
        </div>
    </div>
    <% } %>

    <% if (isStudent) { %>
    <h2>Student Coursework</h2>
    <div class="card-container">
        <div class="card">
            <h3>Materials</h3>
            <p>Download lecture slides and readings[cite: 20, 34].</p>
            <a href="materials.jsp">View Resources</a>
        </div>
        <div class="card">
            <h3>Discussion Forum</h3>
            <p>Exchange ideas with peers [cite: 21-22].</p>
            <a href="discussions.jsp">Join Chat</a>
        </div>
    </div>
    <% } %>
</div>

<br>
<a href="<%= request.getContextPath() %>/logout">Logout</a>
</body>
</html>