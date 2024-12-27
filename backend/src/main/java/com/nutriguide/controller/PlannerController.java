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
import java.util.List;

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
        @RequestParam LocalDate plannedDate,
        @RequestBody RecipeDto recipeDto
    ) {
        try {
            PlannerDto planner = plannerService.addToPlan(userId, recipeId, plannedDate, recipeDto);
            return ResponseEntity.ok(new ApiResponse<>(true, "Recipe added to plan", planner));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse<>(false, "Failed to add recipe to plan", null));
        }
    }

    @GetMapping
    public ResponseEntity<List<PlannerDto>> getUserPlan(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(plannerService.getUserPlan(userId, startDate, endDate));
    }

    @DeleteMapping("/{plannerId}")
    public ResponseEntity<?> removePlannerItem(
            @RequestParam Long userId,
            @PathVariable Long plannerId) {
        plannerService.removePlannerItem(plannerId, userId);
        return ResponseEntity.ok().build();
    }
}