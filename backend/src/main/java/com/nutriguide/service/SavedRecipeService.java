package com.nutriguide.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.nutriguide.dto.RecipeDto;
import com.nutriguide.model.Recipe;
import com.nutriguide.model.SavedRecipe;
import com.nutriguide.model.User;
import com.nutriguide.repository.RecipeRepository;
import com.nutriguide.repository.SavedRecipeRepository;
import com.nutriguide.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class SavedRecipeService {

    @Autowired
    private SavedRecipeRepository savedRecipeRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<RecipeDto> getSavedRecipes(Long userId) {
        try {
            System.out.println("Getting saved recipes for user: " + userId);
            List<SavedRecipe> savedRecipes = savedRecipeRepository.findByUserIdWithRecipe(userId);
            return savedRecipes.stream()
                    .map(savedRecipe -> convertToDto(savedRecipe.getRecipe()))
                    .collect(Collectors.toList());
        } catch (Exception e) {
            System.out.println("Error getting saved recipes: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get saved recipes: " + e.getMessage());
        }
    }

    public RecipeDto saveRecipe(Long userId, String recipeId, RecipeDto recipeDto) {
        try {
            System.out.println("Saving recipe: " + recipeId + " for user: " + userId);
            System.out.println("Recipe data: " + recipeDto);

            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

            Recipe recipe = recipeRepository.findByExternalId(recipeId)
                    .orElseGet(() -> {
                        Recipe newRecipe = new Recipe();
                        newRecipe.setExternalId(recipeId);
                        newRecipe.setTitle(recipeDto.getTitle());
                        newRecipe.setDescription(recipeDto.getDescription());
                        newRecipe.setThumbnailUrl(recipeDto.getThumbnailUrl());
                        newRecipe.setArea(recipeDto.getArea());
                        newRecipe.setCategory(recipeDto.getCategory());
                        newRecipe.setInstructions(recipeDto.getInstructions());
                        
                        try {
                            newRecipe.setIngredients(objectMapper.writeValueAsString(recipeDto.getIngredients()));
                            newRecipe.setMeasures(objectMapper.writeValueAsString(recipeDto.getMeasures()));
                        } catch (Exception e) {
                            newRecipe.setIngredients("[]");
                            newRecipe.setMeasures("[]");
                        }
                        
                        return recipeRepository.save(newRecipe);
                    });

            if (!savedRecipeRepository.existsByUserIdAndRecipe_Id(userId, recipe.getId())) {
                SavedRecipe savedRecipe = new SavedRecipe();
                savedRecipe.setUser(user);
                savedRecipe.setRecipe(recipe);
                savedRecipeRepository.save(savedRecipe);
                System.out.println("Recipe saved successfully");
            } else {
                System.out.println("Recipe already saved for this user");
            }

            return convertToDto(recipe);
        } catch (Exception e) {
            System.out.println("Save recipe error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to save recipe: " + e.getMessage());
        }
    }

    public void unsaveRecipe(Long userId, String recipeId) {
        try {
            System.out.println("Unsaving recipe: " + recipeId + " for user: " + userId);
            Recipe recipe = recipeRepository.findByExternalId(recipeId)
                    .orElseThrow(() -> new RuntimeException("Recipe not found with id: " + recipeId));

            savedRecipeRepository.deleteByUserIdAndRecipe_Id(userId, recipe.getId());
            System.out.println("Recipe unsaved successfully");
        } catch (Exception e) {
            System.out.println("Unsave recipe error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to unsave recipe: " + e.getMessage());
        }
    }

    private RecipeDto convertToDto(Recipe recipe) {
        RecipeDto dto = new RecipeDto();
        dto.setId(recipe.getExternalId());
        dto.setExternalId(recipe.getExternalId());
        dto.setTitle(recipe.getTitle());
        dto.setDescription(recipe.getDescription());
        dto.setThumbnailUrl(recipe.getThumbnailUrl());
        dto.setArea(recipe.getArea());
        dto.setCategory(recipe.getCategory());
        dto.setInstructions(recipe.getInstructions());
        
        try {
            dto.setIngredients(objectMapper.readValue(recipe.getIngredients(), new TypeReference<List<String>>(){}));
            dto.setMeasures(objectMapper.readValue(recipe.getMeasures(), new TypeReference<List<String>>(){}));
        } catch (Exception e) {
            dto.setIngredients(new ArrayList<>());
            dto.setMeasures(new ArrayList<>());
        }
        
        return dto;
    }
}