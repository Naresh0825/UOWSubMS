package com.subms.student.model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "users")
public class User {
    @Id
    @Column(name = "username")
    private String username; // This is the Kinde 'sub' [cite: 19]

    @Column(unique = true, nullable = false)
    private String email;

    private String fullname;

    @Enumerated(EnumType.STRING)
    private Role role; // 'student' or 'instructor' [cite: 11, 27]

    @Temporal(TemporalType.TIMESTAMP)
    private Date created_at = new Date();

    public enum Role {
        student, teacher
    }
    @Column(name = "membership", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private boolean membership;
    @Column(name = "skills", length = 500)
    private String skills; // e.g., "Java, Flutter, BLoC"

    @Enumerated(EnumType.STRING)
    @Column(name = "collaboration_mode")
    private CollaborationMode collaborationMode = CollaborationMode.Online;

    @Column(name = "availability")
    private String availability; // e.g., "Weekends", "Mon-Wed Evenings"

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFullname() {
        return fullname;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public Date getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Date created_at) {
        this.created_at = created_at;
    }


    public boolean isMembership() { return membership; }
    public void setMembership(boolean membership) { this.membership = membership; }

    public enum CollaborationMode {
        Online, Offline, Hybrid
    }



    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills; }

    public CollaborationMode getCollaborationMode() { return collaborationMode; }
    public void setCollaborationMode(CollaborationMode collaborationMode) { this.collaborationMode = collaborationMode; }

    public String getAvailability() { return availability; }
    public void setAvailability(String availability) { this.availability = availability; }
}