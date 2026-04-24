package com.subms.student.servlet;


import com.subms.student.model.Course;
import com.subms.student.service.InstructorService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.security.Principal;
import java.util.List;

@WebServlet("/createcourse")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 100,      // 100MB limit per your requirement
        maxRequestSize = 1024 * 1024 * 110    // 110MB total request size
)
public class CreateCourseServlet extends HttpServlet {

    @EJB
    private InstructorService instructorService;

    /**
     * Use Case: Navigate to Course Setup
     * Redirects the instructor to the creation form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Ensure user is authenticated via Kinde before showing the page

        request.getRequestDispatcher("/site/createcourse.jsp").forward(request, response);
    }

    /**
     * Use Case: Course Setup
     * Processes course creation, including metadata and syllabus upload.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Retrieve the instructor's ID from the session (populated from Kinde OIDC)
        Principal principal = request.getUserPrincipal();
        String instructorId = principal.getName();

        // 2. Extract form parameters
        String title = request.getParameter("title");
        String description = request.getParameter("description");

        // 3. Handle File Upload (Course Syllabus/Outline)
        Part filePart = request.getPart("syllabus");
        byte[] syllabusData = null;
        String fileName = null;

        if (filePart != null && filePart.getSize() > 0) {
            fileName = filePart.getSubmittedFileName();
            try (InputStream is = filePart.getInputStream()) {
                syllabusData = is.readAllBytes(); // Read into byte array for BLOB
            }
        }

        // 4. Call Service to persist data
        try {
            instructorService.createCourse(title, description, instructorId, syllabusData, fileName);
            // Redirect to dashboard on success
            response.sendRedirect(request.getContextPath() + "/site");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Failed to create course: " + e.getMessage());
            request.getRequestDispatcher("/site/createcourse.jsp").forward(request, response);
        }
    }
}