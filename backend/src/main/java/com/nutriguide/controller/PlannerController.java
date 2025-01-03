package com.nutriguide.controller;

import com.nutriguide.dto.ApiResponse;
import com.nutriguide.dto.PlannerDto;
import com.nutriguide.dto.RecipeDto;
import com.nutriguide.service.PlannerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/planner")
@CrossOrigin(origins = "*")
public class PlannerController {

    @Autowired
    private PlannerService plannerService;

    @PostMapping
    public ResponseEntity<?> addToPlan(
            @RequestParam Long userId,
            @RequestParam String recipeId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate plannedDate,
            @RequestBody Map<String, Object> body
    ) {
        try {
            System.out.println("Received request body: " + body);
            Map<String, Object> recipeData = (Map<String, Object>) body.get("recipe");
            RecipeDto recipeDto = convertMapToRecipeDto(recipeData);
            
            System.out.println("Converted RecipeDto: " + recipeDto);
            
            PlannerDto planner = plannerService.addToPlan(userId, recipeId, plannedDate, recipeDto);
            return ResponseEntity.ok(new ApiResponse<>(true, "Recipe added to plan", planner));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Failed to add recipe to plan: " + e.getMessage(), null));
        }
    }

    @GetMapping
    public ResponseEntity<?> getUserPlan(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        try {
            List<PlannerDto> planners = plannerService.getUserPlan(userId, startDate, endDate);
            return ResponseEntity.ok(new ApiResponse<>(true, "User plan retrieved successfully", planners));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Failed to get user plan: " + e.getMessage(), null));
        }
    }

    @DeleteMapping("/{plannerId}")
    public ResponseEntity<?> removePlannerItem(
            @RequestParam Long userId,
            @PathVariable Long plannerId) {
        try {
            plannerService.removePlannerItem(plannerId, userId);
            return ResponseEntity.ok(new ApiResponse<>(true, "Planner item removed successfully", null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Failed to remove planner item: " + e.getMessage(), null));
        }
    }

    @PatchMapping("/{plannerId}/toggle-completion")
    public ResponseEntity<?> toggleMealCompletion(
            @PathVariable Long plannerId,
            @RequestParam Long userId,
            @RequestParam boolean completed) {
        try {
            plannerService.toggleMealCompletion(plannerId, userId, completed);
            return ResponseEntity.ok(new ApiResponse<>(true, "Meal completion status updated successfully", null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>(false, "Failed to update meal completion status: " + e.getMessage(), null));
        }
    }

    private RecipeDto convertMapToRecipeDto(Map<String, Object> recipeData) {
        RecipeDto dto = new RecipeDto();
        try {
            dto.setExternalId(getString(recipeData, "externalId"));
            dto.setTitle(getString(recipeData, "title"));
            dto.setDescription(getString(recipeData, "description"));
            dto.setThumbnailUrl(getString(recipeData, "thumbnailUrl"));
            dto.setArea(getString(recipeData, "area"));
            dto.setCategory(getString(recipeData, "category"));
            dto.setInstructions(getString(recipeData, "instructions"));
            
            Integer cookingTime = (Integer) recipeData.get("cookingTime");
            dto.setCookingTime(cookingTime != null ? cookingTime : 0);
            
            @SuppressWarnings("unchecked")
            List<String> ingredients = (List<String>) recipeData.get("ingredients");
            dto.setIngredients(ingredients != null ? ingredients : new ArrayList<>());
            
            @SuppressWarnings("unchecked")
            List<String> measures = (List<String>) recipeData.get("measures");
            dto.setMeasures(measures != null ? measures : new ArrayList<>());
            
            System.out.println("Converted recipe data: " + dto);
            return dto;
        } catch (Exception e) {
            System.err.println("Error converting recipe data: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to convert recipe data", e);
        }
    }

    private String getString(Map<String, Object> map, String key) {
        Object value = map.get(key);
        return value != null ? value.toString() : "";
    }
}