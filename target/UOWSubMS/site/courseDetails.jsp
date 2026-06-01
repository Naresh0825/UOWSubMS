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

    <div class="section" style="background-color: #e9ecef; padding: 20px; border-radius: 8px;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h2 style="margin-top: 0; color: #333;">Assignments & Submissions</h2>
            <a href="${pageContext.request.contextPath}/assignments?courseId=${course.courseId}" class="btn btn-primary">Go to Assignments &rarr;</a>
        </div>
        <% if (isStudent) { %>
        <p style="color: #555; margin-bottom: 0;">Check upcoming deadlines, download resource files, and upload your coursework submissions here.</p>
        <% } else if (isInstructor) { %>
        <p style="color: #555; margin-bottom: 0;">Create new assignments, upload instructions, and review student submissions here.</p>
        <% } %>
    </div>

    <div class="section">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h2>Course Materials</h2>
        </div>

        <% if (isInstructor) { %>
        <div class="admin-controls" style="margin-bottom: 20px;">
            <h4 style="margin-top: 0;">Upload New Course Material</h4>
            <form action="${pageContext.request.contextPath}/course-details" method="post" enctype="multipart/form-data" style="margin: 0; display: flex; gap: 10px; align-items: center;">
                <input type="hidden" name="courseId" value="${course.courseId}">
                <input type="hidden" name="action" value="upload_material">

                <input type="text" name="materialTitle" placeholder="Title (e.g. Week 1 Slides)" required style="padding: 8px; border: 1px solid #ccc; border-radius: 4px; flex-grow: 1;">
                <input type="file" name="materialFile" required>
                <button type="submit" class="btn btn-primary">Upload Material</button>
            </form>
        </div>
        <% } %>

        <c:choose>
            <c:when test="${empty materials}">
                <p style="color: #666; background: #f8f9fa; padding: 15px; border-radius: 5px; text-align: center;">No course materials have been uploaded yet.</p>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 10px;">
                    <c:forEach var="material" items="${materials}">
                        <div class="file-box">
                            <div>
                                <strong style="color: #333; display: block; margin-bottom: 5px;">${material.title}</strong>
                                <span style="font-size: 0.9em; color: #666;">📄 ${material.file_name}</span>
                            </div>
                            <div style="display: flex; gap: 10px; align-items: center;">
                                <a href="${pageContext.request.contextPath}/download-file?type=material&id=${material.material_id}" class="btn btn-primary" style="padding: 6px 12px;">Download</a>

                                <% if (isInstructor) { %>
                                <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0;">
                                    <input type="hidden" name="courseId" value="${course.courseId}">
                                    <input type="hidden" name="materialId" value="${material.material_id}">
                                    <input type="hidden" name="action" value="delete_material">
                                    <button type="submit" class="btn btn-danger" style="padding: 6px 12px;" onclick="return confirm('Are you sure you want to delete this material?');">Delete</button>
                                </form>
                                <% } %>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section">
        <h2>Discussion Forum</h2>
        <p style="color: #666;">Ask questions, share resources, and collaborate with your peers.</p>
        <% if (isInstructor) { %>
        <div style="background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #ddd;">
            <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0; display: flex; flex-direction: column; gap: 10px;">
                <input type="hidden" name="courseId" value="${course.courseId}">
                <input type="hidden" name="action" value="post_discussion">

                <textarea name="content" rows="3" placeholder="Start a new discussion topic..." required style="padding: 10px; border: 1px solid #ccc; border-radius: 4px; resize: vertical; width: 100%; box-sizing: border-box;"></textarea>

                <button type="submit" class="btn btn-primary" style="align-self: flex-end;">Post Topic</button>
            </form>
        </div>
        <% } %>

        <c:choose>
            <c:when test="${empty discussions}">
                <p style="color: #666; text-align: center; padding: 20px;">No discussions yet. Be the first to start a conversation!</p>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 15px;">
                    <c:forEach var="post" items="${discussions}">
                        <div style="border: 1px solid #e0e0e0; border-radius: 6px; padding: 15px; background: #fff; transition: background-color 0.2s;">

                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px; border-bottom: 1px solid #eee; padding-bottom: 10px;">
                                <small style="color: #888;">
                                    Started by <strong style="color: ${post.author.role == 'teacher' ? '#dc3545' : '#0d6efd'};">${post.author.fullname}</strong> on ${post.createdAt}
                                </small>

                                <% if (isInstructor) { %>
                                <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0;">
                                    <input type="hidden" name="courseId" value="${course.courseId}">
                                    <input type="hidden" name="postId" value="${post.post_id}">
                                    <input type="hidden" name="action" value="delete_discussion">
                                    <button type="submit" class="btn btn-danger" style="padding: 4px 8px; font-size: 0.8em;" onclick="return confirm('Delete this post and all its replies?');">Delete</button>
                                </form>
                                <% } %>
                            </div>

                            <a href="${pageContext.request.contextPath}/discussion-details?topicId=${post.post_id}" style="text-decoration: none; color: inherit; display: block;">
                                <h3 style="margin: 0; color: #0d6efd;">${post.content}</h3>
                            </a>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>