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

    public PlannerDto addToPlan(Long userId, String recipeId, LocalDate plannedDate, RecipeDto recipeDto) {
        try {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));
    
            // Save or update recipe
            Recipe recipe = recipeRepository.findByExternalId(recipeId)
                    .orElseGet(() -> {
                        Recipe newRecipe = new Recipe();
                        newRecipe.setExternalId(recipeId);
                        return newRecipe;
                    });
            
            // Update recipe details
            recipe.setTitle(recipeDto.getTitle() != null ? recipeDto.getTitle() : "");
            recipe.setDescription(recipeDto.getDescription() != null ? recipeDto.getDescription() : "");
            recipe.setThumbnailUrl(recipeDto.getThumbnailUrl() != null ? recipeDto.getThumbnailUrl() : "");
            recipe.setArea(recipeDto.getArea() != null ? recipeDto.getArea() : "");
            recipe.setCategory(recipeDto.getCategory() != null ? recipeDto.getCategory() : "");
            recipe.setInstructions(recipeDto.getInstructions() != null ? recipeDto.getInstructions() : "");
            
            if (recipeDto.getIngredients() != null && !recipeDto.getIngredients().isEmpty()) {
                recipe.setIngredientsList(recipeDto.getIngredients());
            }
            
            if (recipeDto.getMeasures() != null && !recipeDto.getMeasures().isEmpty()) {
                recipe.setMeasuresList(recipeDto.getMeasures());
            }
            
            recipe.setCookingTime(recipeDto.getCookingTime());
            
            System.out.println("Saving recipe with title: " + recipe.getTitle());
            recipe = recipeRepository.save(recipe);
    
            Planner planner = new Planner();
            planner.setUser(user);
            planner.setRecipe(recipe);
            planner.setPlannedDate(plannedDate);
            
            planner = plannerRepository.save(planner);
            
            return convertToDto(planner);
        } catch (Exception e) {
            System.out.println("Error adding to plan: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to add recipe to plan: " + e.getMessage());
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