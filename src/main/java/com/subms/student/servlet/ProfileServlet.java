package com.subms.student.servlet;

import com.subms.student.model.User;
import com.subms.student.service.UserService;
import jakarta.ejb.EJB;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;

    @EJB
    private UserService userService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the currently logged-in user's username (Kinde sub ID)
        String username = request.getUserPrincipal().getName();

        // Fetch their full profile from the database
        User currentUser = em.find(User.class, username);

        request.setAttribute("user", currentUser);
        request.getRequestDispatcher("/site/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getUserPrincipal().getName();
        String skills = request.getParameter("skills");
        String collaborationMode = request.getParameter("collaborationMode");
        String availability = request.getParameter("availability");

        try {
            userService.updateStudentProfile(username, skills, collaborationMode, availability);
            request.getSession().setAttribute("successMessage", "Profile updated successfully!");
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "Failed to update profile: " + e.getMessage());
        }

        // Redirect back to the profile page to see the updates
        response.sendRedirect(request.getContextPath() + "/profile");
    }
}