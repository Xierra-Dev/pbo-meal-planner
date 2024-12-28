package com.nutriguide.controller;

import com.nutriguide.dto.UserPreferencesDto;
import com.nutriguide.service.UserPreferencesService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/preferences")
@RequiredArgsConstructor
@Slf4j
public class UserPreferencesController {
    private final UserPreferencesService preferencesService;
    
    @PutMapping("/{userId}")
    public ResponseEntity<Void> updatePreferences(
        @PathVariable Long userId,
        @RequestBody UserPreferencesDto preferences
    ) {
        log.info("Received PUT request for user {} with data: {}", userId, preferences);
        preferencesService.saveUserPreferences(userId, preferences);
        log.info("Successfully processed preferences update for user {}", userId);
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/{userId}")
    public ResponseEntity<UserPreferencesDto> getPreferences(
        @PathVariable Long userId
    ) {
        log.info("Received GET request for user {}", userId);
        UserPreferencesDto preferences = preferencesService.getUserPreferences(userId);
        log.info("Returning preferences for user {}: {}", userId, preferences);
        return ResponseEntity.ok(preferences);
    }

    @GetMapping("/debug/{userId}")
    public ResponseEntity<String> debugUserPreferences(@PathVariable Long userId) {
        log.info("Debugging preferences for user {}", userId);
        UserPreferencesDto preferences = preferencesService.getUserPreferences(userId);
        return ResponseEntity.ok("Current preferences state: " + preferences.toString());
    }
}