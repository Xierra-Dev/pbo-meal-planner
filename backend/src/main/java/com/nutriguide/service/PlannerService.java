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
    
            // Save or update recipe
            Recipe recipe = recipeRepository.findByExternalId(recipeId)
                    .orElseGet(() -> {
                        Recipe newRecipe = new Recipe();
                        newRecipe.setExternalId(recipeId);
                        return newRecipe;
                    });
            
            // Update recipe details
            recipe.setTitle(recipeDto.getTitle());
            recipe.setDescription(recipeDto.getDescription());
            recipe.setThumbnailUrl(recipeDto.getThumbnailUrl());
            recipe.setArea(recipeDto.getArea());
            recipe.setCategory(recipeDto.getCategory());
            recipe.setInstructions(recipeDto.getInstructions());
            
            // Handle null ingredients
            List<String> ingredients = recipeDto.getIngredients();
            recipe.setIngredients(ingredients != null ? String.join(",", ingredients) : "");
            
            recipe.setCookingTime(recipeDto.getCookingTime());
            recipe = recipeRepository.save(recipe);
    
            // Create planner entry
            Planner planner = new Planner();
            planner.setUser(user);
            planner.setRecipe(recipe);
            planner.setPlannedDate(plannedDate);
            
            planner = plannerRepository.save(planner);
            
            return convertToDto(planner);
        } catch (Exception e) {
            System.out.println("Error in addToPlan: " + e.getMessage());
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
        
        dto.setRecipe(recipeDto);
        return dto;
    }
}