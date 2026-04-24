<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Create Course - Platform</title>
</head>
<body>
<h1>Configure New Course Space</h1>

<form action="createcourse" method="post" enctype="multipart/form-data">
    <div>
        <label>Course Title:</label><br>
        <input type="text" name="title" required placeholder="e.g. ISIT950">
    </div>
    <br>
    <div>
        <label>Description:</label><br>
        <textarea name="description" rows="4" cols="50"></textarea>
    </div>
    <br>
    <div>
        <label>Upload Course Outline (Max 100MB):</label><br>
        <input type="file" name="syllabus" accept=".pdf,.doc,.docx">
    </div>
    <br>
    <button type="submit">Create Course</button>
</form>

<hr>
<a href="site">Cancel and Return</a>
</body>
</html>