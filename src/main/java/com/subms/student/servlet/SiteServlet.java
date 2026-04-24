package com.subms.student.servlet;

import com.subms.student.model.Course;
import com.subms.student.service.InstructorService;
import com.subms.student.service.StudentService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.Principal;
import java.util.List;

@WebServlet("/site")
public class SiteServlet extends HttpServlet {
    @EJB
    private InstructorService instructorService;
    @EJB
    private StudentService studentService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Principal principal = request.getUserPrincipal();
        if (principal == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Please log in");
            return;
        }
        String userId = principal.getName();

        // If user is a Teacher, fetch the courses they created
        if (request.isUserInRole("teacher")) {
            List<Course> createdCourses = instructorService.getInstructorCourses(userId);
            request.setAttribute("courses", createdCourses);
        }

        // If user is a Student, fetch the courses they are enrolled in
        if (request.isUserInRole("student")) {
            // You will need a method like this in your StudentService
            List<Course> enrolledCourses = studentService.getEnrolledCourses(userId);
            request.setAttribute("enrolledCourses", enrolledCourses);
        }
        request.getRequestDispatcher("/site/dashboard.jsp").forward(request, response);
    }
}