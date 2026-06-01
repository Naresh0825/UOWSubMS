package com.subms.student.servlet;

import com.subms.student.model.Assignment;
import com.subms.student.model.Course;
import com.subms.student.model.Submission;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;

// We map this single servlet to both URLs used in your JSPs
@WebServlet(urlPatterns = {"/download-syllabus", "/download-file"})
public class FileDownloadServlet extends HttpServlet {

    @PersistenceContext(unitName = "CoursePU") // Make sure this matches your persistence.xml
    private EntityManager em;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        try {
            // ---------------------------------------------------------
            // 1. Handle Syllabus Downloads (/download-syllabus)
            // ---------------------------------------------------------
            if ("/download-syllabus".equals(path)) {
                String courseIdParam = request.getParameter("courseId");
                if (courseIdParam != null) {
                    Course course = em.find(Course.class, Integer.parseInt(courseIdParam));

                    if (course != null && course.getOutlineFilename() != null) {
                        streamFile(response, course.getOutlineContent(), course.getOutlineFilename());
                        return;
                    }
                }
            }
            // ---------------------------------------------------------
            // 2. Handle Assignments & Submissions (/download-file)
            // ---------------------------------------------------------
            else if ("/download-file".equals(path)) {
                String type = request.getParameter("type");
                String idParam = request.getParameter("id");

                if (idParam != null && type != null) {
                    int id = Integer.parseInt(idParam);

                    // A. Instructor's Assignment Resource
                    if ("assignment".equals(type)) {
                        Assignment assignment = em.find(Assignment.class, id);
                        if (assignment != null && assignment.getResourceContent() != null) {
                            streamFile(response, assignment.getResourceContent(), assignment.getResourceFilename());
                            return;
                        }
                    }
                    // B. Student's Uploaded Submission
                    else if ("submission".equals(type)) {
                        Submission submission = em.find(Submission.class, id);
                        if (submission != null && submission.getFileContent() != null) {

                            // Security Check: Only the teacher or the student who owns the file can download it
                            boolean isTeacher = request.isUserInRole("teacher");
                            boolean isOwner = request.getUserPrincipal().getName().equals(submission.getStudent().getUsername());

                            if (isTeacher || isOwner) {
                                streamFile(response, submission.getFileContent(), submission.getFile_name());
                                return;
                            } else {
                                response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to view this file.");
                                return;
                            }
                        }
                    }
                }
            }

            // If we get here, the file wasn't found or parameters were missing
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "The requested file could not be found.");

        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while downloading the file.");
        }
    }

    /**
     * Helper method to send the byte array to the user's browser as a downloadable file.
     */
    private void streamFile(HttpServletResponse response, byte[] fileData, String fileName) throws IOException {
        // Force the browser to download the file rather than trying to display it
        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        // Write the bytes to the response output stream
        try (OutputStream os = response.getOutputStream()) {
            os.write(fileData);
            os.flush();
        }
    }
}