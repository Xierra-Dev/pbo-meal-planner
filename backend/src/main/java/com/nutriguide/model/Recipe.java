package com.nutriguide.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recipes")
@Data
@NoArgsConstructor
public class Recipe {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String externalId;

    @Column(nullable = false)
    private String title = "";

    @Column(columnDefinition = "TEXT")
    private String description = "";

    @Column(nullable = false)
    private String thumbnailUrl = "";

    @Column
    private String area = "";

    @Column
    private String category = "";

    @Column(columnDefinition = "TEXT")
    private String instructions = "";

    @Column(columnDefinition = "TEXT")
    private String ingredients = "";

    @Column(columnDefinition = "TEXT")
    private String measures = "";

    @Column
    private Integer cookingTime;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<SavedRecipe> savedRecipes = new ArrayList<>();

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Planner> planners = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        
        // Set default values for required fields if null
        if (title == null) title = "";
        if (thumbnailUrl == null) thumbnailUrl = "";
        if (description == null) description = "";
        if (area == null) area = "";
        if (category == null) category = "";
        if (instructions == null) instructions = "";
        if (ingredients == null) ingredients = "";
        if (measures == null) measures = "";
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Helper methods for managing relationships
    public void addSavedRecipe(SavedRecipe savedRecipe) {
        savedRecipes.add(savedRecipe);
        savedRecipe.setRecipe(this);
    }

    public void removeSavedRecipe(SavedRecipe savedRecipe) {
        savedRecipes.remove(savedRecipe);
        savedRecipe.setRecipe(null);
    }

    public void addPlanner(Planner planner) {
        planners.add(planner);
        planner.setRecipe(this);
    }

    public void removePlanner(Planner planner) {
        planners.remove(planner);
        planner.setRecipe(null);
    }

    // Convert List<String> to comma-separated String
    public void setIngredientsList(List<String> ingredientsList) {
        this.ingredients = ingredientsList != null ? String.join(",", ingredientsList) : "";
    }

    // Convert comma-separated String to List<String>
    public List<String> getIngredientsList() {
        return ingredients != null && !ingredients.isEmpty() 
            ? List.of(ingredients.split(",")) 
            : new ArrayList<>();
    }

    // Convert List<String> to comma-separated String
    public void setMeasuresList(List<String> measuresList) {
        this.measures = measuresList != null ? String.join(",", measuresList) : "";
    }

    // Convert comma-separated String to List<String>
    public List<String> getMeasuresList() {
        return measures != null && !measures.isEmpty() 
            ? List.of(measures.split(",")) 
            : new ArrayList<>();
    }
}