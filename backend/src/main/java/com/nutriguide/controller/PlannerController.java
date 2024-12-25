package com.nutriguide.controller;

import com.nutriguide.dto.PlannerDto;
import com.nutriguide.service.PlannerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
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
    public ResponseEntity<PlannerDto> addToPlan(
            @RequestParam Long userId,
            @RequestParam Long recipeId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate plannedDate) {
        return ResponseEntity.ok(plannerService.addToPlan(userId, recipeId, plannedDate));
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