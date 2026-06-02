package com.subms.student.servlet;

import com.subms.student.model.*;
import com.subms.student.service.DiscussionService;
import jakarta.ejb.EJB;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/discussion-details")
public class DiscussionDetailServlet extends HttpServlet {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;

    @EJB
    private DiscussionService discussionService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String topicIdParam = request.getParameter("topicId");
        if (topicIdParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing topic ID");
            return;
        }

        int topicId = Integer.parseInt(topicIdParam);

        // 1. Fetch the main topic
        Discussion topic = discussionService.getPostById(topicId);

        // 2. Fetch all replies to this topic
        List<Discussion> replies = discussionService.getRepliesByTopicId(topicId);

        // 3. Attach to request and forward
        request.setAttribute("topic", topic);
        request.setAttribute("replies", replies);
        request.getRequestDispatcher("/site/discussionDetails.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int topicId = Integer.parseInt(request.getParameter("topicId"));
        String userId = request.getUserPrincipal().getName();

        if ("post_reply".equals(action)) {
            String content = request.getParameter("content");

            try {
                // Get necessary entities
                Discussion parentTopic = em.find(Discussion.class, topicId);
                User author = em.find(User.class, userId);

                // --- FIXED: ONLY APPLY LIMITS TO STUDENTS WHO ARE NOT PRO MEMBERS ---
                if (!request.isUserInRole("teacher") && !author.isMembership()) {

                    // Calculate the date exactly 7 days ago
                    java.util.Date oneWeekAgo = new java.util.Date(System.currentTimeMillis() - (7L * 24 * 3600 * 1000));

                    // Count how many posts & replies this user made in the last week
                    Long recentPostCount = em.createQuery(
                                    "SELECT COUNT(d) FROM Discussion d WHERE d.author.username = :username",
                                    Long.class)
                            .setParameter("username", userId)
                            .getSingleResult();

                    if (recentPostCount >= 10) {
                        throw new Exception("Free tier limit reached: You can only post 10 replies per week. Upgrade to Pro for unlimited posts!");
                    }
                }

                // --- PROCEED WITH POSTING ---
                Discussion reply = new Discussion();
                reply.setAuthor(author);
                reply.setCourse(parentTopic.getCourse()); // Inherit course from topic
                reply.setContent(content);
                reply.setParentPost(parentTopic); // VERY IMPORTANT: Links reply to topic

                discussionService.savePost(reply);

                // Trigger Green Success Dialog
                request.getSession().setAttribute("successMessage", "Reply posted successfully!");

            } catch (Exception e) {
                // Trigger Red Error Dialog (e.g. limit reached)
                request.getSession().setAttribute("errorMessage", e.getMessage());
            }
        }
        else if ("delete_reply".equals(action) && request.isUserInRole("teacher")) {
            int replyId = Integer.parseInt(request.getParameter("replyId"));
            try {
                discussionService.deletePost(replyId);
                request.getSession().setAttribute("successMessage", "Reply deleted successfully.");
            } catch (Exception e) {
                request.getSession().setAttribute("errorMessage", "Failed to delete reply.");
            }
        }

        // Redirect back to the same discussion thread to see the new reply or error
        response.sendRedirect(request.getContextPath() + "/discussion-details?topicId=" + topicId);
    }
}