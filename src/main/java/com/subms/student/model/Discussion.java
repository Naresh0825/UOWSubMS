package com.subms.student.model;
import jakarta.persistence.*;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "discussions")
public class Discussion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int post_id;

    @ManyToOne
    @JoinColumn(name = "course_id")
    private Course course;

    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName = "username")
    private User author;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    // Self-referencing relationship for replies
    @ManyToOne
    @JoinColumn(name = "parent_post_id")
    private Discussion parentPost;

    @OneToMany(mappedBy = "parentPost", cascade = CascadeType.ALL)
    private List<Discussion> replies;

    @Temporal(TemporalType.TIMESTAMP)
    private Date created_at;

    // Getters and Setters...

    public int getPost_id() {
        return post_id;
    }

    public void setPost_id(int post_id) {
        this.post_id = post_id;
    }

    public Date getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Date created_at) {
        this.created_at = created_at;
    }

    public List<Discussion> getReplies() {
        return replies;
    }

    public void setReplies(List<Discussion> replies) {
        this.replies = replies;
    }

    public Discussion getParentPost() {
        return parentPost;
    }

    public void setParentPost(Discussion parentPost) {
        this.parentPost = parentPost;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public User getAuthor() {
        return author;
    }

    public void setAuthor(User author) {
        this.author = author;
    }

    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }
}