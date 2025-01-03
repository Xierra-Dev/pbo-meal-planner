package com.nutriguide.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class PlannerDto {
    private Long id;
    private Long userId;
    private Long recipeId;
    private LocalDate plannedDate;
    private boolean completed;
    private RecipeDto recipe;
}