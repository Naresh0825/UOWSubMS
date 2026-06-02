<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<!DOCTYPE html>
<html>
<head>
    <title>Take Quiz: ${assignment.title}</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; background-color: #f4f7f6; padding: 40px 20px; color: #333; }
        .container { max-width: 800px; margin: 0 auto; }

        .header-card { background: linear-gradient(135deg, #6f42c1 0%, #46198f 100%); color: white; padding: 25px 30px; border-radius: 12px; margin-bottom: 25px; }
        .header-card h2 { margin: 0 0 10px 0; }

        .question-card { background: #fff; padding: 25px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); border-left: 4px solid #0d6efd; }
        .question-text { font-size: 1.1em; font-weight: 600; margin-bottom: 15px; color: #2c3e50; }

        .choice-label { display: block; padding: 10px 15px; background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 6px; margin-bottom: 8px; cursor: pointer; transition: background 0.2s; }
        .choice-label:hover { background: #e9ecef; }

        .form-control { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 6px; font-size: 1em; box-sizing: border-box; }

        .btn-success { background: #198754; color: white; padding: 12px 25px; border: none; border-radius: 6px; font-size: 1.1em; cursor: pointer; font-weight: bold; width: 100%; }
        .btn-success:hover { background: #157347; }
    </style>
</head>
<body>

<div class="container">
    <div class="header-card">
        <h2>${assignment.title}</h2>
        <p style="margin:0; opacity: 0.9;">${assignment.description}</p>
        <span style="background: rgba(255,255,255,0.2); padding: 5px 12px; border-radius: 20px; display: inline-block; margin-top: 15px; font-size: 0.85em;">
            ⏳ Due: ${assignment.deadline}
        </span>
    </div>

    <form action="${pageContext.request.contextPath}/quiz" method="post">
        <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
        <input type="hidden" name="courseId" value="${assignment.course.courseId}">

        <c:forEach var="q" items="${assignment.questions}" varStatus="status">
            <div class="question-card">
                <div class="question-text">
                        ${status.index + 1}. ${q.questionText}
                    <span style="color: #6c757d; font-size: 0.8em; font-weight: normal; float: right;">(${q.points} pts)</span>
                </div>

                <c:choose>
                    <c:when test="${q.questionType == 'MCQ'}">
                        <c:forEach var="choice" items="${fn:split(q.choices, ',')}">
                            <label class="choice-label">
                                <input type="radio" name="question_${q.question_id}" value="${fn:trim(choice)}" required>
                                    ${fn:trim(choice)}
                            </label>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <input type="text" name="question_${q.question_id}" class="form-control" placeholder="Type your answer here..." required>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>

        <button type="submit" class="btn-success">Submit & Auto-Grade</button>
    </form>
</div>

</body>
</html>