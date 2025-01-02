package com.nutriguide.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AssistantResponseDTO {
    private Long id;
    private Long userId;  // Changed to Long to match User entity
    private String message;
    private String response;
    private LocalDateTime timestamp;
}