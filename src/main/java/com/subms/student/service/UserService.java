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