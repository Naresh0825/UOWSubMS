package com.subms.student.service;


import com.subms.student.model.*;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.Date;
import java.util.List;

@Stateless
public class StudentService {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;
    /**
     * Use Case: View Discussions
     * Retrieves top-level discussion threads for a course.
     */
    public List<Discussion> getTopLevelDiscussions(int courseId) {
        return em.createQuery(
                        "SELECT d FROM Discussion d WHERE d.course.courseId = :courseId AND d.parentPost IS NULL ORDER BY d.created_at DESC",
                        Discussion.class)
                .setParameter("courseId", courseId)
                .getResultList();
    }

    /**
     * Retrieves all announcements for a course, ordered by newest first.
     */
    public List<Announcement> getCourseAnnouncements(int courseId) {
        return em.createQuery(
                        "SELECT a FROM Announcement a WHERE a.course.courseId = :courseId ORDER BY a.postedAt DESC",
                        Announcement.class)
                .setParameter("courseId", courseId)
                .getResultList();
    }

    /**
     * Dashboard Utility: Get courses the student is already enrolled in.
     */
    public List<Course> getAllActiveCourses() {
        return em.createQuery("SELECT c FROM Course c WHERE c.isActive = true", Course.class)
                .getResultList();
    }
    public List<Integer> getEnrolledCourseIds(String studentId) {
        return em.createQuery(
                        "SELECT e.course.courseId FROM Enrollment e WHERE e.student.username = :studentId",
                        Integer.class)
                .setParameter("studentId", studentId)
                .getResultList();
    }

    /**
     * Use Case: Enrol Course
     * Gets all courses that the student has NOT enrolled in yet.
     */
    public void unenrollFromCourse(String studentId, int courseId) {
        try {
            Enrollment enrollment = em.createQuery(
                            "SELECT e FROM Enrollment e WHERE e.student.username = :sId AND e.course.courseId = :cId",
                            Enrollment.class)
                    .setParameter("sId", studentId)
                    .setParameter("cId", courseId)
                    .getSingleResult();
            em.remove(enrollment);
        } catch (NoResultException e) {
            // Student was not enrolled, safely ignore
        }
    }
    public List<Course> getEnrolledCourses(String studentId) {
        return em.createQuery(
                        "SELECT e.course FROM Enrollment e WHERE e.student.username = :studentId",
                        Course.class)
                .setParameter("studentId", studentId)
                .getResultList();
    }

    /**
     * Use Case: Enrol Course
     * Creates an enrollment record for the student and the selected course.
     */
    public void enrollInCourse(String studentId, int courseId) throws Exception {
        User student = em.find(User.class, studentId);
        Course course = em.find(Course.class, courseId);

        if (student != null && course != null) {
            // Check for existing enrollment to prevent duplicates
            Long count = em.createQuery(
                            "SELECT COUNT(e) FROM Enrollment e WHERE e.student.username = :sId AND e.course.courseId = :cId", Long.class)
                    .setParameter("sId", studentId)
                    .setParameter("cId", courseId)
                    .getSingleResult();

            if (count == 0) {
                Enrollment enrollment = new Enrollment();
                enrollment.setStudent(student);
                enrollment.setCourse(course);
                em.persist(enrollment);
            } else {
                throw new Exception("You are already enrolled in this course.");
            }
        }
    }

    /**
     * Use Case: View Course Materials
     * Retrieves all materials uploaded by the instructor for a specific course.
     */
    public List<Material> getCourseMaterials(int courseId) {
        return em.createQuery(
                        "SELECT m FROM Material m WHERE m.course.courseId = :courseId ORDER BY m.upload_date DESC",
                        Material.class)
                .setParameter("courseId", courseId)
                .getResultList();
    }

    /**
     * Use Case: Submit Assignments (and Resubmissions)
     * Handles uploading new assignment files or updating existing ones before the deadline.
     */
    public void submitAssignment(int assignmentId, String studentId, byte[] fileData, String fileName) throws Exception {
        Assignment assignment = em.find(Assignment.class, assignmentId);
        User student = em.find(User.class, studentId);

        if (assignment == null || student == null) {
            throw new Exception("Invalid assignment or student record.");
        }

        // Enforce Deadline Check
        if (assignment.getDeadline() != null && new Date().after(assignment.getDeadline())) {
            throw new Exception("The submission deadline has passed. Late submissions are not allowed.");
        }

        // Check if a submission already exists for this student and assignment
        Submission existingSubmission = null;
        try {
            existingSubmission = em.createQuery(
                            "SELECT s FROM Submission s WHERE s.assignment.assignmentId = :aId AND s.student.username = :sId",
                            Submission.class)
                    .setParameter("aId", assignmentId)
                    .setParameter("sId", studentId)
                    .getSingleResult();
        } catch (NoResultException e) {
            // No existing submission found, proceed to create a new one
        }

        if (existingSubmission != null) {
            // Requirement: "Students may also be allowed to update or resubmit their assignments before the deadline."
            existingSubmission.setFileContent(fileData);
            existingSubmission.setFile_name(fileName);
            existingSubmission.setSubmitted_at(new Date());
            existingSubmission.setSubmission_status("Resubmitted");
            em.merge(existingSubmission);
        } else {
            // Requirement: "allows students to upload assignment files" [cite: 24]
            Submission newSubmission = new Submission();
            newSubmission.setAssignment(assignment);
            newSubmission.setStudent(student);
            newSubmission.setFileContent(fileData);
            newSubmission.setFile_name(fileName);
            newSubmission.setSubmission_status("Submitted");
            em.persist(newSubmission);
        }
    }

    /**
     * Use Case: Participate in Discussions & Collaborate with Other Students [cite: 15, 17, 21, 22]
     * Allows students to post new questions or reply to existing ones.
     */
    public void postDiscussionMessage(int courseId, String studentId, String content, Integer parentPostId) {
        Course course = em.find(Course.class, courseId);
        User author = em.find(User.class, studentId);

        if (course != null && author != null) {
            Discussion discussion = new Discussion();
            discussion.setCourse(course);
            discussion.setAuthor(author);
            discussion.setContent(content);

            // Handle nested replies (comment on other students' questions) [cite: 21]
            if (parentPostId != null) {
                Discussion parent = em.find(Discussion.class, parentPostId);
                discussion.setParentPost(parent);
            }

            em.persist(discussion);
        }
    }

    /**
     * Helper Method: Get all discussions for a course
     */
    public List<Discussion> getCourseDiscussions(int courseId) {
        return em.createQuery(
                        "SELECT d FROM Discussion d WHERE d.course.courseId = :courseId ORDER BY d.created_at ASC",
                        Discussion.class)
                .setParameter("courseId", courseId)
                .getResultList();
    }
}
