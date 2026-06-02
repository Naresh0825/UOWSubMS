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
    <title>Manage Assignments | ISIT950</title>
    <style>
        /* Modern Font Stack & Base Colors */
        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 40px 20px;
            background-color: #f4f7f6;
            color: #333;
        }

        .container { max-width: 900px; margin: 0 auto; }

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
            margin-bottom: 25px;
        }

        .header-card {
            background: linear-gradient(135deg, #20c997 0%, #198754 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 12px;
            margin-bottom: 25px;
        }
        .header-card h2 { margin: 0; font-size: 2em; }

        /* Buttons */
        .btn { padding: 8px 16px; border-radius: 6px; text-decoration: none; color: white; border: none; cursor: pointer; font-weight: 600; font-size: 0.9em; transition: all 0.2s ease; }
        .btn-primary { background-color: #0d6efd; }
        .btn-primary:hover { background-color: #0b5ed7; box-shadow: 0 4px 8px rgba(13, 110, 253, 0.2); }
        .btn-success { background-color: #198754; }
        .btn-success:hover { background-color: #157347; box-shadow: 0 4px 8px rgba(25, 135, 84, 0.2); }
        .btn-secondary { background-color: #6c757d; border: 1px solid #ced4da; }
        .btn-secondary:hover { background-color: #5a6268; }
        .btn-purple { background-color: #6f42c1; color: white; }
        .btn-purple:hover { background-color: #59339d; box-shadow: 0 4px 8px rgba(111, 66, 193, 0.2); }

        /* Forms */
        .form-control { width: 100%; padding: 10px 12px; margin-bottom: 15px; border: 1px solid #ced4da; border-radius: 6px; font-family: inherit; font-size: 0.95em; box-sizing: border-box; transition: border-color 0.2s;}
        .form-control:focus { border-color: #86b7fe; outline: 0; box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1); }
        label { font-weight: 600; color: #495057; display: block; margin-bottom: 5px; }

        /* Alerts/Dialogs */
        .alert { padding: 15px 20px; border-radius: 8px; margin-bottom: 25px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
        .alert-error { background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
        .alert-success { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
    </style>

    <script>
        // Toggle the resource file upload in the main assignment creator
        function toggleAssignmentType() {
            var type = document.getElementById("assignmentType").value;
            var resourceDiv = document.getElementById("resourceFileDiv");
            if (type === "true") {
                resourceDiv.style.display = "none";
            } else {
                resourceDiv.style.display = "block";
            }
        }

        // Toggle the choices input in the Quiz Builder based on question type
        function toggleQuestionType(selectElement, assignmentId) {
            var choicesDiv = document.getElementById('choicesDiv_' + assignmentId);
            if (selectElement.value === 'MCQ') {
                choicesDiv.style.display = 'block';
            } else {
                choicesDiv.style.display = 'none';
            }
        }
    </script>
</head>
<body>

<div class="container">
    <a href="${pageContext.request.contextPath}/course-details?id=${courseId}" class="back-link">&larr; Back to Course</a>

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

    <div class="header-card">
        <h2>Course Assignments</h2>
    </div>

    <% if (isInstructor) { %>
    <div class="card" style="border-left: 5px solid #0d6efd; background-color: #f8f9fa;">
        <h3 style="margin-top: 0; color: #2c3e50;">Create New Assignment</h3>
        <form action="${pageContext.request.contextPath}/assignments" method="post" enctype="multipart/form-data" style="margin: 0;">
            <input type="hidden" name="courseId" value="${courseId}">
            <input type="hidden" name="action" value="create_assignment">

            <label>Assignment Type:</label>
            <select name="isQuiz" id="assignmentType" class="form-control" onchange="toggleAssignmentType()" required>
                <option value="false">Standard (Student uploads a file)</option>
                <option value="true">Interactive Quiz (Auto-Marked)</option>
            </select>

            <label>Title:</label>
            <input type="text" name="title" class="form-control" required placeholder="e.g., Week 1 Quiz">

            <label>Instructions/Description:</label>
            <textarea name="description" class="form-control" rows="3" required placeholder="Detail the requirements..."></textarea>

            <label>Deadline:</label>
            <input type="datetime-local" name="deadline" class="form-control" required style="width: auto;">

            <div id="resourceFileDiv">
                <label>Attach Resource File (Optional):</label>
                <input type="file" name="resourceFile" class="form-control" style="width: auto;">
            </div>

            <button type="submit" class="btn btn-primary" style="margin-top: 10px;">Publish Assignment</button>
        </form>
    </div>
    <% } %>

    <c:choose>
        <c:when test="${empty assignments}">
            <div class="card" style="text-align: center; color: #6c757d; padding: 40px;">
                No assignments have been published for this course yet.
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="assignment" items="${assignments}">
                <div class="card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px;">
                        <h3 style="margin: 0; color: #0d6efd; font-size: 1.4em;">
                                ${assignment.quiz ? '⚡ ' : ''}${assignment.title}
                        </h3>
                        <span style="background: #fff3cd; color: #856404; padding: 5px 12px; border-radius: 20px; font-size: 0.85em; font-weight: bold; border: 1px solid #ffeeba;">
                            ⏳ Due: ${assignment.deadline}
                        </span>
                    </div>

                    <p style="white-space: pre-wrap; color: #495057; line-height: 1.6;">${assignment.description}</p>

                    <c:if test="${not empty assignment.resourceFilename}">
                        <div style="background: #f8f9fa; padding: 15px; border-radius: 6px; margin-top: 15px; border: 1px solid #dee2e6; display: flex; justify-content: space-between; align-items: center;">
                            <span style="color: #495057;">📄 <strong>Attached Resource:</strong> ${assignment.resourceFilename}</span>
                            <a href="${pageContext.request.contextPath}/download-file?type=assignment&id=${assignment.assignmentId}" class="btn btn-secondary" style="padding: 6px 12px;">Download</a>
                        </div>
                    </c:if>

                    <% if (isStudent) { %>
                    <hr style="border-top: 1px solid #eef0f2; margin: 25px 0;">

                    <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; border: 1px dashed #ced4da;">
                        <c:choose>
                            <c:when test="${assignment.quiz}">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <h4 style="margin: 0 0 5px 0; color: #6f42c1;">⚡ Interactive Quiz</h4>
                                        <p style="margin: 0; color: #6c757d; font-size: 0.9em;">This assignment is auto-marked. Click below to begin.</p>
                                    </div>
                                    <div style="display: flex; gap: 15px;">
                                        <a href="${pageContext.request.contextPath}/quiz?assignmentId=${assignment.assignmentId}" class="btn btn-purple">Take Quiz Now</a>
                                        <a href="${pageContext.request.contextPath}/submissions?assignmentId=${assignment.assignmentId}" class="btn btn-secondary">View Grade &rarr;</a>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/assignments" method="post" enctype="multipart/form-data" style="margin: 0; display: flex; flex-direction: column; gap: 10px;">
                                    <input type="hidden" name="courseId" value="${courseId}">
                                    <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
                                    <input type="hidden" name="action" value="submit_work">

                                    <label style="color: #198754; font-size: 1.1em;">📤 Upload your work (or Resubmit):</label>
                                    <input type="file" name="submissionFile" required class="form-control" style="margin-bottom: 5px; width: 100%; max-width: 400px;">

                                    <div style="display: flex; gap: 15px; margin-top: 10px;">
                                        <button type="submit" class="btn btn-success">Submit Assignment</button>
                                        <a href="${pageContext.request.contextPath}/submissions?assignmentId=${assignment.assignmentId}" class="btn btn-secondary">View My Submission & Grade &rarr;</a>
                                    </div>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <% } %>

                    <% if (isInstructor) { %>
                    <hr style="border-top: 1px solid #eef0f2; margin: 20px 0;">

                    <c:if test="${not empty assignment.questions}">
                        <div style="background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 15px; margin-bottom: 20px;">
                            <h4 style="margin-top: 0; color: #495057; border-bottom: 2px solid #eef0f2; padding-bottom: 10px;">
                                📝 Saved Quiz Questions
                            </h4>
                            <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 15px;">
                                <c:forEach var="q" items="${assignment.questions}" varStatus="status">
                                    <div style="background: white; padding: 12px; border-radius: 6px; border: 1px solid #e9ecef;">
                                        <div style="font-weight: 600; color: #2c3e50;">
                                                ${status.index + 1}. ${q.questionText}
                                            <span style="color: #6c757d; font-size: 0.85em; font-weight: normal;">(${q.points} pts | ${q.questionType})</span>
                                        </div>
                                        <div style="color: #198754; font-size: 0.95em; margin-top: 5px;">
                                            ✓ <strong>Answer:</strong> ${q.correctAnswer}
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <a href="${pageContext.request.contextPath}/submissions?assignmentId=${assignment.assignmentId}" class="btn btn-primary">Grade Submissions &rarr;</a>

                        <c:if test="${assignment.quiz}">
                            <button type="button" class="btn btn-purple" onclick="document.getElementById('addQuiz_${assignment.assignmentId}').style.display='block'">+ Add Quiz Question</button>
                        </c:if>
                    </div>

                    <div id="addQuiz_${assignment.assignmentId}" style="display: none; background: #e9ecef; padding: 20px; border-radius: 8px; margin-top: 15px; border-left: 4px solid #6f42c1;">
                        <h4 style="margin-top: 0; color: #6f42c1;">Add Auto-Marked Question</h4>
                        <form action="${pageContext.request.contextPath}/assignments" method="post" style="margin: 0;">
                            <input type="hidden" name="courseId" value="${courseId}">
                            <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
                            <input type="hidden" name="action" value="add_quiz_question">

                            <label>Question Type:</label>
                            <select name="questionType" class="form-control" onchange="toggleQuestionType(this, ${assignment.assignmentId})" required>
                                <option value="MCQ">Multiple Choice</option>
                                <option value="FITB">Fill in the Blanks (Case Insensitive)</option>
                                <option value="EXACT">Unique Answer (Exact Match)</option>
                            </select>

                            <label>Question Text:</label>
                            <input type="text" name="questionText" class="form-control" required placeholder="e.g. What is the capital of Australia?">

                            <div id="choicesDiv_${assignment.assignmentId}">
                                <label>Choices (For MCQ only, separate with commas):</label>
                                <input type="text" name="choices" class="form-control" placeholder="e.g. Sydney, Melbourne, Canberra, Perth">
                            </div>

                            <label>Correct Answer:</label>
                            <input type="text" name="correctAnswer" class="form-control" required placeholder="e.g. Canberra">

                            <label>Points:</label>
                            <input type="number" name="points" class="form-control" value="1" min="1" required style="width: 100px;">

                            <button type="submit" class="btn btn-success" style="margin-top: 10px;">Save Question</button>
                            <button type="button" class="btn btn-secondary" onclick="document.getElementById('addQuiz_${assignment.assignmentId}').style.display='none'" style="margin-top: 10px; margin-left: 10px;">Cancel</button>
                        </form>
                    </div>
                    <% } %>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>

</div>

</body>
</html>