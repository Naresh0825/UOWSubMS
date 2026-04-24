<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Course Enrollments | ISIT950</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f5f7; }
        .header { border-bottom: 2px solid #ccc; padding-bottom: 10px; margin-bottom: 20px; }

        /* ListTile Design Implementation */
        .list-view { max-width: 800px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
        .list-tile { display: flex; align-items: center; padding: 16px 20px; border-bottom: 1px solid #eee; transition: background-color 0.2s; }
        .list-tile:last-child { border-bottom: none; }
        .list-tile:hover { background-color: #fafafa; }

        .list-tile-leading { font-size: 1.2rem; font-weight: bold; color: #0d6efd; width: 60px; flex-shrink: 0; }
        .list-tile-content { flex-grow: 1; padding-right: 20px; }
        .list-tile-title { margin: 0 0 5px 0; font-size: 1.1rem; color: #333; }
        .list-tile-subtitle { margin: 0; font-size: 0.9rem; color: #666; line-height: 1.4; }

        /* Trailing Action Buttons */
        .btn { padding: 8px 16px; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-enroll { background-color: #198754; color: white; }
        .btn-enroll:hover { background-color: #157347; }
        .btn-unenroll { background-color: #dc3545; color: white; }
        .btn-unenroll:hover { background-color: #bb2d3b; }

        .btn-back { display: inline-block; margin-top: 20px; color: #0d6efd; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>

<div style="max-width: 800px; margin: 0 auto;">
    <div class="header">
        <h1>Course Enrollments</h1>
        <p>Manage your active subjects below.</p>
    </div>

    <c:if test="${not empty errorMessage}">
        <p style="color: red; font-weight: bold;">${errorMessage}</p>
    </c:if>

    <div class="list-view">
        <c:choose>
            <c:when test="${empty courses}">
                <div style="padding: 20px; text-align: center; color: #777;">
                    No active courses are currently available.
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="course" items="${courses}">

                    <div class="list-tile">
                        <div class="list-tile-leading">
                            #${course.courseId}
                        </div>

                        <div class="list-tile-content">
                            <h3 class="list-tile-title">${course.title}</h3>
                            <p class="list-tile-subtitle">${course.description}</p>
                        </div>

                        <div class="list-tile-trailing">
                            <form action="${pageContext.request.contextPath}/enroll" method="post" style="margin: 0;">
                                <input type="hidden" name="courseId" value="${course.courseId}">

                                <c:choose>
                                    <c:when test="${enrollmentMap[course.courseId] != null}">
                                        <input type="hidden" name="action" value="unenroll">
                                        <button type="submit" class="btn btn-unenroll">Unenroll</button>
                                    </c:when>
                                    <c:otherwise>
                                        <input type="hidden" name="action" value="enroll">
                                        <button type="submit" class="btn btn-enroll">Enroll</button>
                                    </c:otherwise>
                                </c:choose>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>

    <a href="${pageContext.request.contextPath}/site" class="btn-back">&larr; Back to Dashboard</a>
</div>

</body>
</html>