package com.nutriguide.service;

import com.nutriguide.dto.ApiResponse;
import com.nutriguide.dto.LoginRequest;
import com.nutriguide.dto.RegisterRequest;
import com.nutriguide.dto.UserProfileDto;
import com.nutriguide.model.User;
import com.nutriguide.model.RegularUser;
import com.nutriguide.model.PremiumUser;
import com.nutriguide.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@Transactional
public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private UserRepository userRepository;

    public ResponseEntity<?> register(RegisterRequest request) {
        try {
            logger.info("Processing registration for: {}", request.getUsername());
            
            // Validate password
            if (!isPasswordValid(request.getPassword())) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Password does not meet security requirements"));
            }

            // Validate unique username
            if (userRepository.existsByUsername(request.getUsername())) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Username is already taken"));
            }

            // Validate unique email
            if (userRepository.existsByEmail(request.getEmail())) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Email is already registered"));
            }

            // Create user based on type
            User user;
            if ("PREMIUM".equals(request.getUserType().toString())) {
                user = createPremiumUser(request);
            } else {
                user = createRegularUser(request);
            }

            User savedUser = userRepository.save(user);
            logger.info("User registered successfully: {}", savedUser.getUsername());

            // Prepare response
            Map<String, Object> response = createUserResponse(savedUser);

            return ResponseEntity.ok(new ApiResponse(true, "User registered successfully", response));
        } catch (Exception e) {
            logger.error("Registration error: ", e);
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, "Registration failed: " + e.getMessage()));
        }
    }

    public boolean isPasswordValid(String password) {
        // Minimal 8 karakter
        if (password.length() < 8) return false;
        
        // Harus mengandung minimal 1 huruf besar
        if (!password.matches(".*[A-Z].*")) return false;
        
        // Harus mengandung minimal 1 huruf kecil
        if (!password.matches(".*[a-z].*")) return false;
        
        // Harus mengandung minimal 1 angka
        if (!password.matches(".*\\d.*")) return false;
        
        // Harus mengandung minimal 1 karakter spesial
        return password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?].*");
    }

    private PremiumUser createPremiumUser(RegisterRequest request) {
        return PremiumUser.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(request.getPassword())
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .createdAt(LocalDateTime.now())
            .updatedAt(LocalDateTime.now())
            .subscriptionEndDate(LocalDateTime.now().plusMonths(1))
            .unlimitedSavedRecipes(true)
            .unlimitedMealPlans(true)
            .build();
    }

    private RegularUser createRegularUser(RegisterRequest request) {
        return RegularUser.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(request.getPassword())
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .createdAt(LocalDateTime.now())
            .updatedAt(LocalDateTime.now())
            .maxSavedRecipes(10)
            .maxMealPlans(7)
            .build();
    }

    public ResponseEntity<?> login(LoginRequest request) {
        try {
            logger.info("Processing login for: {}", request.getEmail());
            
            // Find user by email
            User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

            // Verify password
            if (!request.getPassword().equals(user.getPassword())) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Invalid password"));
            }

            // Prepare response
            Map<String, Object> response = createUserResponse(user);
            
            logger.info("User logged in successfully: {}", user.getUsername());
            return ResponseEntity.ok(new ApiResponse(true, "Login successful", response));
        } catch (Exception e) {
            logger.error("Login error: ", e);
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, "Login failed: " + e.getMessage()));
        }
    }

    private Map<String, Object> createUserResponse(User user) {
        Map<String, Object> response = new HashMap<>();
        response.put("userId", user.getId());
        response.put("username", user.getUsername());
        response.put("email", user.getEmail());
        response.put("firstName", user.getFirstName());
        response.put("lastName", user.getLastName());
        response.put("profilePictureUrl", user.getProfilePictureUrl());
        response.put("createdAt", user.getCreatedAt());
        response.put("updatedAt", user.getUpdatedAt());

        // Add type-specific information
        if (user instanceof PremiumUser premiumUser) {
            response.put("userType", "PREMIUM");
            response.put("subscriptionEndDate", premiumUser.getSubscriptionEndDate());
            response.put("unlimitedSavedRecipes", premiumUser.getUnlimitedSavedRecipes());
            response.put("unlimitedMealPlans", premiumUser.getUnlimitedMealPlans());
        } else if (user instanceof RegularUser regularUser) {
            response.put("userType", "REGULAR");
            response.put("maxSavedRecipes", regularUser.getMaxSavedRecipes());
            response.put("maxMealPlans", regularUser.getMaxMealPlans());
        }

        return response;
    }

    public boolean isEmailAvailable(String email) {
        return !userRepository.existsByEmail(email);
    }

    public boolean isUsernameAvailable(String username) {
        return !userRepository.existsByUsername(username);
    }

    public UserProfileDto getUserProfile(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        return convertToProfileDto(user);
    }

    private UserProfileDto convertToProfileDto(User user) {
        UserProfileDto.UserProfileDtoBuilder builder = UserProfileDto.builder()
            .id(user.getId())
            .username(user.getUsername())
            .email(user.getEmail())
            .firstName(user.getFirstName())
            .lastName(user.getLastName())
            .bio(user.getBio())
            .profilePictureUrl(user.getProfilePictureUrl())
            .createdAt(user.getCreatedAt())
            .updatedAt(user.getUpdatedAt());

        if (user instanceof PremiumUser premiumUser) {
            builder
                .userType("PREMIUM")
                .subscriptionEndDate(premiumUser.getSubscriptionEndDate())
                
                .unlimitedSavedRecipes(premiumUser.getUnlimitedSavedRecipes())
                .unlimitedMealPlans(premiumUser.getUnlimitedMealPlans());
        } else if (user instanceof RegularUser regularUser) {
            builder
                .userType("REGULAR")
                .maxSavedRecipes(regularUser.getMaxSavedRecipes())
                .maxMealPlans(regularUser.getMaxMealPlans());
        }

        return builder.build();
    }

    @Transactional
    public UserProfileDto updateProfile(Long userId, UserProfileDto profileDto) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        // Update fields if provided
        if (profileDto.getFirstName() != null) {
            user.setFirstName(profileDto.getFirstName());
        }
        if (profileDto.getLastName() != null) {
            user.setLastName(profileDto.getLastName());
        }
        if (profileDto.getBio() != null) {
            user.setBio(profileDto.getBio());
        }
        if (profileDto.getProfilePictureUrl() != null) {
            user.setProfilePictureUrl(profileDto.getProfilePictureUrl());
        }

        user.setUpdatedAt(LocalDateTime.now());
        User updatedUser = userRepository.save(user);

        return convertToProfileDto(updatedUser);
    }

    // Method untuk mengecek status subscription
    public boolean isSubscriptionActive(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        if (user instanceof PremiumUser premiumUser) {
            return premiumUser.getSubscriptionEndDate().isAfter(LocalDateTime.now());
        }
        return false;
    }

    // Method untuk memperpanjang subscription
    @Transactional
    public void extendSubscription(Long userId, int months) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        if (user instanceof PremiumUser premiumUser) {
            LocalDateTime currentEndDate = premiumUser.getSubscriptionEndDate();
            LocalDateTime newEndDate;
            
            if (currentEndDate.isBefore(LocalDateTime.now())) {
                newEndDate = LocalDateTime.now().plusMonths(months);
            } else {
                newEndDate = currentEndDate.plusMonths(months);
            }
            
            premiumUser.setSubscriptionEndDate(newEndDate);
            userRepository.save(premiumUser);
        } else {
            throw new RuntimeException("User is not a premium user");
        }
    }
}