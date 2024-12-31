package com.nutriguide.controller;

import com.nutriguide.dto.AssistantRequestDTO;
import com.nutriguide.dto.AssistantResponseDTO;
import com.nutriguide.exception.ResourceNotFoundException;
import com.nutriguide.service.AssistantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/assistant")
@CrossOrigin(origins = "*")
public class AssistantController {
    
    @Autowired
    private AssistantService assistantService;
    
    @PostMapping
    public ResponseEntity<?> chat(@RequestBody AssistantRequestDTO request) {
        try {
            AssistantResponseDTO response = assistantService.processAssistant(request);
            return ResponseEntity.ok(response);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to process chat request: " + e.getMessage()));
        }
    }
    
    @GetMapping("/history/{userId}")
    public ResponseEntity<?> getAssistantHistory(@PathVariable Long userId) {
        try {
            List<AssistantResponseDTO> history = assistantService.getAssistantHistory(userId);
            return ResponseEntity.ok(history);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to get chat history: " + e.getMessage()));
        }
    }
}
