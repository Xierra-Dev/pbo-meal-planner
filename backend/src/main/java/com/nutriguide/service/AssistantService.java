package com.nutriguide.service;

import com.nutriguide.dto.AssistantRequestDTO;
import com.nutriguide.dto.AssistantResponseDTO;
import com.nutriguide.exception.AssistantProcessingException;
import com.nutriguide.exception.ResourceNotFoundException;
import com.nutriguide.model.Assistant;
import com.nutriguide.model.User;
import com.nutriguide.repository.AssistantRepository;
import com.nutriguide.repository.UserRepository;
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
import org.springframework.transaction.annotation.Transactional;

@Service
public class AssistantService {
    private static final Logger logger = LoggerFactory.getLogger(AssistantService.class);
    
    private final AssistantRepository assistantRepository;
    private final UserRepository userRepository;
    private final RestTemplate restTemplate;
    private final String apiKey;
    private final String apiUrl;

    @Value("${gemini.max.tokens:500}")
    private Integer maxTokens;

    @Value("${gemini.temperature:0.7}")
    private Double temperature;

    public AssistantService(
            AssistantRepository assistantRepository,
            UserRepository userRepository,
            @Value("${gemini.api.key}") String apiKey,
            @Value("${gemini.api.url}") String apiUrl
    ) {
        this.assistantRepository = assistantRepository;
        this.userRepository = userRepository;
        this.restTemplate = new RestTemplate();
        this.apiKey = apiKey;
        this.apiUrl = apiUrl;
    }

    @Transactional
    public AssistantResponseDTO processAssistant(AssistantRequestDTO request) {
        try {
            logger.debug("Processing assistant request for user: {}", request.getUserId());

            // Validate user exists
            User user = userRepository.findById(request.getUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + request.getUserId()));

            // Prepare headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-goog-api-key", apiKey);

            // Prepare request body for Gemini API
            Map<String, Object> requestBody = new HashMap<>();
            Map<String, Object> contents = new HashMap<>();
            contents.put("role", "user");
            contents.put("parts", new Object[]{
                    Map.of("text", request.getMessage())
            });
            
            requestBody.put("contents", new Object[]{contents});
            requestBody.put("generationConfig", Map.of(
                "temperature", temperature,
                "maxOutputTokens", maxTokens
            ));

            // Call Gemini API
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            ResponseEntity<String> response = restTemplate.exchange(
                    apiUrl,
                    HttpMethod.POST,
                    entity,
                    String.class
            );

            // Handle API response
            if (!response.getStatusCode().is2xxSuccessful()) {
                throw new AssistantProcessingException("Failed to get response from Gemini API", null);
            }

            String assistantResponse = extractResponseFromJson(new JSONObject(response.getBody()));

            // Save to database
            Assistant assistant = new Assistant();
            assistant.setUser(user);
            assistant.setMessage(request.getMessage());
            assistant.setResponse(assistantResponse);
            assistant.setTimestamp(LocalDateTime.now());

            Assistant savedAssistant = assistantRepository.save(assistant);
            
            return convertToDTO(savedAssistant);

        } catch (ResourceNotFoundException e) {
            logger.error("User not found: {}", e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.error("Error processing assistant request: ", e);
            throw new AssistantProcessingException("Failed to process assistant request", e);
        }
    }

    private String extractResponseFromJson(JSONObject jsonResponse) {
        try {
            return jsonResponse
                    .getJSONArray("candidates")
                    .getJSONObject(0)
                    .getJSONObject("content")
                    .getJSONArray("parts")
                    .getJSONObject(0)
                    .getString("text");
        } catch (Exception e) {
            throw new AssistantProcessingException("Failed to parse Gemini API response", e);
        }
    }

    private AssistantResponseDTO convertToDTO(Assistant assistant) {
        AssistantResponseDTO dto = new AssistantResponseDTO();
        dto.setId(assistant.getId());
        dto.setUserId(assistant.getUser().getId());
        dto.setMessage(assistant.getMessage());
        dto.setResponse(assistant.getResponse());
        dto.setTimestamp(assistant.getTimestamp());
        return dto;
    }

    @Transactional(readOnly = true)
    public List<AssistantResponseDTO> getAssistantHistory(Long userId) {
        try {
            // Validate user exists
            if (!userRepository.existsById(userId)) {
                throw new ResourceNotFoundException("User not found with id: " + userId);
            }
                
            logger.debug("Fetching chat history for user: {}", userId);
            List<Assistant> history = assistantRepository.findByUserIdOrderByTimestampDesc(userId);
            logger.debug("Found {} messages in history", history.size());
            
            return history.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
                    
        } catch (ResourceNotFoundException e) {
            logger.error("User not found: {}", e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.error("Error fetching chat history for user: " + userId, e);
            throw new AssistantProcessingException("Failed to fetch chat history", e);
        }
    }
}