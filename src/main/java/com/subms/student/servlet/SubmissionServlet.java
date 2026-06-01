package com.subms.student.servlet;

import com.subms.student.model.Assignment;
import com.subms.student.model.Submission;
import com.subms.student.service.InstructorService;
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
import java.util.Date;
import java.util.List;

@WebServlet("/submissions")
public class SubmissionServlet extends HttpServlet {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;
    @EJB
    private InstructorService instructorService;
    @EJB
    private StudentService studentService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
        Assignment assignment = em.find(Assignment.class, assignmentId);
        request.setAttribute("assignment", assignment);

        // Determine if the deadline has passed
        boolean canGrade = new Date().after(assignment.getDeadline());
        request.setAttribute("canGrade", canGrade);

        if (request.isUserInRole("teacher")) {
            List<Submission> submissions = instructorService.getSubmissionsForAssignment(assignmentId);
            request.setAttribute("submissions", submissions);
        } else {
            String studentId = request.getUserPrincipal().getName();
            Submission mySubmission = studentService.getStudentSubmission(assignmentId, studentId);
            request.setAttribute("mySubmission", mySubmission);
        }

        request.getRequestDispatcher("/site/submissions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!request.isUserInRole("teacher")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
        int submissionId = Integer.parseInt(request.getParameter("submissionId"));
        String grade = request.getParameter("grade");

        try {
            instructorService.gradeSubmission(submissionId, grade);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            doGet(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/submissions?assignmentId=" + assignmentId);
    }
}