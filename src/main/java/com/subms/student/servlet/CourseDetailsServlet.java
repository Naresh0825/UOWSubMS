package com.subms.student.servlet;

import com.subms.student.model.*;
import com.subms.student.service.InstructorService;
import com.subms.student.service.StudentService;
import jakarta.ejb.EJB;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

@WebServlet("/course-details")
@MultipartConfig(maxFileSize = 1024 * 1024 * 100) // 100MB
public class CourseDetailsServlet extends HttpServlet {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;

    @EJB
    private InstructorService instructorService;
    @EJB
    private StudentService studentService;

    // Load the page
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int courseId = Integer.parseInt(request.getParameter("id"));
        Course course = em.find(Course.class, courseId);

//         You would also fetch Materials here later:
         List<Material> materials = studentService.getCourseMaterials(courseId);
         request.setAttribute("materials", materials);
        List<Announcement> announcements = studentService.getCourseAnnouncements(courseId);
        request.setAttribute("announcements", announcements);

        request.setAttribute("course", course);
        request.getRequestDispatcher("/site/courseDetails.jsp").forward(request, response);
    }

    // Handle outline updates (Teacher Only)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!request.isUserInRole("teacher")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int courseId = Integer.parseInt(request.getParameter("courseId"));
        String action = request.getParameter("action");

        if ("post_announcement".equals(action)) {
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            instructorService.postAnnouncement(courseId, title, content);
        }

        if ("delete".equals(action)) {
            instructorService.deleteCourseOutline(courseId);
        } else if ("replace".equals(action)) {
            Part filePart = request.getPart("newSyllabus");
            if (filePart != null && filePart.getSize() > 0) {
                byte[] fileData;
                try (InputStream is = filePart.getInputStream()) {
                    fileData = is.readAllBytes();
                }
                instructorService.updateCourseOutline(courseId, fileData, filePart.getSubmittedFileName());
            }
        }

        // Refresh the page
        response.sendRedirect(request.getContextPath() + "/course-details?id=" + courseId);
    }
}