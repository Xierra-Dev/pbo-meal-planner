package com.nutriguide.controller;

import com.nutriguide.dto.ErrorResponse;
import com.nutriguide.dto.RecipeDto;
import com.nutriguide.service.SavedRecipeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/saved-recipes")
@CrossOrigin(origins = "*")
public class SavedRecipeController {

    @Autowired
    private SavedRecipeService savedRecipeService;

    @PostMapping("/{recipeId}")
    public ResponseEntity<?> saveRecipe(
            @RequestParam Long userId,
            @PathVariable String recipeId,
            @RequestBody RecipeDto recipeDto) {
        try {
            System.out.println("Controller - Saving recipe: " + recipeId + " for user: " + userId);
            System.out.println("Controller - Recipe data: " + recipeDto);
            
            if (recipeDto == null || recipeDto.getTitle() == null) {
                return ResponseEntity.badRequest().body(new ErrorResponse(false, "Invalid recipe data"));
            }
            
            RecipeDto saved = savedRecipeService.saveRecipe(userId, recipeId, recipeDto);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Controller Error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse(false, e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<?> getSavedRecipes(@RequestParam Long userId) {
        try {
            System.out.println("Controller - Getting saved recipes for user: " + userId);
            List<RecipeDto> recipes = savedRecipeService.getSavedRecipes(userId);
            return ResponseEntity.ok(recipes);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Controller Error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse(false, e.getMessage()));
        }
    }

    @DeleteMapping("/{recipeId}")
    public ResponseEntity<?> unsaveRecipe(
            @RequestParam Long userId,
            @PathVariable String recipeId) {
        try {
            System.out.println("Controller - Unsaving recipe: " + recipeId + " for user: " + userId);
            savedRecipeService.unsaveRecipe(userId, recipeId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Controller Error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse(false, e.getMessage()));
        }
    }
}