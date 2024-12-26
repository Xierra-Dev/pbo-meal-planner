package com.nutriguide.repository;

import com.nutriguide.model.Planner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface PlannerRepository extends JpaRepository<Planner, Long> {
    
    @Query("SELECT p FROM Planner p " +
           "JOIN FETCH p.recipe " +
           "JOIN FETCH p.user " +
           "WHERE p.user.id = :userId " +
           "AND p.plannedDate BETWEEN :startDate AND :endDate " +
           "ORDER BY p.plannedDate ASC")
    List<Planner> findByUserIdAndPlannedDateBetween(
        @Param("userId") Long userId, 
        @Param("startDate") LocalDate startDate, 
        @Param("endDate") LocalDate endDate
    );

    @Query("SELECT CASE WHEN COUNT(p) > 0 THEN true ELSE false END " +
           "FROM Planner p " +
           "WHERE p.user.id = :userId " +
           "AND p.recipe.id = :recipeId " +
           "AND p.plannedDate = :plannedDate")
    boolean existsByUserIdAndRecipeIdAndPlannedDate(
        @Param("userId") Long userId, 
        @Param("recipeId") Long recipeId, 
        @Param("plannedDate") LocalDate plannedDate
    );

    @Query("SELECT p FROM Planner p " +
           "JOIN FETCH p.recipe " +
           "WHERE p.id = :plannerId")
    Planner findByIdWithRecipe(@Param("plannerId") Long plannerId);
}