package com.nutriguide.model;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@DiscriminatorValue("REGULAR")
public class RegularUser extends User {
    
    @Column(name = "max_saved_recipes")
    private Integer maxSavedRecipes = 10;

    @Column(name = "max_meal_plans")
    private Integer maxMealPlans = 7;
}