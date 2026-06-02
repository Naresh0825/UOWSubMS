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

        // 1. TEACHER: Create a brand new assignment
        if ("create_assignment".equals(action) && request.isUserInRole("teacher")) {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            try {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String deadlineStr = request.getParameter("deadline");
                java.util.Date deadline = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").parse(deadlineStr);

                // --- NEW: Grab the isQuiz boolean from the Dropdown ---
                boolean isQuiz = Boolean.parseBoolean(request.getParameter("isQuiz"));

                Part filePart = request.getPart("resourceFile");
                byte[] fileData = null;
                String fileName = null;
                if (filePart != null && filePart.getSize() > 0) {
                    fileName = filePart.getSubmittedFileName();
                    try (InputStream is = filePart.getInputStream()) { fileData = is.readAllBytes(); }
                }

                // Pass isQuiz to the service
                instructorService.createAssignment(courseId, title, description, deadline, fileData, fileName, isQuiz);
                request.getSession().setAttribute("successMessage", "Assignment published successfully!");

            } catch (Exception e) {
                request.getSession().setAttribute("errorMessage", "Failed to create assignment: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/assignments?courseId=" + courseId);
            return;
        }

        // 2. STUDENT: Submit standard file-based work
        else if ("submit_work".equals(action) && request.isUserInRole("student")) {
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            int courseId = Integer.parseInt(request.getParameter("courseId"));

            try {
                // Handle Student Submission Upload
                Part filePart = request.getPart("submissionFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = filePart.getSubmittedFileName();
                    byte[] fileData;
                    try (InputStream is = filePart.getInputStream()) { fileData = is.readAllBytes(); }

                    // This calls the Service where the Premium limits and deadlines are checked
                    studentService.submitAssignment(assignmentId, userId, fileData, fileName);

                    // Trigger the Green Success Dialog!
                    request.getSession().setAttribute("successMessage", "Your assignment was submitted successfully!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Please select a file to upload.");
                }
            } catch (Exception e) {
                // Trigger the Red Error Dialog (e.g. "Free tier limit reached" or "Deadline passed")
                request.getSession().setAttribute("errorMessage", e.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/assignments?courseId=" + courseId);
            return;
        }

        // 3. TEACHER: Add Auto-Marked Questions to a Quiz
        else if ("add_quiz_question".equals(action) && request.isUserInRole("teacher")) {
            int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            int courseId = Integer.parseInt(request.getParameter("courseId"));

            try {
                String questionType = request.getParameter("questionType");
                String questionText = request.getParameter("questionText");
                String choices = request.getParameter("choices"); // Only used for MCQ
                String correctAnswer = request.getParameter("correctAnswer");
                int points = Integer.parseInt(request.getParameter("points"));

                // Call the new service method
                instructorService.addQuizQuestion(assignmentId, questionText, questionType, choices, correctAnswer, points);

                request.getSession().setAttribute("successMessage", "Question added! This assignment is now an Auto-Marked Quiz.");
            } catch (Exception e) {
                request.getSession().setAttribute("errorMessage", "Failed to add question: " + e.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/assignments?courseId=" + courseId);
            return;
        }
    }
}