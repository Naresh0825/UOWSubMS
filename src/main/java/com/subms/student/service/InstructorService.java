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
     * Adds a new question to an auto-marked Quiz assignment.
     */
    public void addQuizQuestion(int assignmentId, String questionText, String questionType, String choices, String correctAnswer, int points) throws Exception {
        Assignment assignment = em.find(Assignment.class, assignmentId);

        if (assignment == null) {
            throw new Exception("Assignment not found.");
        }

        // Ensure this assignment is actually flagged as a quiz
        if (!assignment.isQuiz()) {
            assignment.setQuiz(true);
            em.merge(assignment);
        }

        AssignmentQuestion question = new AssignmentQuestion();
        question.setAssignment(assignment);
        question.setQuestionText(questionText);
        question.setQuestionType(questionType); // "MCQ" or "FITB"
        question.setChoices(choices); // e.g., "A) Java, B) Python, C) C++"
        question.setCorrectAnswer(correctAnswer);
        question.setPoints(points);

        em.persist(question);
    }
    /**
     * Retrieves all student submissions for a specific assignment.
     */
    public List<Submission> getSubmissionsForAssignment(int assignmentId) {
        return em.createQuery(
                        // FIXED: Changed ORDER BY s.submittedAt to s.submitted_at
                        "SELECT s FROM Submission s WHERE s.assignment.assignmentId = :assignmentId ORDER BY s.submitted_at ASC",
                        Submission.class)
                .setParameter("assignmentId", assignmentId)
                .getResultList();
    }

    /**
     * Grades a student's submission. Enforces the post-deadline rule.
     */
    /**
     * Grades a student's submission. Can be done anytime.
     */
    public void gradeSubmission(int submissionId, String grade) throws Exception {
        Submission submission = em.find(Submission.class, submissionId);
        if (submission != null) {
            submission.setGrade(grade);
            em.merge(submission); // Save the grade to the database
        }
    }
    public void postAnnouncement(int courseId, String title, String content) {
        Course course = em.find(Course.class, courseId);
        if (course != null) {
            Announcement announcement = new Announcement();
            announcement.setCourse(course);
            announcement.setTitle(title);
            announcement.setContent(content);
            em.persist(announcement);
        }
    }
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
    /**
     * Creates an assignment with an optional resource file attachment.
     */
    public void createAssignment(int courseId, String title, String description, java.util.Date deadline, byte[] fileData, String fileName, boolean isQuiz) {
        Course course = em.find(Course.class, courseId);
        if (course != null) {
            Assignment assignment = new Assignment();
            assignment.setCourse(course);
            assignment.setTitle(title);
            assignment.setDescription(description);
            assignment.setDeadline(deadline);
            assignment.setResourceContent(fileData);
            assignment.setResourceFilename(fileName);
            assignment.setQuiz(isQuiz); // <-- ADD THIS LINE
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
     * Uploads a new material file to a course.
     */
    public void uploadCourseMaterial(int courseId, String title, byte[] fileData, String fileName) {
        Course course = em.find(Course.class, courseId);
        if (course != null) {
            Material material = new Material();
            material.setCourse(course);
            material.setTitle(title);
            material.setFileContent(fileData);
            material.setFile_name(fileName);
            em.persist(material);
        }
    }

    /**
     * Deletes a course material.
     */
    public void deleteCourseMaterial(int materialId) {
        Material material = em.find(Material.class, materialId);
        if (material != null) {
            em.remove(material);
        }
    }

    /**
     * Use Case: Monitor Student Participation
     */

//    public List<Submission> getAssignmentSubmissions(int assignmentId) {
//        return em.createQuery("SELECT s FROM Submission s WHERE s.assignment.assignmentId = :aId", Submission.class)
//                .setParameter("aId", assignmentId)
//                .getResultList(); // Monitor results [cite: 41]
//    }
    public void updateCourseOutline(int courseId, byte[] newContent, String newFilename) {
        Course course = em.find(Course.class, courseId);
        if (course != null) {
            course.setOutlineContent(newContent);
            course.setOutlineFilename(newFilename);
            em.merge(course);
        }
    }

    /**
     * Deletes the course syllabus.
     */
    public void deleteCourseOutline(int courseId) {
        Course course = em.find(Course.class, courseId);
        if (course != null) {
            course.setOutlineContent(null);
            course.setOutlineFilename(null);
            em.merge(course);
        }
    }
}