package com.nutriguide.service;

import com.nutriguide.dto.RecipeDto;
import com.nutriguide.model.Recipe;
import com.nutriguide.repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class RecipeService {

    @Autowired
    private RecipeRepository recipeRepository;

    public RecipeDto createRecipe(Recipe recipe) {
        Recipe savedRecipe = recipeRepository.save(recipe);
        return convertToDto(savedRecipe);
    }

    public List<RecipeDto> getAllRecipes() {
        return recipeRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public RecipeDto getRecipeById(Long id) {
        Recipe recipe = recipeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Recipe not found"));
        return convertToDto(recipe);
    }

    public List<RecipeDto> searchRecipes(String query) {
        return recipeRepository.findByTitleContainingIgnoreCase(query).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public List<RecipeDto> getRecipesByCategory(String category) {
        return recipeRepository.findByCategory(category).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private RecipeDto convertToDto(Recipe recipe) {
        RecipeDto dto = new RecipeDto();
        dto.setId(recipe.getId().toString());
        dto.setTitle(recipe.getTitle());
        dto.setCategory(recipe.getCategory());
        dto.setInstructions(recipe.getInstructions());
        dto.setThumbnailUrl(recipe.getThumbnailUrl());
        return dto;
    }
}