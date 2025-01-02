package com.nutriguide.service;

import com.nutriguide.dto.PlannerDto;
import com.nutriguide.dto.RecipeDto;
import com.nutriguide.model.Planner;
import com.nutriguide.model.Recipe;
import com.nutriguide.model.User;
import com.nutriguide.repository.PlannerRepository;
import com.nutriguide.repository.RecipeRepository;
import com.nutriguide.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlannerService {

    @Autowired
    private PlannerRepository plannerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private SavedRecipeService savedRecipeService;

    public PlannerDto addToPlan(Long userId, String recipeId, LocalDate plannedDate, RecipeDto recipeDto) {
        try {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));
    
            Recipe recipe = recipeRepository.findByExternalId(recipeId)
                    .orElseGet(() -> {
                        Recipe newRecipe = new Recipe();
                        newRecipe.setExternalId(recipeId);
                        return newRecipe;
                    });
            
            // Update recipe with all fields
            updateRecipeFromDto(recipe, recipeDto);
            recipe = recipeRepository.save(recipe);
    
            Planner planner = new Planner();
            planner.setUser(user);
            planner.setRecipe(recipe);
            planner.setPlannedDate(plannedDate);
            
            planner = plannerRepository.save(planner);
            
            return convertToDto(planner);
        } catch (Exception e) {
            throw new RuntimeException("Failed to add recipe to plan: " + e.getMessage());
        }
    }

    private void updateRecipeFromDto(Recipe recipe, RecipeDto dto) {
        recipe.setTitle(dto.getTitle() != null ? dto.getTitle() : "");
        recipe.setDescription(dto.getDescription() != null ? dto.getDescription() : "");
        recipe.setThumbnailUrl(dto.getThumbnailUrl() != null ? dto.getThumbnailUrl() : "");
        recipe.setArea(dto.getArea() != null ? dto.getArea() : "");
        recipe.setCategory(dto.getCategory() != null ? dto.getCategory() : "");
        recipe.setInstructions(dto.getInstructions() != null ? dto.getInstructions() : "");
        recipe.setCookingTime(dto.getCookingTime());
        recipe.setHealthScore(dto.getHealthScore());
        
        if (dto.getIngredients() != null && !dto.getIngredients().isEmpty()) {
            recipe.setIngredientsList(dto.getIngredients());
        }
        
        if (dto.getMeasures() != null && !dto.getMeasures().isEmpty()) {
            recipe.setMeasuresList(dto.getMeasures());
        }

        if (dto.getNutritionInfo() != null) {
            recipe.setNutritionInfoMap(dto.getNutritionInfo());
        }
    }

    public List<PlannerDto> getUserPlan(Long userId, LocalDate startDate, LocalDate endDate) {
        try {
            List<Planner> planners = plannerRepository.findByUserIdAndPlannedDateBetween(userId, startDate, endDate);
            
            // Add debug logging
            System.out.println("Found " + planners.size() + " planned items");
            
            return planners.stream()
                    .map(planner -> {
                        PlannerDto dto = new PlannerDto();
                        dto.setId(planner.getId());
                        dto.setUserId(planner.getUser().getId());
                        dto.setRecipeId(Long.parseLong(planner.getRecipe().getExternalId()));
                        dto.setPlannedDate(planner.getPlannedDate());
                        
                        RecipeDto recipeDto = new RecipeDto();
                        Recipe recipe = planner.getRecipe();
                        recipeDto.setId(recipe.getExternalId());
                        recipeDto.setTitle(recipe.getTitle());
                        recipeDto.setDescription(recipe.getDescription());
                        recipeDto.setThumbnailUrl(recipe.getThumbnailUrl());
                        recipeDto.setArea(recipe.getArea());
                        recipeDto.setCategory(recipe.getCategory());
                        recipeDto.setInstructions(recipe.getInstructions());
                        recipeDto.setIngredients(Arrays.asList(recipe.getIngredients().split(","))); // Convert String to List
                        recipeDto.setCookingTime(recipe.getCookingTime());
                        dto.setRecipe(recipeDto);
                        return dto;
                    })
                    .collect(Collectors.toList());
        } catch (Exception e) {
            System.out.println("Error getting user plan: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get user plan: " + e.getMessage());
        }
    }

    public void removePlannerItem(Long plannerId, Long userId) {
        Planner planner = plannerRepository.findById(plannerId)
                .orElseThrow(() -> new RuntimeException("Planner item not found"));
        
        if (!planner.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized access");
        }
        
        plannerRepository.delete(planner);
    }

    public void toggleMealCompletion(Long plannerId, Long userId, boolean completed) {
        Planner planner = plannerRepository.findById(plannerId)
                .orElseThrow(() -> new RuntimeException("Planner item not found"));
                
        if (!planner.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized access");
        }
        
        planner.setCompleted(completed);
        plannerRepository.save(planner);
    }

    private PlannerDto convertToDto(Planner planner) {
        PlannerDto dto = new PlannerDto();
        dto.setId(planner.getId());
        dto.setUserId(planner.getUser().getId());
        dto.setRecipeId(Long.parseLong(planner.getRecipe().getExternalId()));
        dto.setPlannedDate(planner.getPlannedDate());
        
        RecipeDto recipeDto = new RecipeDto();
        Recipe recipe = planner.getRecipe();
        recipeDto.setId(recipe.getExternalId());
        recipeDto.setTitle(recipe.getTitle());
        recipeDto.setDescription(recipe.getDescription());
        recipeDto.setThumbnailUrl(recipe.getThumbnailUrl());
        recipeDto.setArea(recipe.getArea());
        recipeDto.setCategory(recipe.getCategory());
        recipeDto.setInstructions(recipe.getInstructions());
        
        // Tambahkan konversi ingredients dan measures
        recipeDto.setIngredients(recipe.getIngredientsList());
        recipeDto.setMeasures(recipe.getMeasuresList());
        
        dto.setRecipe(recipeDto);
        return dto;
    }
}