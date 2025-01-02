package com.nutriguide.service;

import com.nutriguide.dto.ApiResponse;
import com.nutriguide.dto.LoginRequest;
import com.nutriguide.dto.RegisterRequest;
import com.nutriguide.dto.UserProfileDto;
import com.nutriguide.model.User;
import com.nutriguide.model.UserRole;
import com.nutriguide.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private UserRepository userRepository;

    @Transactional
public ResponseEntity<?> register(RegisterRequest request) {
    try {
        // Validation
        if (userRepository.existsByUsername(request.getUsername())) {
            return ResponseEntity.badRequest()
                .body(new ApiResponse<>(false, "Username already exists"));
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            return ResponseEntity.badRequest()
                .body(new ApiResponse<>(false, "Email already exists"));
        }

        // Create new user with selected account type
        User user = User.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(request.getPassword())
            .roleUser(request.getAccountType()) // Use the selected account type
            .createdAt(LocalDateTime.now())
            .updatedAt(LocalDateTime.now())
            .build();

        // Save user
        user = userRepository.save(user);
        logger.info("User registered successfully: {} with role: {}", 
            user.getUsername(), user.getRoleUser());

        // Create response with token
        Map<String, Object> userData = new HashMap<>();
        userData.put("id", user.getId());
        userData.put("username", user.getUsername());
        userData.put("email", user.getEmail());
        userData.put("roleUser", user.getRoleUser().getValue());
        userData.put("token", generateToken(user));

        return ResponseEntity.ok(new ApiResponse<>(true, "Registration successful", userData));
    } catch (Exception e) {
        logger.error("Registration error: ", e);
        return ResponseEntity.badRequest()
            .body(new ApiResponse<>(false, "Registration failed", e.getMessage()));
    }
}

    public ResponseEntity<?> login(LoginRequest request) {
        try {
            User user = userRepository.findByEmail(request.getEmail())
                .orElse(null);

            if (user == null || !request.getPassword().equals(user.getPassword())) {
                logger.warn("Login failed: Invalid credentials for email: {}", request.getEmail());
                return ResponseEntity.badRequest()
                    .body(new ApiResponse<>(false, "Invalid email or password"));
            }

            // Create response with token
            Map<String, Object> userData = new HashMap<>();
            userData.put("id", user.getId());
            userData.put("username", user.getUsername());
            userData.put("email", user.getEmail());
            userData.put("roleUser", user.getRoleUser().getValue());
            userData.put("token", generateToken(user)); // Add simple token

            logger.info("User logged in successfully: {}", user.getUsername());
            return ResponseEntity.ok(new ApiResponse<>(true, "Login successful", userData));
        } catch (Exception e) {
            logger.error("Login error: ", e);
            return ResponseEntity.badRequest()
                .body(new ApiResponse<>(false, "Login failed", e.getMessage()));
        }
    }

    public boolean isEmailAvailable(String email) {
        boolean isAvailable = !userRepository.existsByEmail(email);
        logger.debug("Email availability check: {} - {}", email, isAvailable);
        return isAvailable;
    }

    public boolean isUsernameAvailable(String username) {
        boolean isAvailable = !userRepository.existsByUsername(username);
        logger.debug("Username availability check: {} - {}", username, isAvailable);
        return isAvailable;
    }

    private UserProfileDto convertToProfileDto(User user) {
        return UserProfileDto.builder()
            .id(user.getId())
            .username(user.getUsername())
            .email(user.getEmail())
            .firstName(user.getFirstName())
            .lastName(user.getLastName())
            .bio(user.getBio())
            .profilePictureUrl(user.getProfilePictureUrl())
            .createdAt(user.getCreatedAt())
            .updatedAt(user.getUpdatedAt())
            .build();
    }

    private String generateToken(User user) {
        return Base64.getEncoder().encodeToString(
            (user.getId() + ":" + user.getEmail() + ":" + System.currentTimeMillis())
                .getBytes(StandardCharsets.UTF_8)
        );
    }
}