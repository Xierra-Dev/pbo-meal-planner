package com.nutriguide.repository;

import com.nutriguide.model.SavedRecipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SavedRecipeRepository extends JpaRepository<SavedRecipe, Long> {
    List<SavedRecipe> findByUserId(Long userId);
    
    boolean existsByUserIdAndRecipe_Id(Long userId, Long recipeId);
    
    void deleteByUserIdAndRecipe_Id(Long userId, Long recipeId);
    
    @Query("SELECT sr FROM SavedRecipe sr JOIN FETCH sr.recipe WHERE sr.user.id = :userId")
    List<SavedRecipe> findByUserIdWithRecipe(Long userId);
}