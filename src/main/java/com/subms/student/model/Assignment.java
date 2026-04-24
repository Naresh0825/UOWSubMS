package com.subms.student.model;
import jakarta.persistence.*;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "assignments")
public class Assignment {

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
    private Date deadline; // Allows students to view deadlines [cite: 24]

    // One assignment can have many student submissions [cite: 37]
    @OneToMany(mappedBy = "assignment", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Submission> submissions;

    // Constructors
    public Assignment() {}

    // Getters and Setters
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

    public List<Submission> getSubmissions() { return submissions; }
    public void setSubmissions(List<Submission> submissions) { this.submissions = submissions; }
}
