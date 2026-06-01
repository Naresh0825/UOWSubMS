package com.subms.student.resource;

import com.subms.student.model.User;
import com.subms.student.service.UserService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.List;

@Path("/users") // Combines with your "/api" ApplicationPath to become "/api/users"
//@RolesAllowed("teacher")
public class UserResource {

    @Inject // In CDI/JAX-RS, we typically use @Inject instead of @EJB
    private UserService userService;

    @POST
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createUser(
            @FormParam("username") String username,
            @FormParam("email") String email,
            @FormParam("fullname") String fullname,
            @FormParam("role") String role,
            @DefaultValue("false") @FormParam("membership") boolean membership) {

        try {
            // Basic validation
            if (username == null || email == null || fullname == null || role == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"status\":\"error\", \"message\":\"Missing required fields: username, email, fullname, or role.\"}")
                        .build();
            }

            // Create the user via the service
            userService.createUser(username, email, fullname, role, membership);

            // Return success JSON (201 Created)
            return Response.status(Response.Status.CREATED)
                    .entity("{\"status\":\"success\", \"message\":\"User created successfully.\"}")
                    .build();

        } catch (Exception e) {
            // Handle errors (409 Conflict)
            return Response.status(Response.Status.CONFLICT)
                    .entity("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}")
                    .build();
        }
    }
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllUsers() {
        try {
            // Fetch the list of users from the service
            List<User> users = userService.getAllUsers();

            // Return 200 OK with the list of users as JSON
            return Response.ok(users).build();

        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}")
                    .build();
        }
    }
}