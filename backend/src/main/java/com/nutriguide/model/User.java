package com.nutriguide.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.nutriguide.enums.UserType;
import java.time.LocalDateTime;
import java.util.List;

@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "users")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "user_type", discriminatorType = DiscriminatorType.STRING)
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @Column(name = "profile_picture_url")
    private String profilePictureUrl;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_type", insertable = false, updatable = false)
    private UserType userType;

    // Premium features
    @Column(name = "subscription_end_date")
    private LocalDateTime subscriptionEndDate;



    @Column(name = "unlimited_saved_recipes")
    private Boolean unlimitedSavedRecipes = false;

    @Column(name = "unlimited_meal_plans")
    private Boolean unlimitedMealPlans = false;

    // Regular user limits
    @Column(name = "max_saved_recipes")
    private Integer maxSavedRecipes = 10;

    @Column(name = "max_meal_plans")
    private Integer maxMealPlans = 7;

    // Role for admin functionality
    @Column(nullable = false)
    private String role = "USER";

    @JsonManagedReference
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SavedRecipe> savedRecipes;

    @JsonManagedReference
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Planner> planners;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        
        if (userType == null) {
            userType = UserType.REGULAR;
        }
        
        if (maxSavedRecipes == null) {
            maxSavedRecipes = 10;
        }
        
        if (maxMealPlans == null) {
            maxMealPlans = 7;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and setters for premium features
   

    public Boolean getUnlimitedSavedRecipes() {
        return unlimitedSavedRecipes != null ? unlimitedSavedRecipes : false;
    }

    public Boolean getUnlimitedMealPlans() {
        return unlimitedMealPlans != null ? unlimitedMealPlans : false;
    }

    // Utility methods
    public boolean isPremiumUser() {
        return UserType.PREMIUM.equals(userType);
    }

    public boolean isAdmin() {
        return "ADMIN".equals(role);
    }

    public boolean hasActiveSubscription() {
        if (!isPremiumUser()) return false;
        if (subscriptionEndDate == null) return false;
        return subscriptionEndDate.isAfter(LocalDateTime.now());
    }

    public boolean canAccessPremiumFeature(String featureName) {
        if (!isPremiumUser()) return false;
        if (!hasActiveSubscription()) return false;
        
        return switch (featureName) {
           
            case "UNLIMITED_SAVED_RECIPES" -> getUnlimitedSavedRecipes();
            case "UNLIMITED_MEAL_PLANS" -> getUnlimitedMealPlans();
            default -> false;
        };
    }

    public int getRemainingRecipes() {
        if (getUnlimitedSavedRecipes()) return Integer.MAX_VALUE;
        return maxSavedRecipes;
    }

    public int getRemainingMealPlans() {
        if (getUnlimitedMealPlans()) return Integer.MAX_VALUE;
        return maxMealPlans;
    }
}