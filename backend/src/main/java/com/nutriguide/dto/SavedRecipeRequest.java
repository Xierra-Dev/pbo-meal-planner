package com.nutriguide.dto;

import lombok.Data;

@Data
public class SavedRecipeRequest {
    private Long userId;
    private String recipeId;
    private RecipeDto recipeDto;
}