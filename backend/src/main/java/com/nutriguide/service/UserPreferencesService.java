package com.nutriguide.service;

import com.nutriguide.dto.UserPreferencesDto;
import com.nutriguide.dto.UserHealthDataDto;
import com.nutriguide.model.User;
import com.nutriguide.model.UserHealthData;
import com.nutriguide.model.UserGoal;
import com.nutriguide.model.UserAllergy;
import com.nutriguide.repository.UserRepository;
import com.nutriguide.repository.UserHealthDataRepository;
import com.nutriguide.repository.UserGoalRepository;
import com.nutriguide.repository.UserAllergyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserPreferencesService {
    private final UserRepository userRepository;
    private final UserHealthDataRepository healthDataRepository;
    private final UserGoalRepository goalRepository;
    private final UserAllergyRepository allergyRepository;

    @Transactional
    public void saveUserPreferences(Long userId, UserPreferencesDto preferencesDto) {
        log.info("Starting to save preferences for user {} with data: {}", userId, preferencesDto);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        // Save health data
        if (preferencesDto.getHealthData() != null) {
            log.info("Health data is not null, proceeding to save"); // Tambahkan ini
            try {
                saveHealthData(user, preferencesDto.getHealthData());
            } catch (Exception e) {
                log.error("Error saving health data: {}", e.getMessage(), e);
                throw new RuntimeException("Failed to save health data", e);
            }
        } else {
            log.warn("Health data is null, skipping save"); // Tambahkan ini
        }

        // Save goals if present
        if (preferencesDto.getGoals() != null && !preferencesDto.getGoals().isEmpty()) {
            try {
                saveGoals(user, preferencesDto.getGoals());
            } catch (Exception e) {
                log.error("Error saving goals for user {}: {}", userId, e.getMessage());
                throw new RuntimeException("Failed to save goals", e);
            }
        }

        // Save allergies if present
        if (preferencesDto.getAllergies() != null && !preferencesDto.getAllergies().isEmpty()) {
            try {
                saveAllergies(user, preferencesDto.getAllergies());
            } catch (Exception e) {
                log.error("Error saving allergies for user {}: {}", userId, e.getMessage());
                throw new RuntimeException("Failed to save allergies", e);
            }
        }
        
        log.info("Successfully saved all preferences for user {}", userId);
    }

    @Transactional
    private void saveHealthData(User user, UserHealthDataDto healthDataDto) {
        log.info("Saving health data for user {}: {}", user.getId(), healthDataDto);
        
        try {
            // Delete existing data
            healthDataRepository.deleteByUserId(user.getId());
            
            // Create new health data
            UserHealthData healthData = UserHealthData.builder()
                .user(user)
                .sex(healthDataDto.getSex())
                .birthYear(healthDataDto.getBirthYear())
                .height(healthDataDto.getHeight())
                .weight(healthDataDto.getWeight())
                .activityLevel(healthDataDto.getActivityLevel())
                .build();

            // Set timestamps
            healthData.setCreatedAt(LocalDateTime.now());
            healthData.setUpdatedAt(LocalDateTime.now());
            
            log.info("Saving health data entity: {}", healthData);
            UserHealthData savedData = healthDataRepository.saveAndFlush(healthData);
            log.info("Health data saved with ID: {}", savedData.getId());
        } catch (Exception e) {
            log.error("Error in saveHealthData: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to save health data", e);
        }
    }

    @Transactional
    private void saveGoals(User user, List<String> goals) {
        log.info("Saving goals for user {}: {}", user.getId(), goals);
        
        try {
            // Delete existing goals
            goalRepository.deleteByUserId(user.getId());
            
            if (!goals.isEmpty()) {
                List<UserGoal> userGoals = goals.stream()
                    .map(goal -> UserGoal.builder()
                        .user(user)
                        .goalName(goal)
                        .build())
                    .collect(Collectors.toList());
                    
                List<UserGoal> savedGoals = goalRepository.saveAll(userGoals);
                log.info("Saved {} goals for user {}", savedGoals.size(), user.getId());
            }
        } catch (Exception e) {
            log.error("Error in saveGoals: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to save goals", e);
        }
    }

    @Transactional
    private void saveAllergies(User user, List<String> allergies) {
        log.info("Saving allergies for user {}: {}", user.getId(), allergies);
        
        try {
            // Delete existing allergies
            allergyRepository.deleteByUserId(user.getId());
            
            if (!allergies.isEmpty()) {
                List<UserAllergy> userAllergies = allergies.stream()
                    .map(allergy -> UserAllergy.builder()
                        .user(user)
                        .allergyName(allergy)
                        .build())
                    .collect(Collectors.toList());
                    
                List<UserAllergy> savedAllergies = allergyRepository.saveAll(userAllergies);
                log.info("Saved {} allergies for user {}", savedAllergies.size(), user.getId());
            }
        } catch (Exception e) {
            log.error("Error in saveAllergies: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to save allergies", e);
        }
    }

    public UserPreferencesDto getUserPreferences(Long userId) {
        log.info("Fetching preferences for user {}", userId);
        
        try {
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

            // Get health data with explicit logging
            UserHealthData healthData = healthDataRepository.findByUserId(userId)
                .orElse(null);
            log.info("Retrieved health data for user {}: {}", userId, healthData);

            // Get goals
            List<String> goals = goalRepository.findByUserId(userId).stream()
                .map(UserGoal::getGoalName)
                .collect(Collectors.toList());
            log.info("Retrieved goals for user {}: {}", userId, goals);

            // Get allergies
            List<String> allergies = allergyRepository.findByUserId(userId).stream()
                .map(UserAllergy::getAllergyName)
                .collect(Collectors.toList());
            log.info("Retrieved allergies for user {}: {}", userId, allergies);

            UserPreferencesDto preferences = UserPreferencesDto.builder()
                .healthData(healthData != null ? mapToHealthDataDto(healthData) : null)
                .goals(goals)
                .allergies(allergies)
                .build();
                
            log.info("Built preferences DTO: {}", preferences);
            return preferences;
        } catch (Exception e) {
            log.error("Error getting preferences for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to get user preferences", e);
        }
    }

    private UserHealthDataDto mapToHealthDataDto(UserHealthData healthData) {
        return UserHealthDataDto.builder()
            .sex(healthData.getSex())
            .birthYear(healthData.getBirthYear())
            .height(healthData.getHeight())
            .weight(healthData.getWeight())
            .activityLevel(healthData.getActivityLevel())
            .build();
    }
}