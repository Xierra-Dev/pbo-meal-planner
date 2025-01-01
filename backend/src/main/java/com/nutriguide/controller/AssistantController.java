package com.nutriguide.controller;

import com.nutriguide.dto.AssistantRequestDTO;
import com.nutriguide.dto.AssistantResponseDTO;
import com.nutriguide.service.AssistantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/assistant")
@CrossOrigin(origins = "*")
public class AssistantController {
    
    @Autowired
    private AssistantService assistantService;
    
    @PostMapping
    public ResponseEntity<AssistantResponseDTO> chat(@RequestBody AssistantRequestDTO request) {
        AssistantResponseDTO response = assistantService.processAssistant(request);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/history/{userId}")
    public ResponseEntity<List<AssistantResponseDTO>> getAssistantHistory(@PathVariable String userId) {
        List<AssistantResponseDTO> historyDTOs = assistantService.getAssistantHistory(userId);
        return ResponseEntity.ok(historyDTOs);
    }
}