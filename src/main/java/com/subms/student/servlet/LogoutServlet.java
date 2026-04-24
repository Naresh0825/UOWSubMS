package com.subms.student.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Destroy the local container authentication
        try {
            request.logout();
        } catch (ServletException e) {
            // It's safe to ignore this. It just means the user was likely already logged out.
        }

        // 2. Invalidate the local HTTP session and clear any custom attributes
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // 3. Redirect the user to Kinde to destroy the SSO session
        String kindeLogoutUrl = "https://uowtech.kinde.com/logout";
        response.sendRedirect(kindeLogoutUrl);
    }
}
