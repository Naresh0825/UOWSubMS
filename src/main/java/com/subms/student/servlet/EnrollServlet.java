package com.subms.student.servlet;



import com.subms.student.model.Course;
import com.subms.student.service.StudentService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/enroll")
public class EnrollServlet extends HttpServlet {

    @EJB
    private StudentService studentService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Principal principal = request.getUserPrincipal();
        if (principal == null || !request.isUserInRole("student")) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String studentId = principal.getName();

        // 1. Get all active courses
        List<Course> activeCourses = studentService.getAllActiveCourses();

        // 2. Get the IDs of courses the student is enrolled in
        List<Integer> enrolledIds = studentService.getEnrolledCourseIds(studentId);

        // 3. Convert list to a Map for easy O(1) lookup in the JSP
        Map<Integer, Boolean> enrollmentMap = new HashMap<>();
        for (Integer id : enrolledIds) {
            enrollmentMap.put(id, true);
        }

        request.setAttribute("courses", activeCourses);
        request.setAttribute("enrollmentMap", enrollmentMap);
        request.getRequestDispatcher("/site/enroll.jsp").forward(request, response);}

    /**
     * Handles the POST request when a student clicks "Enroll" on a specific course card.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getUserPrincipal().getName();
        int courseId = Integer.parseInt(request.getParameter("courseId"));
        String action = request.getParameter("action"); // Distinguish between enroll and unenroll

        try {
            if ("unenroll".equals(action)) {
                studentService.unenrollFromCourse(studentId, courseId);
            } else {
                studentService.enrollInCourse(studentId, courseId);
            }
            // Redirect back to the same page to see the updated button state
            response.sendRedirect(request.getContextPath() + "/enroll");
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            doGet(request, response);
        }
    }

}