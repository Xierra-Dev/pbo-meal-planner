package com.nutriguide.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecipeDto {
    private String id;
    private String externalId;
    private String title;
    private String description;
    private String thumbnailUrl;
    private String area;
    private String category;
    private String instructions;
    private Integer cookingTime;
    private List<String> ingredients;
    private List<String> measures;
}