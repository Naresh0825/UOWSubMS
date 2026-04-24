package com.subms.student.model;
import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "courses")
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "course_id")
    private int courseId;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    // instructor_id links to users(username)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id")
    private User instructor;

    // Requirement: Upload Course Syllabus/Outline
    @Lob
    @Column(name = "outline_content", columnDefinition = "LONGBLOB")
    private byte[] outlineContent;

    @Column(name = "outline_filename")
    private String outlineFilename;

    // Relationships to other entities
    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL)
    private List<Assignment> assignments;

    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL)
    private List<Material> materials;

    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL)
    private List<Enrollment> enrollments;

    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL)
    private List<Discussion> discussions;

    @Column(name = "isActive", nullable = false)
    private boolean isActive = false;

    // Constructors
    public Course() {}

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    // Getters and Setters
    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public User getInstructor() { return instructor; }
    public void setInstructor(User instructor) { this.instructor = instructor; }

    public byte[] getOutlineContent() { return outlineContent; }
    public void setOutlineContent(byte[] outlineContent) { this.outlineContent = outlineContent; }

    public String getOutlineFilename() { return outlineFilename; }
    public void setOutlineFilename(String outlineFilename) { this.outlineFilename = outlineFilename; }
}
