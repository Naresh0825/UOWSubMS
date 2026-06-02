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

        // Fetch Materials
        List<Material> materials = studentService.getCourseMaterials(courseId);
        request.setAttribute("materials", materials);

        List<Announcement> announcements = studentService.getCourseAnnouncements(courseId);
        request.setAttribute("announcements", announcements);

        List<Discussion> discussions = studentService.getTopLevelDiscussions(courseId);
        request.setAttribute("discussions", discussions);

        request.setAttribute("course", course);
        request.getRequestDispatcher("/site/courseDetails.jsp").forward(request, response);
    }

    // Handle course updates (Teacher Only)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!request.isUserInRole("teacher")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int courseId = Integer.parseInt(request.getParameter("courseId"));
        String action = request.getParameter("action");
        String userId = request.getUserPrincipal().getName();

        // Student & Instructor Actions
        if ("post_discussion".equals(action)) {
            String content = request.getParameter("content");
            try {
                studentService.postDiscussionMessage(courseId, userId, content, null);
            } catch (Exception e) {
                // Save the error message in the session so it survives the redirect!
                request.getSession().setAttribute("errorMessage", e.getMessage());
            }
        }
        else if ("post_announcement".equals(action)) {
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            instructorService.postAnnouncement(courseId, title, content);
        }

        // Syllabus Actions
        else if ("delete".equals(action)) {
            instructorService.deleteCourseOutline(courseId);
        }
        else if ("replace".equals(action)) {
            Part filePart = request.getPart("newSyllabus");
            if (filePart != null && filePart.getSize() > 0) {
                byte[] fileData;
                try (InputStream is = filePart.getInputStream()) {
                    fileData = is.readAllBytes();
                }
                instructorService.updateCourseOutline(courseId, fileData, filePart.getSubmittedFileName());
            }
        }

        // --- NEW: Course Materials Actions ---
        else if ("upload_material".equals(action)) {
            String materialTitle = request.getParameter("materialTitle");
            Part filePart = request.getPart("materialFile");

            if (filePart != null && filePart.getSize() > 0) {
                byte[] fileData;
                try (InputStream is = filePart.getInputStream()) {
                    fileData = is.readAllBytes();
                }
                String fileName = filePart.getSubmittedFileName();
                instructorService.uploadCourseMaterial(courseId, materialTitle, fileData, fileName);
            }
        }
        else if ("delete_material".equals(action)) {
            int materialId = Integer.parseInt(request.getParameter("materialId"));
            instructorService.deleteCourseMaterial(materialId);
        }

        // Refresh the page
        response.sendRedirect(request.getContextPath() + "/course-details?id=" + courseId);
    }
}