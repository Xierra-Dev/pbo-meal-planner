package com.nutriguide.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AssistantResponseDTO {
    private Long id;
    private String userId;
    private String message;
    private String response;
    private LocalDateTime timestamp;
}