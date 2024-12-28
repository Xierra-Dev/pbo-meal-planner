package com.nutriguide.controller;

import com.nutriguide.dto.UserProfileDto;
import com.nutriguide.model.User;
import com.nutriguide.exception.ResourceNotFoundException;
import com.nutriguide.exception.UserAlreadyExistsException;
import com.nutriguide.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*") // Sesuaikan dengan domain Flutter app
public class UserController {

    @Autowired
    private UserService userService;

    // Create
    @PostMapping
    public ResponseEntity<?> createUser(@Valid @RequestBody User user) {
        try {
            User createdUser = userService.save(user);
            return new ResponseEntity<>(createdUser, HttpStatus.CREATED);
        } catch (UserAlreadyExistsException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.CONFLICT
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to create user"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Read
    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        try {
            User user = userService.findById(id);
            return ResponseEntity.ok(user);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to get user"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    @GetMapping
    public ResponseEntity<List<UserProfileDto>> getAllUsers() {
        try {
            List<UserProfileDto> users = userService.findAll();
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/username/{username}")
    public ResponseEntity<?> getUserByUsername(@PathVariable String username) {
        try {
            User user = userService.findByUsername(username);
            return ResponseEntity.ok(user);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to get user"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Profile
    @GetMapping("/{userId}/profile")
    public ResponseEntity<?> getUserProfile(@PathVariable Long userId) {
        try {
            UserProfileDto profile = userService.getUserProfile(userId);
            return ResponseEntity.ok(profile);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to get user profile"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    @PutMapping("/{userId}/profile")
    public ResponseEntity<?> updateProfile(
        @PathVariable Long userId,
        @Valid @RequestBody UserProfileDto profileDto
    ) {
        try {
            UserProfileDto updatedProfile = userService.updateProfile(userId, profileDto);
            return ResponseEntity.ok(updatedProfile);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (UserAlreadyExistsException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.CONFLICT
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to update profile"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Check username/email availability
    @GetMapping("/check-username/{username}")
    public ResponseEntity<Map<String, Boolean>> checkUsernameAvailability(@PathVariable String username) {
        boolean exists = userService.existsByUsername(username);
        return ResponseEntity.ok(Map.of("available", !exists));
    }

    @GetMapping("/check-email/{email}")
    public ResponseEntity<Map<String, Boolean>> checkEmailAvailability(@PathVariable String email) {
        boolean exists = userService.existsByEmail(email);
        return ResponseEntity.ok(Map.of("available", !exists));
    }

    // Delete
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        try {
            userService.delete(id);
            return new ResponseEntity<>(
                Map.of("message", "User deleted successfully"),
                HttpStatus.OK
            );
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to delete user"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Error handler untuk validation errors
    @ExceptionHandler(jakarta.validation.ConstraintViolationException.class)
    public ResponseEntity<?> handleValidationExceptions(jakarta.validation.ConstraintViolationException e) {
        Map<String, String> errors = Map.of(
            "error", "Validation failed",
            "details", e.getMessage()
        );
        return new ResponseEntity<>(errors, HttpStatus.BAD_REQUEST);
    }
}