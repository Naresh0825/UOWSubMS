package com.subms.student.servlet;

import com.subms.student.model.*;
import com.subms.student.service.InstructorService;
import com.subms.student.service.StudentService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/assignments")
@MultipartConfig(maxFileSize = 1024 * 1024 * 100) // 100MB limit
public class AssignmentServlet extends HttpServlet {

    @EJB
    private InstructorService instructorService;
    @EJB
    private StudentService studentService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int courseId = Integer.parseInt(request.getParameter("courseId"));
        // Assuming you have a method to get assignments by course
        List<Assignment> assignments = studentService.getAssignmentsByCourse(courseId);

        request.setAttribute("courseId", courseId);
        request.setAttribute("assignments", assignments);
        request.getRequestDispatcher("/site/assignments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String userId = request.getUserPrincipal().getName();

        try {
            if ("create_assignment".equals(action) && request.isUserInRole("teacher")) {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                String title = request.getParameter("title");
                String description = request.getParameter("description");

                // Parse HTML date input (yyyy-MM-dd'T'HH:mm)
                String deadlineStr = request.getParameter("deadline");
                java.util.Date deadline = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").parse(deadlineStr);

                // Handle Optional Resource Upload
                Part filePart = request.getPart("resourceFile");
                byte[] fileData = null;
                String fileName = null;
                if (filePart != null && filePart.getSize() > 0) {
                    fileName = filePart.getSubmittedFileName();
                    try (InputStream is = filePart.getInputStream()) { fileData = is.readAllBytes(); }
                }

                instructorService.createAssignment(courseId, title, description, deadline, fileData, fileName);
                response.sendRedirect(request.getContextPath() + "/assignments?courseId=" + courseId);
                return;
            }

            else if ("submit_work".equals(action) && request.isUserInRole("student")) {
                int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
                int courseId = Integer.parseInt(request.getParameter("courseId"));

                // Handle Student Submission Upload
                Part filePart = request.getPart("submissionFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = filePart.getSubmittedFileName();
                    byte[] fileData;
                    try (InputStream is = filePart.getInputStream()) { fileData = is.readAllBytes(); }

                    studentService.submitAssignment(assignmentId, userId, fileData, fileName);
                }
                response.sendRedirect(request.getContextPath() + "/assignments?courseId=" + courseId + "&status=submitted");
                return;
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing assignment: " + e.getMessage());
        }
    }
}