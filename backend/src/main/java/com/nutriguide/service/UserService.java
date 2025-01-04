package com.nutriguide.service;

import com.nutriguide.dto.UserProfileDto;
import com.nutriguide.dto.UserResponseDto;
import com.nutriguide.model.User;
import com.nutriguide.model.RegularUser;
import com.nutriguide.model.PremiumUser;
import com.nutriguide.exception.ResourceNotFoundException;
import com.nutriguide.exception.UserAlreadyExistsException;
import com.nutriguide.repository.UserRepository;
import com.nutriguide.enums.UserType;
import jakarta.persistence.EntityManager;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;
import java.util.Map;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import com.nutriguide.repository.UserHealthDataRepository;
import com.nutriguide.repository.UserGoalRepository;
import com.nutriguide.repository.UserAllergyRepository;


@Service
@Validated
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EntityManager entityManager;

    @Autowired
    private UserHealthDataRepository userHealthDataRepository;

    @Autowired
    private UserGoalRepository userGoalRepository;

    @Autowired
    private UserAllergyRepository userAllergyRepository;

    @Autowired
    private AuthService authService;

    @Transactional
    public User registerUser(User user) {
        logger.info("Registering new user: {}", user.getUsername());
        
        // Validate unique constraints
        validateUniqueConstraints(user);
        
        // Create new Regular User
        RegularUser newUser = new RegularUser();
        copyBaseUserProperties(user, newUser);
        
        // Set default values for regular user
        newUser.setMaxSavedRecipes(10);
        newUser.setMaxMealPlans(7);
        newUser.setRole("USER");
        newUser.setUserType(UserType.REGULAR);
        
        return userRepository.save(newUser);
    }

    // Create
    @Transactional
    public User save(User user, String userType) {
        logger.info("Saving new user: {} as {}", user.getUsername(), userType);
        
        // Validate unique constraints
        validateUniqueConstraints(user);
        
        User newUser;
        if ("PREMIUM".equals(userType)) {
            PremiumUser premiumUser = new PremiumUser();
            copyBaseUserProperties(user, premiumUser);
            premiumUser.setSubscriptionEndDate(LocalDateTime.now().plusMonths(1));
            premiumUser.setUnlimitedSavedRecipes(true);
            premiumUser.setUnlimitedMealPlans(true);
            newUser = premiumUser;
        } else {
            RegularUser regularUser = new RegularUser();
            copyBaseUserProperties(user, regularUser);
            regularUser.setMaxSavedRecipes(10);
            regularUser.setMaxMealPlans(7);
            newUser = regularUser;
        }
        
        return userRepository.save(newUser);
    }

    @Transactional
    public UserResponseDto updateUser(Long userId, Map<String, String> userData) {
        try {
            // 1. Fetch existing user
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

            // 2. Update basic info
            if (userData.get("username") != null) user.setUsername(userData.get("username"));
            if (userData.get("email") != null) user.setEmail(userData.get("email"));
            if (userData.get("firstName") != null) user.setFirstName(userData.get("firstName"));
            if (userData.get("lastName") != null) user.setLastName(userData.get("lastName"));

            // 3. Save basic info first
            userRepository.save(user);

            // 4. Update user type if provided
            if (userData.get("userType") != null) {
                String newType = userData.get("userType");
                
                // Update user type
                entityManager.createNativeQuery(
                    "UPDATE users SET user_type = :type WHERE id = :id")
                    .setParameter("type", newType)
                    .setParameter("id", userId)
                    .executeUpdate();

                entityManager.flush();
                entityManager.clear();

                // Update premium features based on user type
                if ("PREMIUM".equals(newType)) {
                    entityManager.createNativeQuery("""
                        UPDATE users 
                        SET has_ai_recommendations = true,
                            has_advanced_analytics = true,
                            unlimited_saved_recipes = true,
                            unlimited_meal_plans = true,
                            subscription_end_date = :endDate,
                            max_saved_recipes = null,
                            max_meal_plans = null
                        WHERE id = :id
                        """)
                        .setParameter("endDate", LocalDateTime.now().plusMonths(1))
                        .setParameter("id", userId)
                        .executeUpdate();
                } else {
                    entityManager.createNativeQuery("""
                        UPDATE users 
                        SET has_ai_recommendations = false,
                            has_advanced_analytics = false,
                            unlimited_saved_recipes = false,
                            unlimited_meal_plans = false,
                            subscription_end_date = null,
                            max_saved_recipes = 10,
                            max_meal_plans = 7
                        WHERE id = :id
                        """)
                        .setParameter("id", userId)
                        .executeUpdate();
                }

                entityManager.flush();
                entityManager.clear();
            }

            // 5. Reload user to get fresh data
            user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

            return convertToDto(user);
        } catch (Exception e) {
            logger.error("Error updating user: ", e);
            throw new RuntimeException("Failed to update user: " + e.getMessage());
        }
    }

    private User convertUserType(User user, UserType newType) {
        entityManager.detach(user);
        User newUser;
        
        if (UserType.PREMIUM.equals(newType)) {
            PremiumUser premiumUser = new PremiumUser();
            // Copy basic properties
            BeanUtils.copyProperties(user, premiumUser);
            // Set premium features
            premiumUser.setUnlimitedSavedRecipes(true);
            premiumUser.setUnlimitedMealPlans(true);
            premiumUser.setSubscriptionEndDate(LocalDateTime.now().plusMonths(1));
            newUser = premiumUser;
        } else {
            RegularUser regularUser = new RegularUser();
            // Copy basic properties
            BeanUtils.copyProperties(user, regularUser);
            // Set regular user limits
            regularUser.setMaxSavedRecipes(10);
            regularUser.setMaxMealPlans(7);
            newUser = regularUser;
        }
        
        return newUser;
    }

    private void copyBaseUserProperties(User source, User target) {
        target.setUsername(source.getUsername());
        target.setEmail(source.getEmail());
        target.setPassword(source.getPassword());
        target.setFirstName(source.getFirstName());
        target.setLastName(source.getLastName());
        target.setBio(source.getBio());
        target.setProfilePictureUrl(source.getProfilePictureUrl());
        target.setCreatedAt(LocalDateTime.now());
        target.setUpdatedAt(LocalDateTime.now());
    }

    // Read methods
    public User findById(Long id) {
        logger.debug("Finding user by ID: {}", id);
        return userRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }

    public User findByUsername(String username) {
        logger.debug("Finding user by username: {}", username);
        return userRepository.findByUsername(username)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with username: " + username));
    }

    public User findByEmail(String email) {
        logger.debug("Finding user by email: {}", email);
        return userRepository.findByEmail(email)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
    }

    public List<UserProfileDto> findAll() {
        logger.debug("Finding all users");
        return userRepository.findAll().stream()
            .map(this::convertToProfileDto)
            .collect(Collectors.toList());
    }

    // Update methods
    @Transactional
    public UserProfileDto upgradeToPremium(Long userId) {
        logger.info("Upgrading user to premium: {}", userId);
        updateUserType(userId, "PREMIUM");
        User user = findById(userId);
        return convertToProfileDto(user);
    }

    @Transactional
    public UserProfileDto downgradeToRegular(Long userId) {
        logger.info("Downgrading user to regular: {}", userId);
        updateUserType(userId, "REGULAR");
        User user = findById(userId);
        return convertToProfileDto(user);
    }

    @Transactional
    public UserProfileDto updateProfile(Long userId, @Valid UserProfileDto profileDto) {
        logger.info("Updating profile for user ID: {}", userId);
        
        User user = findById(userId);
        
        // Validate username uniqueness if changed
        if (!user.getUsername().equals(profileDto.getUsername())) {
            validateUsernameUnique(profileDto.getUsername());
        }
        
        // Validate email uniqueness if changed
        if (!user.getEmail().equals(profileDto.getEmail())) {
            validateEmailUnique(profileDto.getEmail());
        }

        updateUserFields(user, profileDto);
        User updatedUser = userRepository.save(user);
        return convertToProfileDto(updatedUser);
    }

    private void updateUserFields(User user, UserProfileDto profileDto) {
        if (profileDto.getFirstName() != null) user.setFirstName(profileDto.getFirstName());
        if (profileDto.getLastName() != null) user.setLastName(profileDto.getLastName());
        if (profileDto.getUsername() != null) user.setUsername(profileDto.getUsername());
        if (profileDto.getEmail() != null) user.setEmail(profileDto.getEmail());
        if (profileDto.getBio() != null) user.setBio(profileDto.getBio());
        if (profileDto.getProfilePictureUrl() != null) user.setProfilePictureUrl(profileDto.getProfilePictureUrl());
        user.setUpdatedAt(LocalDateTime.now());
    }

    // Delete
    @Transactional
    public void delete(Long id) {
        logger.info("Deleting user with ID: {}", id);
        
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("User not found with id: " + id);
        }
        
        userRepository.deleteById(id);
    }

    @Transactional
    public void deleteUserHealthData(Long userId) {
        User user = findById(userId);
        userHealthDataRepository.deleteByUserId(userId);
    }
    
    public void deleteUserGoals(Long userId) {
        User user = findById(userId);
        userGoalRepository.deleteByUserId(userId);
    }
    
    public void deleteUserAllergies(Long userId) {
        User user = findById(userId);
        userAllergyRepository.deleteByUserId(userId);
    }

    public User getUserById(Long userId) {
        return userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
    }
    
    public void deleteUser(Long userId) {
        User user = getUserById(userId);
        userRepository.delete(user);
    }

    public void changePassword(Long userId, String currentPassword, String newPassword) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
    
        // Verify current password
        if (!user.getPassword().equals(currentPassword)) {
            throw new RuntimeException("Current password is incorrect");
        }
    
        // Validate new password
        if (!authService.isPasswordValid(newPassword)) {
            throw new RuntimeException("New password does not meet security requirements");
        }
    
        // Save new password
        user.setPassword(newPassword);
        userRepository.save(user);
    }

    // Admin methods
    @Transactional
    public UserProfileDto updateUserByAdmin(Long userId, UserProfileDto profileDto) {
        logger.info("Admin updating user: {}", userId);
        User user = findById(userId);
        
        updateUserFields(user, profileDto);
        
        // Handle user type change if specified
        if (profileDto.getUserType() != null) {
            updateUserType(userId, profileDto.getUserType());
        }
        
        User updatedUser = userRepository.save(user);
        return convertToProfileDto(updatedUser);
    }

    // Utility methods
    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    public UserProfileDto getUserProfile(Long userId) {
        logger.debug("Getting profile for user ID: {}", userId);
        return convertToProfileDto(findById(userId));
    }

    @Transactional
    public void updateUserType(Long userId, String newUserType) {
        logger.info("Updating user type for user ID: {} to {}", userId, newUserType);
        
        try {
            // Update discriminator column dengan native query
            int updatedRows = entityManager.createNativeQuery(
                "UPDATE users SET user_type = :newType WHERE id = :userId"
            )
            .setParameter("newType", newUserType)
            .setParameter("userId", userId)
            .executeUpdate();
            
            if (updatedRows == 0) {
                throw new ResourceNotFoundException("User not found with id: " + userId);
            }

            // Clear persistence context
            entityManager.flush();
            entityManager.clear();
            
            // Update user properties based on new type
            User user = findById(userId);
            if ("PREMIUM".equals(newUserType)) {
                user.setSubscriptionEndDate(LocalDateTime.now().plusMonths(1));
                user.setUnlimitedSavedRecipes(true);
                user.setUnlimitedMealPlans(true);
                user.setMaxSavedRecipes(null);
                user.setMaxMealPlans(null);
            } else {
                user.setSubscriptionEndDate(null);
                user.setUnlimitedSavedRecipes(false);
                user.setUnlimitedMealPlans(false);
                user.setMaxSavedRecipes(10);
                user.setMaxMealPlans(7);
            }
            userRepository.save(user);
            
            logger.info("Successfully updated user type for user ID: {}", userId);
        } catch (Exception e) {
            logger.error("Error updating user type: {}", e.getMessage());
            throw new RuntimeException("Failed to update user type: " + e.getMessage());
        }
    }

    // Helper methods
    private UserProfileDto convertToProfileDto(User user) {
        return UserProfileDto.builder()
            .id(user.getId())
            .firstName(user.getFirstName())
            .lastName(user.getLastName())
            .username(user.getUsername())
            .email(user.getEmail())
            .bio(user.getBio())
            .profilePictureUrl(user.getProfilePictureUrl())
            .createdAt(user.getCreatedAt())
            .updatedAt(user.getUpdatedAt())
            .userType(user.getUserType().toString())
            .role(user.getRole())
            .subscriptionEndDate(user.getSubscriptionEndDate())
            .unlimitedSavedRecipes(user.getUnlimitedSavedRecipes())
            .unlimitedMealPlans(user.getUnlimitedMealPlans())
            .maxSavedRecipes(user.getMaxSavedRecipes())
            .maxMealPlans(user.getMaxMealPlans())
            .build();
    }

    private UserResponseDto convertToDto(User user) {
        UserResponseDto dto = new UserResponseDto();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setUserType(user.getUserType());
        dto.setRole(user.getRole());
        return dto;
    }

    private void validateUniqueConstraints(User user) {
        validateUsernameUnique(user.getUsername());
        validateEmailUnique(user.getEmail());
    }

    private void validateUsernameUnique(String username) {
        if (username != null && userRepository.existsByUsername(username)) {
            throw new UserAlreadyExistsException("Username already exists: " + username);
        }
    }

    private void validateEmailUnique(String email) {
        if (email != null && userRepository.existsByEmail(email)) {
            throw new UserAlreadyExistsException("Email already exists: " + email);
        }
    }
}