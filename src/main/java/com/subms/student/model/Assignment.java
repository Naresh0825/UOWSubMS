package com.subms.student.model;

import jakarta.persistence.*;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "assignments")
public class Assignment {
    // Constructors
    public Assignment() {}
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "assignment_id")
    private int assignmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course; // Links to the specific Course space

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description; // Defines submission requirements

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "deadline")
    private Date deadline; // Allows students to view deadlines

    // --- New Fields for Instructor Resource Uploads ---
    @Lob
    @Column(columnDefinition = "LONGBLOB")
    private byte[] resourceContent;

    @Column(name = "resourceFilename")
    private String resourceFilename;
    // --------------------------------------------------

    // One assignment can have many student submissions
    @OneToMany(mappedBy = "assignment", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Submission> submissions;


    @Column(name = "is_quiz", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private boolean isQuiz = false;

    @OneToMany(mappedBy = "assignment", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private java.util.List<AssignmentQuestion> questions;

    // Getters and Setters
    public boolean isQuiz() { return isQuiz; }
    public void setQuiz(boolean isQuiz) { this.isQuiz = isQuiz; }

    public java.util.List<AssignmentQuestion> getQuestions() { return questions; }
    public void setQuestions(java.util.List<AssignmentQuestion> questions) { this.questions = questions; }

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public Course getCourse() { return course; }
    public void setCourse(Course course) { this.course = course; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getDeadline() { return deadline; }
    public void setDeadline(Date deadline) { this.deadline = deadline; }

    public byte[] getResourceContent() { return resourceContent; }
    public void setResourceContent(byte[] resourceContent) { this.resourceContent = resourceContent; }

    public String getResourceFilename() { return resourceFilename; }
    public void setResourceFilename(String resourceFilename) { this.resourceFilename = resourceFilename; }

    public List<Submission> getSubmissions() { return submissions; }
    public void setSubmissions(List<Submission> submissions) { this.submissions = submissions; }
}