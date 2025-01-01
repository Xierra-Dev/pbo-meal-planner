package com.nutriguide.service;

import com.nutriguide.dto.AssistantRequestDTO;
import com.nutriguide.dto.AssistantResponseDTO;
import com.nutriguide.exception.AssistantProcessingException;
import com.nutriguide.model.Assistant;
import com.nutriguide.repository.AssistantRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AssistantService {
    private static final Logger logger = LoggerFactory.getLogger(AssistantService.class);
    
    private final AssistantRepository assistantRepository;
    private final RestTemplate restTemplate;
    private final String apiKey;
    private final String apiUrl;

    public AssistantService(
        AssistantRepository assistantRepository,
        @Value("${gemini.api.key}") String apiKey,
        @Value("${gemini.api.url}") String apiUrl
    ) {
        this.assistantRepository = assistantRepository;
        this.restTemplate = new RestTemplate();
        this.apiKey = apiKey;
        this.apiUrl = apiUrl;
    }

    public AssistantResponseDTO processAssistant(AssistantRequestDTO request) {
        try {
            logger.debug("Processing assistant request for user: {}", request.getUserId());
            
            // Prepare headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-goog-api-key", apiKey);

            // Prepare request body
            Map<String, Object> requestBody = new HashMap<>();
            Map<String, Object> contents = new HashMap<>();
            contents.put("role", "user");
            contents.put("parts", new Object[]{
                Map.of("text", request.getMessage())
            });
            requestBody.put("contents", new Object[]{contents});

            // Make request to Gemini API
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            ResponseEntity<String> response = restTemplate.exchange(
                apiUrl,
                HttpMethod.POST,
                entity,
                String.class
            );

            // Parse response
            JSONObject jsonResponse = new JSONObject(response.getBody());
            String assistantResponse = jsonResponse
                .getJSONArray("candidates")
                .getJSONObject(0)
                .getJSONObject("content")
                .getJSONArray("parts")
                .getJSONObject(0)
                .getString("text");

            // Save to database
            Assistant assistantEntity = new Assistant();
            assistantEntity.setUserId(request.getUserId());
            assistantEntity.setMessage(request.getMessage());
            assistantEntity.setResponse(assistantResponse);
            assistantEntity.setTimestamp(LocalDateTime.now());

            Assistant savedAssistant = assistantRepository.save(assistantEntity);
            logger.debug("Saved assistant response with ID: {}", savedAssistant.getId());

            return convertToDTO(savedAssistant);
        } catch (Exception e) {
            logger.error("Failed to process assistant message", e);
            throw new AssistantProcessingException("Failed to process assistant message", e);
        }
    }

    public List<AssistantResponseDTO> getAssistantHistory(String userId) {
        List<Assistant> history = assistantRepository.findByUserIdOrderByTimestampDesc(userId);
        return history.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private AssistantResponseDTO convertToDTO(Assistant assistant) {
        AssistantResponseDTO dto = new AssistantResponseDTO();
        dto.setId(assistant.getId());
        dto.setMessage(assistant.getMessage());
        dto.setResponse(assistant.getResponse());
        dto.setTimestamp(assistant.getTimestamp());
        dto.setUserId(assistant.getUserId());
        return dto;
    }
}