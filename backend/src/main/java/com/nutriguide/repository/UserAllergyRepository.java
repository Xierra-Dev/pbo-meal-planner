package com.nutriguide.repository;

import com.nutriguide.model.UserAllergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Modifying;
import java.util.List;

@Repository
public interface UserAllergyRepository extends JpaRepository<UserAllergy, Long> {
    List<UserAllergy> findByUserId(Long userId);
    
    @Modifying
    @Query("DELETE FROM UserAllergy ua WHERE ua.user.id = :userId")
    void deleteByUserId(@Param("userId") Long userId);
}