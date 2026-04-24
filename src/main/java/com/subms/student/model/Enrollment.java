package com.subms.student.model;


import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "enrollments", uniqueConstraints = {@UniqueConstraint(columnNames = {"student_id", "course_id"})})
public class Enrollment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int enrollment_id;

    @ManyToOne
    @JoinColumn(name = "student_id", referencedColumnName = "username")
    private User student;

    @ManyToOne
    @JoinColumn(name = "course_id")
    private Course course;

    @Temporal(TemporalType.TIMESTAMP)
    private Date enrolled_at = new Date();

    // Getters and Setters...

    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }

    public int getEnrollment_id() {
        return enrollment_id;
    }

    public void setEnrollment_id(int enrollment_id) {
        this.enrollment_id = enrollment_id;
    }

    public User getStudent() {
        return student;
    }

    public void setStudent(User student) {
        this.student = student;
    }

    public Date getEnrolled_at() {
        return enrolled_at;
    }

    public void setEnrolled_at(Date enrolled_at) {
        this.enrolled_at = enrolled_at;
    }
}
