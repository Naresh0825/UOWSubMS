package com.subms.student.service;


import com.subms.student.model.Discussion;
import java.util.List;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
@Stateless
public class DiscussionService {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;

    /**
     * Retrieves the main topic post.
     */
    public Discussion getPostById(int id) {
        return em.find(Discussion.class, id);
    }

    /**
     * Fetches all replies for a specific topic.
     * Filtered by parent_post_id and ordered by date.
     */
    public List<Discussion> getRepliesByTopicId(int topicId) {
        return em.createQuery(
                        "SELECT d FROM Discussion d WHERE d.parentPost.post_id = :topicId ORDER BY d.created_at ASC",
                        Discussion.class)
                .setParameter("topicId", topicId)
                .getResultList();
    }

    /**
     * Fetches top-level topics (where parent_post_id IS NULL)
     * This is what you would show on the Course Details page.
     */
    public List<Discussion> getTopicsByCourse(int courseId) {
        return em.createQuery(
                        "SELECT d FROM Discussion d WHERE d.course.courseId = :courseId AND d.parentPost.post_id IS NULL ORDER BY d.created_at DESC",
                        Discussion.class)
                .setParameter("courseId", courseId)
                .getResultList();
    }

    /**
     * Saves a new post or reply.
     */
    @Transactional
    public void savePost(Discussion post) {

            em.persist(post);

    }

    public void deletePost(int postId) {
        Discussion post = em.find(Discussion.class, postId);
        if (post != null) {
            em.remove(post);
        }
    }
}
