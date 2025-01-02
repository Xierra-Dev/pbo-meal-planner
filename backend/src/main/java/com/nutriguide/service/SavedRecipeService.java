package com.nutriguide.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriguide.dto.RecipeDto;
import com.nutriguide.exception.ResourceNotFoundException;
import com.nutriguide.model.Recipe;
import com.nutriguide.model.SavedRecipe;
import com.nutriguide.model.User;
import com.nutriguide.repository.RecipeRepository;
import com.nutriguide.repository.SavedRecipeRepository;
import com.nutriguide.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class SavedRecipeService {
    private static final Logger logger = LoggerFactory.getLogger(SavedRecipeService.class);

    @Autowired
    private SavedRecipeRepository savedRecipeRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Autowired
    private ObjectMapper objectMapper;

    public List<RecipeDto> getSavedRecipes(Long userId) {
        try {
            logger.info("Fetching saved recipes for user ID: {}", userId);

            // Validate user exists and get user object
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

            // Log user role for debugging
            logger.debug("User role: {}", user.getRoleUser());

            // Get saved recipes
            List<SavedRecipe> savedRecipes = savedRecipeRepository.findByUserIdWithRecipe(userId);
            logger.debug("Found {} saved recipes", savedRecipes.size());

            return savedRecipes.stream()
                .map(this::convertSavedRecipeToDto)
                .collect(Collectors.toList());

        } catch (ResourceNotFoundException e) {
            logger.error("User not found error: {}", e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.error("Error getting saved recipes for user {}: {}", userId, e.getMessage(), e);
            throw new RuntimeException("Failed to get saved recipes", e);
        }
    }

    public RecipeDto saveRecipe(Long userId, String recipeId, RecipeDto recipeDto) {
        try {
            logger.info("Saving recipe: {} for user: {}", recipeId, userId);
            
            // Validate user exists and get user object
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

            // Log user role for debugging
            logger.debug("User role: {}", user.getRoleUser());

            if (savedRecipeRepository.existsByUserIdAndRecipe_ExternalId(userId, recipeId)) {
                throw new RuntimeException("Recipe already saved by this user");
            }

            Recipe recipe = recipeRepository.findByExternalId(recipeId)
                .orElseGet(() -> createNewRecipe(recipeId, recipeDto));

            SavedRecipe savedRecipe = new SavedRecipe();
            savedRecipe.setUser(user);
            savedRecipe.setRecipe(recipe);
            savedRecipe.setSavedAt(LocalDateTime.now());
            
            savedRecipeRepository.save(savedRecipe);
            logger.info("Successfully saved recipe {} for user {}", recipeId, userId);

            return convertToDto(recipe);
            
        } catch (ResourceNotFoundException e) {
            logger.error("User not found error: {}", e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.error("Error saving recipe: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to save recipe", e);
        }
    }

    private Recipe createNewRecipe(String recipeId, RecipeDto recipeDto) {
        Recipe newRecipe = new Recipe();
        newRecipe.setExternalId(recipeId);
        newRecipe.setTitle(recipeDto.getTitle());
        newRecipe.setDescription(recipeDto.getDescription());
        newRecipe.setThumbnailUrl(recipeDto.getThumbnailUrl());
        newRecipe.setArea(recipeDto.getArea());
        newRecipe.setCategory(recipeDto.getCategory());
        newRecipe.setInstructions(recipeDto.getInstructions());
        newRecipe.setIngredientsList(recipeDto.getIngredients());
        newRecipe.setMeasuresList(recipeDto.getMeasures());
        
        return recipeRepository.save(newRecipe);
    }

    private RecipeDto convertSavedRecipeToDto(SavedRecipe savedRecipe) {
        Recipe recipe = savedRecipe.getRecipe();
        RecipeDto dto = new RecipeDto();
        dto.setId(recipe.getExternalId());
        dto.setTitle(recipe.getTitle());
        dto.setDescription(recipe.getDescription());
        dto.setThumbnailUrl(recipe.getThumbnailUrl());
        dto.setArea(recipe.getArea());
        dto.setCategory(recipe.getCategory());
        dto.setInstructions(recipe.getInstructions());
        dto.setIngredients(recipe.getIngredientsList());
        dto.setMeasures(recipe.getMeasuresList());
        return dto;
    }

    public void unsaveRecipe(Long userId, String recipeId) {
        try {
            logger.info("Unsaving recipe: {} for user: {}", recipeId, userId);
            
            // Validate user exists
            if (!userRepository.existsById(userId)) {
                throw new ResourceNotFoundException("User not found with id: " + userId);
            }

            // Validate recipe exists and is saved
            if (!savedRecipeRepository.existsByUserIdAndRecipe_ExternalId(userId, recipeId)) {
                throw new ResourceNotFoundException("Recipe not found or not saved by this user");
            }

            savedRecipeRepository.deleteByUserIdAndRecipe_ExternalId(userId, recipeId);
            logger.info("Successfully unsaved recipe: {} for user: {}", recipeId, userId);
        } catch (Exception e) {
            logger.error("Error unsaving recipe: {}", e.getMessage());
            throw new RuntimeException("Failed to unsave recipe: " + e.getMessage());
        }
    }

    private RecipeDto convertToDto(Recipe recipe) {
        try {
            RecipeDto dto = new RecipeDto();
            dto.setId(recipe.getExternalId());
            dto.setTitle(recipe.getTitle());
            dto.setDescription(recipe.getDescription());
            dto.setThumbnailUrl(recipe.getThumbnailUrl());
            dto.setArea(recipe.getArea());
            dto.setCategory(recipe.getCategory());
            dto.setInstructions(recipe.getInstructions());
            
            // Use helper methods for conversion
            dto.setIngredients(recipe.getIngredientsList());
            dto.setMeasures(recipe.getMeasuresList());
            
            return dto;
        } catch (Exception e) {
            logger.error("Error converting recipe to DTO: {}", e.getMessage());
            throw new RuntimeException("Error converting recipe to DTO: " + e.getMessage());
        }
    }
}