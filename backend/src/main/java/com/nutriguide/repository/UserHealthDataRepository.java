package com.nutriguide.repository;

import com.nutriguide.model.UserHealthData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserHealthDataRepository extends JpaRepository<UserHealthData, Long> {
    Optional<UserHealthData> findByUserId(Long userId);
    
    @Modifying
    @Query("DELETE FROM UserHealthData uhd WHERE uhd.user.id = :userId")
    void deleteByUserId(@Param("userId") Long userId);
}