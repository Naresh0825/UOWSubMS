package com.subms.student.servlet;

import com.subms.student.model.Assignment;
import com.subms.student.model.Course;
import com.subms.student.model.Material;
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

@WebServlet(urlPatterns = {"/download-syllabus", "/download-file"})
public class FileDownloadServlet extends HttpServlet {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        try {
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
            else if ("/download-file".equals(path)) {
                String type = request.getParameter("type");
                String idParam = request.getParameter("id");

                if (idParam != null && type != null) {
                    int id = Integer.parseInt(idParam);

                    if ("assignment".equals(type)) {
                        Assignment assignment = em.find(Assignment.class, id);
                        if (assignment != null && assignment.getResourceContent() != null) {
                            streamFile(response, assignment.getResourceContent(), assignment.getResourceFilename());
                            return;
                        }
                    }
                    else if ("submission".equals(type)) {
                        Submission submission = em.find(Submission.class, id);
                        if (submission != null && submission.getFileContent() != null) {
                            boolean isTeacher = request.isUserInRole("teacher");
                            boolean isOwner = request.getUserPrincipal().getName().equals(submission.getStudent().getUsername());

                            if (isTeacher || isOwner) {
                                streamFile(response, submission.getFileContent(), submission.getFile_name());
                                return;
                            } else {
                                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                                return;
                            }
                        }
                    }
                    // ADDED: Course Material Download Logic
                    else if ("material".equals(type)) {
                        Material material = em.find(Material.class, id);
                        if (material != null && material.getFileContent() != null) {
                            streamFile(response, material.getFileContent(), material.getFile_name());
                            return;
                        }
                    }
                }
            }

            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found.");

        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Download error.");
        }
    }

    private void streamFile(HttpServletResponse response, byte[] fileData, String fileName) throws IOException {
        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        try (OutputStream os = response.getOutputStream()) {
            os.write(fileData);
            os.flush();
        }
    }
}