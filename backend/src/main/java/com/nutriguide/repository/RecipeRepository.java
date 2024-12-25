package com.nutriguide.repository;

import com.nutriguide.model.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {
    Optional<Recipe> findByExternalId(String externalId);
    List<Recipe> findByTitleContainingIgnoreCase(String query);
    List<Recipe> findByCategory(String category);
}