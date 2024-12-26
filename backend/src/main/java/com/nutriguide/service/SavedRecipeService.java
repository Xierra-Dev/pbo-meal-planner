package com.nutriguide.service;

import com.fasterxml.jackson.databind.ObjectMapper;
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

    @Autowired
    private ObjectMapper objectMapper;

    public List<RecipeDto> getSavedRecipes(Long userId) {
        try {
            System.out.println("Getting saved recipes for user: " + userId);
            
            // Validasi user exists
            if (!userRepository.existsById(userId)) {
                throw new RuntimeException("User not found with id: " + userId);
            }

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
            
            // Validasi user exists
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

            // Cek apakah resep sudah disimpan
            if (savedRecipeRepository.existsByUserIdAndRecipe_ExternalId(userId, recipeId)) {
                throw new RuntimeException("Recipe already saved by this user");
            }

            Recipe recipe = recipeRepository.findByExternalId(recipeId)
                    .orElseGet(() -> {
                        Recipe newRecipe = new Recipe();
                        try {
                            newRecipe.setExternalId(recipeId);
                            newRecipe.setTitle(recipeDto.getTitle());
                            newRecipe.setDescription(recipeDto.getDescription());
                            newRecipe.setThumbnailUrl(recipeDto.getThumbnailUrl());
                            newRecipe.setArea(recipeDto.getArea());
                            newRecipe.setCategory(recipeDto.getCategory());
                            newRecipe.setInstructions(recipeDto.getInstructions());
                            
                            String ingredientsJson = objectMapper.writeValueAsString(
                                recipeDto.getIngredients() != null ? recipeDto.getIngredients() : new ArrayList<>()
                            );
                            String measuresJson = objectMapper.writeValueAsString(
                                recipeDto.getMeasures() != null ? recipeDto.getMeasures() : new ArrayList<>()
                            );
                            
                            newRecipe.setIngredients(ingredientsJson);
                            newRecipe.setMeasures(measuresJson);
                            
                            return recipeRepository.save(newRecipe);
                        } catch (Exception e) {
                            throw new RuntimeException("Failed to create recipe: " + e.getMessage());
                        }
                    });

            SavedRecipe savedRecipe = new SavedRecipe();
            savedRecipe.setUser(user);
            savedRecipe.setRecipe(recipe);
            savedRecipeRepository.save(savedRecipe);

            return convertToDto(recipe);
        } catch (Exception e) {
            System.out.println("Error saving recipe: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to save recipe: " + e.getMessage());
        }
    }

    public void unsaveRecipe(Long userId, String recipeId) {
        try {
            System.out.println("Unsaving recipe: " + recipeId + " for user: " + userId);
            
            // Validasi user exists
            if (!userRepository.existsById(userId)) {
                throw new RuntimeException("User not found with id: " + userId);
            }

            // Validasi recipe exists
            if (!savedRecipeRepository.existsByUserIdAndRecipe_ExternalId(userId, recipeId)) {
                throw new RuntimeException("Recipe not found or not saved by this user");
            }

            savedRecipeRepository.deleteByUserIdAndRecipe_ExternalId(userId, recipeId);
        } catch (Exception e) {
            System.out.println("Error unsaving recipe: " + e.getMessage());
            e.printStackTrace();
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
            
            if (recipe.getIngredients() != null) {
                dto.setIngredients(objectMapper.readValue(recipe.getIngredients(), List.class));
            }
            if (recipe.getMeasures() != null) {
                dto.setMeasures(objectMapper.readValue(recipe.getMeasures(), List.class));
            }
            
            return dto;
        } catch (Exception e) {
            throw new RuntimeException("Error converting recipe to DTO: " + e.getMessage());
        }
    }
}