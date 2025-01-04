package com.nutriguide.model;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@DiscriminatorValue("PREMIUM")
public class PremiumUser extends User {
    
    @Column(name = "subscription_end_date")
    private LocalDateTime subscriptionEndDate;

    

    @Column(name = "unlimited_saved_recipes")
    private Boolean unlimitedSavedRecipes = true;

    @Column(name = "unlimited_meal_plans")
    private Boolean unlimitedMealPlans = true;
}