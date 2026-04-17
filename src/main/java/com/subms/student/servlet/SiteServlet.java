package com.subms.student.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.Principal;

@WebServlet("/site")
public class SiteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Check for OIDC Principal
        Principal principal = request.getUserPrincipal();

        // 2. Handle Unauthenticated Users
        if (principal == null) {
            // Option A: Send a 401 error
            // response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Please log in.");

            // Option B: Redirect them to your OIDC login page (Replace with your actual login URL)
            response.sendRedirect(request.getContextPath() + "/login");
            return; // Stop execution so we don't forward to the JSP
        }

        // 3. Role-based logic for authenticated users
        request.setAttribute("username", principal.getName());
        boolean isInstructor = request.isUserInRole("teacher");
        request.setAttribute("userRole", isInstructor ? "Teacher" : "Student");

        // 4. Forward to your JSP UI
        request.getRequestDispatcher("/site/dashboard.jsp").forward(request, response);
    }
}