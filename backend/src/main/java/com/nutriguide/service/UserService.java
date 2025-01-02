package com.nutriguide.service;

import com.nutriguide.dto.UserProfileDto;
import com.nutriguide.model.User;
import com.nutriguide.exception.ResourceNotFoundException;
import com.nutriguide.exception.UserAlreadyExistsException;
import com.nutriguide.repository.UserRepository;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Validated
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    @Autowired
    private UserRepository userRepository;

    // Create
    @Transactional
    public User save(User user) {
        logger.info("Saving new user: {}", user.getUsername());
        
        // Validate unique constraints
        validateUniqueConstraints(user);
        
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        return userRepository.save(user);
    }

    // Read
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

    // Update
    @Transactional
    public UserProfileDto updateProfile(Long userId, @Valid UserProfileDto profileDto) {
        User existingUser = findById(userId);
        
        // Validate username uniqueness only if username is being changed
        if (profileDto.getUsername() != null && 
            !profileDto.getUsername().equals(existingUser.getUsername())) {
            // Check if username exists for ANY OTHER user
            boolean usernameExists = userRepository.findByUsername(profileDto.getUsername())
                .map(u -> !u.getId().equals(userId))
                .orElse(false);
            
            if (usernameExists) {
                throw new UserAlreadyExistsException("Username already exists: " + profileDto.getUsername());
            }
        }
        
        // Update fields only if they are provided in the request
        if (profileDto.getUsername() != null && !profileDto.getUsername().trim().isEmpty()) {
            existingUser.setUsername(profileDto.getUsername().trim());
        }
        if (profileDto.getFirstName() != null) {
            existingUser.setFirstName(profileDto.getFirstName().trim());
        }
        if (profileDto.getLastName() != null) {
            existingUser.setLastName(profileDto.getLastName().trim());
        }
        if (profileDto.getBio() != null) {
            existingUser.setBio(profileDto.getBio().trim());
        }
        
        existingUser.setUpdatedAt(LocalDateTime.now());
        User updatedUser = userRepository.save(existingUser);
        return convertToProfileDto(updatedUser);
    }

    // Update the validation method
    private void validateUsernameUnique(String username) {
        if (username == null) {
            return;
        }
        // Use case-insensitive comparison
        boolean exists = userRepository.findByUsername(username)
            .isPresent();
        if (exists) {
            throw new UserAlreadyExistsException("Username already exists: " + username);
        }
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
            .build();
    }

    private void validateUniqueConstraints(User user) {
        validateUsernameUnique(user.getUsername());
        validateEmailUnique(user.getEmail());
    }

    private void validateEmailUnique(String email) {
        if (email != null && userRepository.existsByEmail(email)) {
            throw new UserAlreadyExistsException("Email already exists: " + email);
        }
    }
    
}