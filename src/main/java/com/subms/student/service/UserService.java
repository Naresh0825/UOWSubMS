package com.subms.student.service;

import com.subms.student.model.User;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

@Stateless
public class UserService {

    @PersistenceContext(unitName = "CoursePU")
    private EntityManager em;
    public List<User> getAllUsers() {
        return em.createQuery("SELECT u FROM User u ORDER BY u.created_at DESC", User.class)
                .getResultList();
    }
    /**
     * Updates a student's collaboration profile.
     */
    public void updateStudentProfile(String username, String skills, String collaborationModeStr, String availability) throws Exception {
        User user = em.find(User.class, username);
        if (user != null) {
            user.setSkills(skills);
            user.setAvailability(availability);

            try {
                if (collaborationModeStr != null && !collaborationModeStr.isEmpty()) {
                    user.setCollaborationMode(User.CollaborationMode.valueOf(collaborationModeStr));
                }
            } catch (IllegalArgumentException e) {
                // Ignore invalid enum strings and keep the existing mode
            }

            em.merge(user);
        } else {
            throw new Exception("User not found.");
        }
    }
    /**
     * Creates a new user in the database via the API.
     */
    public User createUser(String username, String email, String fullname, String roleStr, boolean membership) throws Exception {
        // Check if user already exists
        User existingUser = em.find(User.class, username);
        if (existingUser != null) {
            throw new Exception("User with this username already exists.");
        }

        User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setFullname(fullname);
        newUser.setMembership(membership);

        // Convert the String to the Enum safely
        try {
            newUser.setRole(User.Role.valueOf(roleStr.toLowerCase()));
        } catch (IllegalArgumentException | NullPointerException e) {
            throw new Exception("Invalid role. Role must be either 'student' or 'teacher'.");
        }

        em.persist(newUser);
        return newUser;
    }
}