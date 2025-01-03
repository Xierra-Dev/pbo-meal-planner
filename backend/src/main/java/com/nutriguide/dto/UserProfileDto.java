package com.nutriguide.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDto {
    private Long id;

    private String role;

    @Size(min = 1, max = 100, message = "First name must be between 1 and 100 characters")
    private String firstName;

    @Size(min = 1, max = 100, message = "Last name must be between 1 and 100 characters")
    private String lastName;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @Email(message = "Invalid email format")
    private String email;

    @Size(max = 255, message = "Bio cannot exceed 255 characters")
    private String bio;

    private String profilePictureUrl;

    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;

    private String userType; // "REGULAR" or "PREMIUM"

    // Fields for Premium Users
    private LocalDateTime subscriptionEndDate;
    private Boolean hasAiRecommendations;
    private Boolean hasAdvancedAnalytics;
    private Boolean unlimitedSavedRecipes;
    private Boolean unlimitedMealPlans;

    // Fields for Regular Users
    private Integer maxSavedRecipes;
    private Integer maxMealPlans;

    // Custom method untuk generate profile URL
    public String getProfileUrl() {
        return String.format("https://app.nutriguide.com/u/%s", username);
    }

    // Method untuk memformat nama lengkap
    public String getFullName() {
        if (firstName == null && lastName == null) {
            return username;
        }
        
        StringBuilder fullName = new StringBuilder();
        if (firstName != null) {
            fullName.append(firstName);
        }
        if (lastName != null) {
            if (fullName.length() > 0) {
                fullName.append(" ");
            }
            fullName.append(lastName);
        }
        return fullName.toString();
    }

    // Method untuk memvalidasi profile picture URL
    public boolean hasValidProfilePicture() {
        return profilePictureUrl != null && !profilePictureUrl.trim().isEmpty();
    }

    // Method untuk mendapatkan default profile picture jika tidak ada
    public String getProfilePicture() {
        return hasValidProfilePicture() 
            ? profilePictureUrl 
            : "https://app.nutriguide.com/assets/default-profile.png";
    }

    // Method untuk mengecek apakah profile sudah lengkap
    public boolean isProfileComplete() {
        return firstName != null && !firstName.trim().isEmpty()
            && lastName != null && !lastName.trim().isEmpty()
            && bio != null && !bio.trim().isEmpty()
            && hasValidProfilePicture();
    }

    // Method untuk mendapatkan completion percentage
    public int getProfileCompletionPercentage() {
        int total = 0;
        int completed = 0;

        // Check first name
        total++;
        if (firstName != null && !firstName.trim().isEmpty()) completed++;

        // Check last name
        total++;
        if (lastName != null && !lastName.trim().isEmpty()) completed++;

        // Check bio
        total++;
        if (bio != null && !bio.trim().isEmpty()) completed++;

        // Check profile picture
        total++;
        if (hasValidProfilePicture()) completed++;

        return (completed * 100) / total;
    }

    // Method untuk mengecek apakah user adalah Premium
    public boolean isPremiumUser() {
        return "PREMIUM".equals(userType);
    }

    // Method untuk mengecek status subscription Premium
    public boolean hasActiveSubscription() {
        if (!isPremiumUser()) return false;
        return subscriptionEndDate != null && subscriptionEndDate.isAfter(LocalDateTime.now());
    }

    // Method untuk mendapatkan sisa hari subscription
    public long getRemainingSubscriptionDays() {
        if (!isPremiumUser() || subscriptionEndDate == null) return 0;
        return java.time.Duration.between(LocalDateTime.now(), subscriptionEndDate).toDays();
    }

    // Method untuk mendapatkan jumlah resep yang bisa disimpan
    public int getMaxSavedRecipesLimit() {
        if (isPremiumUser() && Boolean.TRUE.equals(unlimitedSavedRecipes)) {
            return Integer.MAX_VALUE;
        }
        return maxSavedRecipes != null ? maxSavedRecipes : 10;
    }

    // Method untuk mendapatkan jumlah meal plan yang bisa dibuat
    public int getMaxMealPlansLimit() {
        if (isPremiumUser() && Boolean.TRUE.equals(unlimitedMealPlans)) {
            return Integer.MAX_VALUE;
        }
        return maxMealPlans != null ? maxMealPlans : 7;
    }

    // Static factory method untuk membuat instance dari minimal data
    public static UserProfileDto createMinimal(String username, String email, String userType) {
        return UserProfileDto.builder()
            .username(username)
            .email(email)
            .userType(userType)
            .createdAt(LocalDateTime.now())
            .updatedAt(LocalDateTime.now())
            .maxSavedRecipes("REGULAR".equals(userType) ? 10 : null)
            .maxMealPlans("REGULAR".equals(userType) ? 7 : null)
            .hasAiRecommendations("PREMIUM".equals(userType))
            .hasAdvancedAnalytics("PREMIUM".equals(userType))
            .unlimitedSavedRecipes("PREMIUM".equals(userType))
            .unlimitedMealPlans("PREMIUM".equals(userType))
            .build();
    }

    // Method untuk sanitize data sebelum save
    public void sanitize() {
        if (firstName != null) firstName = firstName.trim();
        if (lastName != null) lastName = lastName.trim();
        if (username != null) username = username.trim().toLowerCase();
        if (email != null) email = email.trim().toLowerCase();
        if (bio != null) bio = bio.trim();
        if (userType != null) userType = userType.toUpperCase();
    }

    // Method untuk memvalidasi user type
    public boolean isValidUserType() {
        return "REGULAR".equals(userType) || "PREMIUM".equals(userType);
    }

    // Method untuk mengecek fitur Premium
    public boolean canAccessPremiumFeature(String featureName) {
        if (!isPremiumUser()) return false;
        if (!hasActiveSubscription()) return false;
        
        return switch (featureName) {
            case "AI_RECOMMENDATIONS" -> Boolean.TRUE.equals(hasAiRecommendations);
            case "ADVANCED_ANALYTICS" -> Boolean.TRUE.equals(hasAdvancedAnalytics);
            case "UNLIMITED_RECIPES" -> Boolean.TRUE.equals(unlimitedSavedRecipes);
            case "UNLIMITED_MEAL_PLANS" -> Boolean.TRUE.equals(unlimitedMealPlans);
            default -> false;
        };
    }
}