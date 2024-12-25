package com.nutriguide.service;

import com.nutriguide.dto.PlannerDto;
import com.nutriguide.dto.RecipeDto;
import com.nutriguide.model.Planner;
import com.nutriguide.model.Recipe;
import com.nutriguide.model.User;
import com.nutriguide.repository.PlannerRepository;
import com.nutriguide.repository.RecipeRepository;
import com.nutriguide.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlannerService {

    @Autowired
    private PlannerRepository plannerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    public PlannerDto addToPlan(Long userId, Long recipeId, LocalDate plannedDate) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new RuntimeException("Recipe not found"));

        Planner planner = new Planner();
        planner.setUser(user);
        planner.setRecipe(recipe);
        planner.setPlannedDate(plannedDate);

        return convertToDto(plannerRepository.save(planner));
    }

    public List<PlannerDto> getUserPlan(Long userId, LocalDate startDate, LocalDate endDate) {
        return plannerRepository.findByUserIdAndPlannedDateBetween(userId, startDate, endDate)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    public void removePlannerItem(Long plannerId, Long userId) {
        Planner planner = plannerRepository.findById(plannerId)
                .orElseThrow(() -> new RuntimeException("Planner item not found"));
        
        if (!planner.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized access");
        }
        
        plannerRepository.delete(planner);
    }

    private PlannerDto convertToDto(Planner planner) {
        PlannerDto dto = new PlannerDto();
        dto.setId(planner.getId());
        dto.setUserId(planner.getUser().getId());
        dto.setRecipeId(planner.getRecipe().getId());
        dto.setPlannedDate(planner.getPlannedDate());
        
        RecipeDto recipeDto = new RecipeDto();
        recipeDto.setId(planner.getRecipe().getId().toString());
        recipeDto.setTitle(planner.getRecipe().getTitle());
        recipeDto.setCategory(planner.getRecipe().getCategory());
        recipeDto.setThumbnailUrl(planner.getRecipe().getThumbnailUrl());
        
        dto.setRecipe(recipeDto);
        return dto;
    }
}