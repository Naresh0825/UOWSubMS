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
     * Submits and automatically grades a quiz.
     */
    /**
     * Submits and automatically grades a quiz. (Strictly 1 Attempt)
     */
    public void submitQuiz(int assignmentId, String username, java.util.Map<Integer, String> studentAnswers) throws Exception {
        User user = em.find(User.class, username);
        Assignment assignment = em.find(Assignment.class, assignmentId);

        // 1. Deadline Check
        if (new java.util.Date().after(assignment.getDeadline())) {
            throw new Exception("Cannot submit: The deadline has passed.");
        }

        // Fetch existing submission
        Submission existingSub = getStudentSubmission(assignmentId, username);

        // --- NEW: STRICT ONE-ATTEMPT RULE ---
        if (existingSub != null) {
            throw new Exception("Quiz locked: You have already completed this quiz. Multiple attempts are not allowed.");
        }

        // --- 2. THE AUTO-MARKING ENGINE ---
        int totalScore = 0;
        int maxScore = 0;

        // Loop through all questions in this quiz
        for (AssignmentQuestion q : assignment.getQuestions()) {
            maxScore += q.getPoints();

            // Get the student's answer for this specific question
            String studentAnswer = studentAnswers.get(q.getQuestion_id());

            if (studentAnswer != null && !studentAnswer.trim().isEmpty()) {
                // For Fill-in-the-Blanks, ignore uppercase/lowercase differences
                if ("FITB".equals(q.getQuestionType())) {
                    if (studentAnswer.trim().equalsIgnoreCase(q.getCorrectAnswer().trim())) {
                        totalScore += q.getPoints();
                    }
                }
                // For Multiple Choice / Exact Match, do a strict check
                else {
                    if (studentAnswer.trim().equals(q.getCorrectAnswer().trim())) {
                        totalScore += q.getPoints();
                    }
                }
            }
        }

        // Format the final auto-grade (e.g., "85/100")
        String finalGrade = totalScore + "/" + maxScore;

        // --- 3. SAVE THE GRADE ---
        // (Since existingSub will always be null here, we only need the persist block)
        Submission newSub = new Submission();
        newSub.setAssignment(assignment);
        newSub.setStudent(user);
        newSub.setAttempt_count(1);
        newSub.setGrade(finalGrade); // Instantly graded!
        newSub.setFile_name("Quiz Auto-Submission");
        em.persist(newSub);
    }

    /**
     * Retrieves a specific student's submission for an assignment.
     */

    public Submission getStudentSubmission(int assignmentId, String studentId) {
        try {
            return em.createQuery(
                            "SELECT s FROM Submission s WHERE s.assignment.assignmentId = :aId AND s.student.username = :sId",
                            Submission.class)
                    .setParameter("aId", assignmentId)
                    .setParameter("sId", studentId)
                    .getSingleResult();
        } catch (jakarta.persistence.NoResultException e) {
            return null; // Student hasn't submitted anything yet
        }
    }
    /**
     * Retrieves all assignments for a specific course.
     * Orders them by deadline so upcoming assignments appear at the top.
     */
    public List<Assignment> getAssignmentsByCourse(int courseId) {
        return em.createQuery(
                        "SELECT a FROM Assignment a WHERE a.course.courseId = :courseId ORDER BY a.deadline ASC",
                        Assignment.class)
                .setParameter("courseId", courseId)
                .getResultList();
    }
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
     * Retrieves all materials for a specific course, ordered by newest first.
     */
    public List<Material> getCourseMaterials(int courseId) {
        return em.createQuery(
                        // FIXED: Changed m.uploaded_at to m.upload_date to match your entity
                        "SELECT m FROM Material m WHERE m.course.courseId = :courseId ORDER BY m.upload_date DESC",
                        Material.class)
                .setParameter("courseId", courseId)
                .getResultList();
    }

    /**
     * Use Case: Submit Assignments (and Resubmissions)
     * Handles uploading new assignment files or updating existing ones before the deadline.
     */
    /**
     * Submits or re-submits an assignment. Enforces membership limits.
     */
    public void submitAssignment(int assignmentId, String username, byte[] fileData, String fileName) throws Exception {
        User user = em.find(User.class, username);
        Assignment assignment = em.find(Assignment.class, assignmentId);

        // 1. Deadline Check (Applies to everyone)
        if (new java.util.Date().after(assignment.getDeadline())) {
            throw new Exception("Cannot submit: The deadline has passed.");
        }

        // Fetch existing submission (if any)
        Submission existingSub = getStudentSubmission(assignmentId, username);

        if (existingSub != null) {
            // --- 2. IT'S A RESUBMISSION: MEMBERSHIP CHECK ---
            if (!user.isMembership()) {
                // Free users get the initial submission (attempt 1) + 2 resubmissions (attempts 2 and 3)
                if (existingSub.getAttempt_count() >= 3) {
                    throw new Exception("Free tier limit reached: Maximum 2 resubmissions allowed. Upgrade to Pro for unlimited resubmissions!");
                }
            }

            // Update the existing submission
            existingSub.setFileContent(fileData);
            existingSub.setFile_name(fileName);
            existingSub.setSubmitted_at(new java.util.Date());
            existingSub.setAttempt_count(existingSub.getAttempt_count() + 1); // Increment counter

            em.merge(existingSub);

        } else {
            // --- 3. FIRST TIME SUBMISSION ---
            Submission newSub = new Submission();
            newSub.setAssignment(assignment);
            newSub.setStudent(user);
            newSub.setFileContent(fileData);
            newSub.setFile_name(fileName);
            newSub.setAttempt_count(1);

            em.persist(newSub);
        }
    }
    /**
     * Use Case: Participate in Discussions & Collaborate with Other Students [cite: 15, 17, 21, 22]
     * Allows students to post new questions or reply to existing ones.
     */
    /**
     * Posts a discussion message. Enforces membership limits.
     */
    public void postDiscussionMessage(int courseId, String username, String content, Integer parentId) throws Exception {
        User user = em.find(User.class, username);

        // --- 1. MEMBERSHIP CHECK FOR DISCUSSIONS ---
        if (!user.isMembership()) {
            // Calculate the date exactly 7 days ago
            java.util.Date oneWeekAgo = new java.util.Date(System.currentTimeMillis() - (7L * 24 * 3600 * 1000));

            // FIXED: Changed d.createdAt to d.created_at to match your entity!
            Long recentPostCount = em.createQuery(
                            "SELECT COUNT(d) FROM Discussion d WHERE d.author.username = :username AND d.created_at >= :oneWeekAgo",
                            Long.class)
                    .setParameter("username", username)
                    .setParameter("oneWeekAgo", oneWeekAgo)
                    .getSingleResult();

            if (recentPostCount >= 10) {
                throw new Exception("Free tier limit reached: You can only post 10 discussions per week. Upgrade to Pro for unlimited posts!");
            }
        }

        // --- 2. PROCEED WITH POSTING ---
        Course course = em.find(Course.class, courseId);
        Discussion post = new Discussion();
        post.setCourse(course);
        post.setAuthor(user);
        post.setContent(content);
        // post.setParentId(parentId); // If threaded

        em.persist(post);
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
