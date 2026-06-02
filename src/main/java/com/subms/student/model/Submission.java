package com.subms.student.model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "submissions")
public class Submission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int submission_id;

    @ManyToOne
    @JoinColumn(name = "assignment_id")
    private Assignment assignment;

    @ManyToOne
    @JoinColumn(name = "student_id")
    private User student;

    @Lob
    @Column(name = "file_content", columnDefinition = "LONGBLOB")
    private byte[] fileContent; // The binary file data [cite: 24]

    private String file_name;
    private String submission_status = "Submitted";
    private String grade;

    @Temporal(TemporalType.TIMESTAMP)
    private Date submitted_at = new Date();


    @Column(name = "attempt_count", columnDefinition = "INT DEFAULT 1")
    private int attempt_count = 1;

    public int getAttempt_count() { return attempt_count; }
    public void setAttempt_count(int attempt_count) { this.attempt_count = attempt_count; }


    public int getSubmission_id() {
        return submission_id;
    }

    public void setSubmission_id(int submission_id) {
        this.submission_id = submission_id;
    }

    public Assignment getAssignment() {
        return assignment;
    }

    public void setAssignment(Assignment assignment) {
        this.assignment = assignment;
    }

    public User getStudent() {
        return student;
    }

    public void setStudent(User student) {
        this.student = student;
    }

    public byte[] getFileContent() {
        return fileContent;
    }

    public void setFileContent(byte[] fileContent) {
        this.fileContent = fileContent;
    }

    public String getFile_name() {
        return file_name;
    }

    public void setFile_name(String file_name) {
        this.file_name = file_name;
    }

    public String getSubmission_status() {
        return submission_status;
    }

    public void setSubmission_status(String submission_status) {
        this.submission_status = submission_status;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public Date getSubmitted_at() {
        return submitted_at;
    }

    public void setSubmitted_at(Date submitted_at) {
        this.submitted_at = submitted_at;
    }
}
