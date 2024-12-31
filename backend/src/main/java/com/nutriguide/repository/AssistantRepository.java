package com.nutriguide.repository;

import com.nutriguide.model.Assistant;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AssistantRepository extends JpaRepository<Assistant, Long> {
    List<Assistant> findByUserIdOrderByTimestampDesc(String userId);
}