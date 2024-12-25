package com.nutriguide.repository;

import com.nutriguide.model.Planner;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface PlannerRepository extends JpaRepository<Planner, Long> {
    List<Planner> findByUserIdAndPlannedDateBetween(Long userId, LocalDate startDate, LocalDate endDate);
}