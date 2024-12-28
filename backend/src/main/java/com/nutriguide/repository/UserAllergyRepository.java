package com.nutriguide.repository;

import com.nutriguide.model.UserAllergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface UserAllergyRepository extends JpaRepository<UserAllergy, Long> {
    List<UserAllergy> findByUserId(Long userId);
    void deleteByUserId(Long userId);
}