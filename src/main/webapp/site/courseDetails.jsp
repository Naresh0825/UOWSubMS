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
        /* Modern Font Stack & Base Colors */
        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 40px 20px;
            background-color: #f4f7f6;
            color: #333;
        }

        .container {
            max-width: 950px;
            margin: 0 auto;
        }

        /* Nav Link */
        .back-link {
            display: inline-block;
            color: #6c757d;
            text-decoration: none;
            font-weight: 600;
            margin-bottom: 20px;
            transition: color 0.2s;
        }
        .back-link:hover { color: #0d6efd; }

        /* Card Layout for Sections */
        .section-card {
            background: #ffffff;
            margin-bottom: 30px;
            padding: 25px 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            border: 1px solid #eef0f2;
        }

        /* Section Headers */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #f0f2f5;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .section-header h2 { margin: 0; color: #2c3e50; font-size: 1.5em; }

        /* Course Header Special Styling */
        .course-header-card {
            background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
            color: white;
        }
        .course-header-card h1 { margin: 0 0 10px 0; font-size: 2.2em; }
        .course-header-card p { color: #e9ecef; font-size: 1.1em; margin: 0 0 15px 0; }
        .badge-status {
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: bold;
            backdrop-filter: blur(4px);
        }

        /* Buttons */
        .btn {
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            color: white;
            border: none;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9em;
            transition: all 0.2s ease;
        }
        .btn-primary { background-color: #0d6efd; }
        .btn-primary:hover { background-color: #0b5ed7; transform: translateY(-1px); box-shadow: 0 4px 8px rgba(13, 110, 253, 0.2); }
        .btn-danger { background-color: #dc3545; }
        .btn-danger:hover { background-color: #c82333; }
        .btn-secondary { background-color: #6c757d; }
        .btn-secondary:hover { background-color: #5a6268; }

        /* Inputs & Forms */
        .form-control {
            padding: 10px 12px;
            border: 1px solid #ced4da;
            border-radius: 6px;
            font-family: inherit;
            font-size: 0.95em;
            width: 100%;
            box-sizing: border-box;
            transition: border-color 0.2s;
        }
        .form-control:focus { border-color: #86b7fe; outline: 0; box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1); }

        /* File & Content Boxes */
        .file-box {
            background: #f8f9fa;
            padding: 15px 20px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: background 0.2s;
        }
        .file-box:hover { background: #f1f3f5; }

        .content-item {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 20px;
            background: #fff;
            margin-bottom: 15px;
            transition: box-shadow 0.2s, border-color 0.2s;
        }
        .content-item:hover { box-shadow: 0 4px 10px rgba(0,0,0,0.04); border-color: #dee2e6; }

        /* Color Coded Left Borders to distinguish content types */
        .announcement-item { border-left: 4px solid #17a2b8; }
        .discussion-item { border-left: 4px solid #6f42c1; }

        /* Admin/Instructor Toolbars */
        .admin-controls {
            margin-top: 20px;
            padding: 15px 20px;
            background: #fff8e1; /* Soft warning/attention color */
            border-left: 4px solid #ffc107;
            border-radius: 6px;
        }
        .admin-controls h4 { margin: 0 0 10px 0; color: #856404; }

        /* Empty States */
        .empty-state {
            color: #6c757d;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            border: 1px dashed #ced4da;
        }
    </style>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/site" class="back-link">&larr; Back to Dashboard</a>

    <div class="section-card course-header-card">
        <h1>${course.title}</h1>
        <p>${course.description}</p>
        <span class="badge-status">
            ${course.active ? '🟢 Active Course' : '⚪ Draft Mode'}
        </span>
    </div>

    <div class="section-card">
        <div class="section-header">
            <h2>Subject Outline</h2>
        </div>

        <c:choose>
            <c:when test="${not empty course.outlineFilename}">
                <div class="file-box">
                    <span>📄 <strong style="color: #2c3e50;">${course.outlineFilename}</strong></span>
                    <a href="${pageContext.request.contextPath}/download-syllabus?courseId=${course.courseId}" class="btn btn-primary">Download Outline</a>
                </div>

                <% if (isInstructor) { %>
                <div class="admin-controls">
                    <h4>Instructor Tools: Manage Outline</h4>
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <form action="${pageContext.request.contextPath}/course-details" method="post" enctype="multipart/form-data" style="margin: 0; display: flex; gap: 10px;">
                            <input type="hidden" name="courseId" value="${course.courseId}">
                            <input type="hidden" name="action" value="replace">
                            <input type="file" name="newSyllabus" required class="form-control" style="width: auto;">
                            <button type="submit" class="btn btn-primary">Replace</button>
                        </form>

                        <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0;">
                            <input type="hidden" name="courseId" value="${course.courseId}">
                            <input type="hidden" name="action" value="delete">
                            <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete the outline?');">Delete</button>
                        </form>
                    </div>
                </div>
                <% } %>
            </c:when>
            <c:otherwise>
                <div class="empty-state">No subject outline has been uploaded yet.</div>
                <% if (isInstructor) { %>
                <form action="${pageContext.request.contextPath}/course-details" method="post" enctype="multipart/form-data" class="admin-controls">
                    <input type="hidden" name="courseId" value="${course.courseId}">
                    <input type="hidden" name="action" value="replace">
                    <div style="display: flex; gap: 10px;">
                        <input type="file" name="newSyllabus" required class="form-control">
                        <button type="submit" class="btn btn-primary">Upload</button>
                    </div>
                </form>
                <% } %>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section-card">
        <div class="section-header">
            <h2>Course Materials</h2>
        </div>

        <% if (isInstructor) { %>
        <div class="admin-controls">
            <h4>Upload New Course Material</h4>
            <form action="${pageContext.request.contextPath}/course-details" method="post" enctype="multipart/form-data" style="margin: 0; display: flex; gap: 10px; align-items: center;">
                <input type="hidden" name="courseId" value="${course.courseId}">
                <input type="hidden" name="action" value="upload_material">

                <input type="text" name="materialTitle" placeholder="Title (e.g. Week 1 Slides)" required class="form-control" style="flex-grow: 1;">
                <input type="file" name="materialFile" required class="form-control" style="width: auto;">
                <button type="submit" class="btn btn-primary">Upload</button>
            </form>
        </div>
        <br>
        <% } %>

        <c:choose>
            <c:when test="${empty materials}">
                <div class="empty-state">No course materials have been uploaded yet.</div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 10px;">
                    <c:forEach var="material" items="${materials}">
                        <div class="file-box">
                            <div>
                                <strong style="color: #2c3e50; display: block; margin-bottom: 5px; font-size: 1.1em;">${material.title}</strong>
                                <span style="font-size: 0.85em; color: #6c757d;">📄 ${material.file_name}</span>
                            </div>
                            <div style="display: flex; gap: 10px; align-items: center;">
                                <a href="${pageContext.request.contextPath}/download-file?type=material&id=${material.material_id}" class="btn btn-primary">Download</a>

                                <% if (isInstructor) { %>
                                <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0;">
                                    <input type="hidden" name="courseId" value="${course.courseId}">
                                    <input type="hidden" name="materialId" value="${material.material_id}">
                                    <input type="hidden" name="action" value="delete_material">
                                    <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this material?');">Delete</button>
                                </form>
                                <% } %>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section-card" style="background: #f8f9fa; border: 1px solid #ced4da;">
        <div class="section-header" style="border-bottom: none; padding-bottom: 0; margin-bottom: 10px;">
            <h2 style="color: #212529;">Assignments & Submissions</h2>
            <a href="${pageContext.request.contextPath}/assignments?courseId=${course.courseId}" class="btn btn-primary">Enter Assignments Portal &rarr;</a>
        </div>
        <% if (isStudent) { %>
        <p style="color: #6c757d; margin: 0;">Check upcoming deadlines, download resource files, and upload your coursework submissions here.</p>
        <% } else if (isInstructor) { %>
        <p style="color: #6c757d; margin: 0;">Create new assignments, upload instructions, and review student submissions here.</p>
        <% } %>
    </div>

    <div class="section-card">
        <div class="section-header">
            <h2>Announcements</h2>
        </div>

        <% if (isInstructor) { %>
        <div class="admin-controls">
            <h4>Post New Announcement</h4>
            <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0; display: flex; flex-direction: column; gap: 10px;">
                <input type="hidden" name="courseId" value="${course.courseId}">
                <input type="hidden" name="action" value="post_announcement">

                <input type="text" name="title" placeholder="Announcement Title" required class="form-control">
                <textarea name="content" rows="3" placeholder="Type your announcement here..." required class="form-control" style="resize: vertical;"></textarea>
                <button type="submit" class="btn btn-primary" style="align-self: flex-start;">Post Announcement</button>
            </form>
        </div>
        <br>
        <% } %>

        <c:choose>
            <c:when test="${empty announcements}">
                <div class="empty-state">No announcements have been posted yet.</div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column;">
                    <c:forEach var="announcement" items="${announcements}">
                        <div class="content-item announcement-item">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 12px;">
                                <h3 style="margin: 0; color: #0d6efd; font-size: 1.2em;">${announcement.title}</h3>
                                <small style="color: #888; font-weight: 500;">📅 ${announcement.postedAt}</small>
                            </div>
                            <p style="margin: 0; color: #495057; line-height: 1.6; white-space: pre-wrap;">${announcement.content}</p>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section-card">
        <div class="section-header">
            <h2>Discussion Forum</h2>
        </div>
        <p style="color: #6c757d; margin-top: 0;">Ask questions, share resources, and collaborate with your peers.</p>

        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 25px; border: 1px solid #e9ecef;">
            <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0; display: flex; flex-direction: column; gap: 10px;">
                <input type="hidden" name="courseId" value="${course.courseId}">
                <input type="hidden" name="action" value="post_discussion">

                <textarea name="content" rows="3" placeholder="Start a new discussion topic..." required class="form-control" style="resize: vertical;"></textarea>
                <button type="submit" class="btn btn-primary" style="align-self: flex-end;">Start Discussion</button>
            </form>
        </div>

        <c:choose>
            <c:when test="${empty discussions}">
                <div class="empty-state">No discussions yet. Be the first to start a conversation!</div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column;">
                    <c:forEach var="post" items="${discussions}">
                        <div class="content-item discussion-item">

                            <div style="display: flex; justify-content: space-between; margin-bottom: 15px; border-bottom: 1px solid #f0f2f5; padding-bottom: 10px;">
                                <small style="color: #6c757d; font-size: 0.9em;">
                                    Started by
                                    <strong style="color: ${post.author.role == 'teacher' ? '#dc3545' : '#20c997'};">
                                            ${post.author.fullname} ${post.author.role == 'teacher' ? '(Instructor)' : ''}
                                    </strong>
                                    on ${post.created_at}
                                </small>

                                <% if (isInstructor) { %>
                                <form action="${pageContext.request.contextPath}/course-details" method="post" style="margin: 0;">
                                    <input type="hidden" name="courseId" value="${course.courseId}">
                                    <input type="hidden" name="postId" value="${post.post_id}">
                                    <input type="hidden" name="action" value="delete_discussion">
                                    <button type="submit" class="btn btn-danger" style="padding: 4px 10px; font-size: 0.8em;" onclick="return confirm('Delete this post and all its replies?');">Delete Thread</button>
                                </form>
                                <% } %>
                            </div>

                            <a href="${pageContext.request.contextPath}/discussion-details?topicId=${post.post_id}" style="text-decoration: none; display: block;">
                                <h3 style="margin: 0; color: #2c3e50; transition: color 0.2s;">
                                    💬 ${post.content}
                                </h3>
                                <p style="color: #0d6efd; font-size: 0.9em; margin: 10px 0 0 0; font-weight: 600;">View full thread &rarr;</p>
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