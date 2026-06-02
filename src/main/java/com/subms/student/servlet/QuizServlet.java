package com.subms.student.servlet;

import com.subms.student.model.Assignment;
import com.subms.student.service.StudentService;
import jakarta.ejb.EJB;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;

    @EJB
    private StudentService studentService;


// Load the Quiz Page
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
        String username = request.getUserPrincipal().getName(); // Get current student

        Assignment assignment = em.find(Assignment.class, assignmentId);

        if (assignment == null || !assignment.isQuiz()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Quiz.");
            return;
        }

        // --- NEW: PREVENT VIEWING THE QUIZ IF ALREADY COMPLETED ---
        if (studentService.getStudentSubmission(assignmentId, username) != null) {
            // Trigger the red error dialog on the assignments page
            request.getSession().setAttribute("errorMessage", "Quiz locked: You have already completed this quiz.");
            response.sendRedirect(request.getContextPath() + "/assignments?courseId=" + assignment.getCourse().getCourseId());
            return;
        }

        // If they haven't submitted yet, show them the questions
        request.setAttribute("assignment", assignment);
        request.getRequestDispatcher("/site/takeQuiz.jsp").forward(request, response);
    }

    // Process the submitted answers
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
        String username = request.getUserPrincipal().getName();
        int courseId = Integer.parseInt(request.getParameter("courseId"));

        Map<Integer, String> studentAnswers = new HashMap<>();

        // Loop through all submitted form parameters
        for (String paramName : request.getParameterMap().keySet()) {
            if (paramName.startsWith("question_")) {
                // Extract the question ID from the input name (e.g., "question_5" -> 5)
                int questionId = Integer.parseInt(paramName.replace("question_", ""));
                String answer = request.getParameter(paramName);
                studentAnswers.put(questionId, answer);
            }
        }

        try {
            // Send the map of answers to your Auto-Marking Engine!
            studentService.submitQuiz(assignmentId, username, studentAnswers);
            request.getSession().setAttribute("successMessage", "Quiz submitted! It has been automatically graded.");
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/assignments?courseId=" + courseId);
    }
}