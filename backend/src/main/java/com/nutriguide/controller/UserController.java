package com.nutriguide.controller;

import com.nutriguide.dto.ApiResponse;
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
import com.nutriguide.dto.ChangePasswordRequest;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody User user) {
        try {
            User registeredUser = userService.registerUser(user);
            return new ResponseEntity<>(
                Map.of(
                    "message", "Registration successful",
                    "userId", registeredUser.getId()
                ), 
                HttpStatus.CREATED
            );
        } catch (UserAlreadyExistsException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.CONFLICT
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Registration failed: " + e.getMessage()),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Create
    @PostMapping
    public ResponseEntity<?> createUser(@Valid @RequestBody User user, 
                                      @RequestParam(defaultValue = "REGULAR") String userType) {
        try {
            User createdUser = userService.save(user, userType.toUpperCase());
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

    @PutMapping("/{userId}/type")
    public ResponseEntity<?> updateUserType(
            @PathVariable Long userId,
            @RequestBody Map<String, String> payload) {
        try {
            String newUserType = payload.get("userType");
            if (newUserType == null) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "User type is required"));
            }
            
            userService.updateUserType(userId, newUserType);
            return ResponseEntity.ok(new ApiResponse(true, "User type updated successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse(false, "Failed to update user type: " + e.getMessage()));
        }
    }

    // Subscription Management
    @PostMapping("/{userId}/upgrade-to-premium")
    public ResponseEntity<?> upgradeToPremium(@PathVariable Long userId) {
        try {
            UserProfileDto updatedProfile = userService.upgradeToPremium(userId);
            return ResponseEntity.ok(updatedProfile);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to upgrade to premium"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    @PostMapping("/{userId}/downgrade-to-regular")
    public ResponseEntity<?> downgradeToRegular(@PathVariable Long userId) {
        try {
            UserProfileDto updatedProfile = userService.downgradeToRegular(userId);
            return ResponseEntity.ok(updatedProfile);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to downgrade to regular"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Subscription Status
    @GetMapping("/{userId}/subscription-status")
    public ResponseEntity<?> getSubscriptionStatus(@PathVariable Long userId) {
        try {
            UserProfileDto profile = userService.getUserProfile(userId);
            Map<String, Object> status = Map.of(
                "isPremium", profile.isPremiumUser(),
                "hasActiveSubscription", profile.hasActiveSubscription(),
                "remainingDays", profile.getRemainingSubscriptionDays(),
                "features", Map.of(
                    "aiRecommendations", profile.canAccessPremiumFeature("AI_RECOMMENDATIONS"),
                    "advancedAnalytics", profile.canAccessPremiumFeature("ADVANCED_ANALYTICS"),
                    "unlimitedRecipes", profile.canAccessPremiumFeature("UNLIMITED_RECIPES"),
                    "unlimitedMealPlans", profile.canAccessPremiumFeature("UNLIMITED_MEAL_PLANS")
                )
            );
            return ResponseEntity.ok(status);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to get subscription status"),
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

    // Delete user health data
    @DeleteMapping("/{userId}/health")
    public ResponseEntity<?> deleteUserHealthData(@PathVariable Long userId) {
        try {
            userService.deleteUserHealthData(userId);
            return ResponseEntity.ok(Map.of(
                "message", "User health data deleted successfully"
            ));
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to delete user health data"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Delete user goals
    @DeleteMapping("/{userId}/goals")
    public ResponseEntity<?> deleteUserGoals(@PathVariable Long userId) {
        try {
            userService.deleteUserGoals(userId);
            return ResponseEntity.ok(Map.of(
                "message", "User goals deleted successfully"
            ));
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to delete user goals"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    // Delete user allergies
    @DeleteMapping("/{userId}/allergies")
    public ResponseEntity<?> deleteUserAllergies(@PathVariable Long userId) {
        try {
            userService.deleteUserAllergies(userId);
            return ResponseEntity.ok(Map.of(
                "message", "User allergies deleted successfully"
            ));
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to delete user allergies"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    @PutMapping("/{userId}/password")
    public ResponseEntity<?> changePassword(
        @PathVariable Long userId,
        @RequestBody ChangePasswordRequest request
    ) {
        try {
            userService.changePassword(userId, request.getCurrentPassword(), request.getNewPassword());
            return ResponseEntity.ok(new ApiResponse(true, "Password changed successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, "Failed to change password: " + e.getMessage()));
        }
    }

    // Profile Completion
    @GetMapping("/{userId}/profile-completion")
    public ResponseEntity<?> getProfileCompletion(@PathVariable Long userId) {
        try {
            UserProfileDto profile = userService.getUserProfile(userId);
            Map<String, Object> completion = Map.of(
                "isComplete", profile.isProfileComplete(),
                "percentage", profile.getProfileCompletionPercentage(),
                "missingFields", getMissingFields(profile)
            );
            return ResponseEntity.ok(completion);
        } catch (ResourceNotFoundException e) {
            return new ResponseEntity<>(
                Map.of("error", e.getMessage()),
                HttpStatus.NOT_FOUND
            );
        } catch (Exception e) {
            return new ResponseEntity<>(
                Map.of("error", "Failed to get profile completion status"),
                HttpStatus.INTERNAL_SERVER_ERROR
            );
        }
    }

    private List<String> getMissingFields(UserProfileDto profile) {
        List<String> missingFields = new java.util.ArrayList<>();
        if (profile.getFirstName() == null || profile.getFirstName().trim().isEmpty()) {
            missingFields.add("firstName");
        }
        if (profile.getLastName() == null || profile.getLastName().trim().isEmpty()) {
            missingFields.add("lastName");
        }
        if (profile.getBio() == null || profile.getBio().trim().isEmpty()) {
            missingFields.add("bio");
        }
        if (!profile.hasValidProfilePicture()) {
            missingFields.add("profilePicture");
        }
        return missingFields;
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