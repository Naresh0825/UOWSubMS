package com.subms.student.service;
import com.subms.student.model.*;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.Date;
import java.util.List;

@Stateless
public class InstructorService {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;

    /**
     * Use Case: Course Setup
     * Creates a course space and uploads the syllabus[cite: 29, 32].
     */
    public void createCourse(String title, String description, String instructorId, byte[] syllabus, String fileName) {
        User instructor = em.find(User.class, instructorId);
        if (instructor != null) {
            Course course = new Course();
            course.setTitle(title);
            course.setDescription(description);
            course.setInstructor(instructor);
            course.setOutlineContent(syllabus); // Stores syllabus as LONGBLOB [cite: 33]
            course.setOutlineFilename(fileName);
            em.persist(course);
        }
    }


    public List<Course> getInstructorCourses(String instructorId) {
        return em.createQuery(
                        "SELECT c FROM Course c WHERE c.instructor.username = :instructorId ORDER BY c.courseId DESC",
                        Course.class)
                .setParameter("instructorId", instructorId)
                .getResultList();
    }

    /**
     * Use Case: Upload Course Materials
     */
    public void uploadMaterial(int courseId, String title, byte[] content, String fileName) {
        Course course = em.find(Course.class, courseId);
        if (course != null) {
            Material material = new Material();
            material.setCourse(course);
            material.setTitle(title);
            material.setFileContent(content); // Resource sharing [cite: 6]
            material.setFile_name(fileName);
            em.persist(material);
        }
    }

    /**
     * Use Case: Manage Assignments
     */
    public void createAssignment(int courseId, String title, String description, Date deadline) {
        Course course = em.find(Course.class, courseId);
        if (course != null) {
            Assignment assignment = new Assignment();
            assignment.setCourse(course);
            assignment.setTitle(title);
            assignment.setDescription(description); // Define requirements [cite: 36]
            assignment.setDeadline(deadline);
            em.persist(assignment);
        }
    }

    /**
     * Use Case: Moderate Discussions
     */
    public void removeDiscussionPost(int postId) {
        Discussion post = em.find(Discussion.class, postId);
        if (post != null) {
            em.remove(post); // Moderation [cite: 39]
        }
    }

    /**
     * Use Case: Monitor Student Participation
     */
    public List<Submission> getAssignmentSubmissions(int assignmentId) {
        return em.createQuery("SELECT s FROM Submission s WHERE s.assignment.assignmentId = :aId", Submission.class)
                .setParameter("aId", assignmentId)
                .getResultList(); // Monitor results [cite: 41]
    }

    /**
     * Use Case: Mark or Grade Assignments
     */
    public void gradeSubmission(int submissionId, String grade) {
        Submission submission = em.find(Submission.class, submissionId);
        if (submission != null) {
            submission.setGrade(grade);
            em.merge(submission); // Update grade [cite: 37]
        }
    }
}