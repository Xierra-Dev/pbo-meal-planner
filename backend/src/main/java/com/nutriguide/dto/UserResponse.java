package com.nutriguide.dto;

import com.nutriguide.enums.UserType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String bio;
    private String profilePictureUrl;
    private UserType userType;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Additional fields for different user types
    private Integer maxSavedRecipes;
    private Integer maxMealPlans;
    private LocalDateTime subscriptionEndDate;
    private Boolean hasAiRecommendations;
    private Boolean hasAdvancedAnalytics;
    private Boolean unlimitedSavedRecipes;
    private Boolean unlimitedMealPlans;
}