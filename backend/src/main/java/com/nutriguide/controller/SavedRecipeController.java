package com.nutriguide.controller;

import com.nutriguide.dto.ApiResponse;
import com.nutriguide.dto.ErrorResponse;
import com.nutriguide.dto.RecipeDto;
import com.nutriguide.dto.SavedRecipeRequest;
import com.nutriguide.exception.ResourceNotFoundException;
import com.nutriguide.service.SavedRecipeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


// SavedRecipeController.java
@RestController
@RequestMapping("/api/saved-recipes") // Tambahkan prefix /api
@CrossOrigin(origins = "*")     
public class SavedRecipeController {
    private static final Logger logger = LoggerFactory.getLogger(SavedRecipeController.class);

    @Autowired
    private SavedRecipeService savedRecipeService;

    @GetMapping
    public ResponseEntity<?> getSavedRecipes(@RequestParam Long userId) {
        try {
            logger.info("Getting saved recipes for user: {}", userId);
            List<RecipeDto> recipes = savedRecipeService.getSavedRecipes(userId);
            return ResponseEntity.ok(new ApiResponse<>(true, "Recipes retrieved successfully", recipes));
        } catch (ResourceNotFoundException e) {
            logger.error("User not found: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ApiResponse<>(false, e.getMessage()));
        } catch (Exception e) {
            logger.error("Error getting saved recipes: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Failed to get saved recipes", e.getMessage()));
        }
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveRecipe(@RequestBody SavedRecipeRequest request) {
        try {
            logger.info("Saving recipe: {} for user: {}", request.getRecipeId(), request.getUserId());
            RecipeDto saved = savedRecipeService.saveRecipe(request.getUserId(), request.getRecipeId(), request.getRecipeDto());
            return ResponseEntity.ok(new ApiResponse<>(true, "Recipe saved successfully", saved));
        } catch (ResourceNotFoundException e) {
            logger.error("User not found: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ApiResponse<>(false, e.getMessage()));
        } catch (Exception e) {
            logger.error("Error saving recipe: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Failed to save recipe", e.getMessage()));
        }
    }

    @DeleteMapping("/unsave")  // Changed endpoint
    public ResponseEntity<?> unsaveRecipe(
        @RequestParam Long userId,
        @RequestParam String recipeId) {
        try {
            logger.info("Unsaving recipe: {} for user: {}", recipeId, userId);
            savedRecipeService.unsaveRecipe(userId, recipeId);
            return ResponseEntity.ok(new ApiResponse<>(true, "Recipe unsaved successfully"));
        } catch (Exception e) {
            logger.error("Error unsaving recipe: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Failed to unsave recipe", e.getMessage()));
        }
    }
}