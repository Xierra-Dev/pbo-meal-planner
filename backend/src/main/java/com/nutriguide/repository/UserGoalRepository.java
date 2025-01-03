package com.nutriguide.repository;

import com.nutriguide.model.UserGoal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface UserGoalRepository extends JpaRepository<UserGoal, Long> {
    List<UserGoal> findByUserId(Long userId);
    
    @Modifying
    @Query("DELETE FROM UserGoal ug WHERE ug.user.id = :userId")
    void deleteByUserId(@Param("userId") Long userId);
}