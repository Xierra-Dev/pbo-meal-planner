package com.nutriguide.repository;

import com.nutriguide.model.SavedRecipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SavedRecipeRepository extends JpaRepository<SavedRecipe, Long> {
    @Query("SELECT sr FROM SavedRecipe sr JOIN FETCH sr.recipe WHERE sr.user.id = :userId")
    List<SavedRecipe> findByUserIdWithRecipe(@Param("userId") Long userId);
    
    boolean existsByUserIdAndRecipe_Id(Long userId, Long recipeId);
    
    boolean existsByUserIdAndRecipe_ExternalId(Long userId, String externalId);
    
    void deleteByUserIdAndRecipe_ExternalId(Long userId, String recipeId);
}