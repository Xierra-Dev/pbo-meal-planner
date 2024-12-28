package com.nutriguide.converter;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Converter
public class JsonConverter implements AttributeConverter<List<String>, String> {
    private static final Logger logger = LoggerFactory.getLogger(JsonConverter.class);
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(List<String> attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return "[]";
        }

        try {
            String json = objectMapper.writeValueAsString(attribute);
            logger.debug("Converting to database column: {}", json);
            return json;
        } catch (JsonProcessingException e) {
            logger.error("Error converting list to JSON: {}", e.getMessage());
            return "[]";
        }
    }

    @Override
    public List<String> convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.trim().isEmpty() || "null".equals(dbData)) {
            return new ArrayList<>();
        }

        try {
            List<String> list = objectMapper.readValue(dbData, new TypeReference<List<String>>() {});
            logger.debug("Converting from database column: {}", list);
            return list;
        } catch (IOException e) {
            logger.error("Error converting JSON to list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    // Helper method untuk validasi JSON
    public boolean isValidJson(String json) {
        try {
            objectMapper.readTree(json);
            return true;
        } catch (JsonProcessingException e) {
            return false;
        }
    }

    // Helper method untuk sanitize JSON string
    public String sanitizeJson(String json) {
        if (json == null || json.trim().isEmpty()) {
            return "[]";
        }

        // Remove invalid characters
        json = json.replaceAll("[^\\x20-\\x7E]", "");
        
        // Ensure it starts with [ and ends with ]
        if (!json.startsWith("[")) {
            json = "[" + json;
        }
        if (!json.endsWith("]")) {
            json = json + "]";
        }

        return json;
    }

    // Helper method untuk convert single string ke list
    public List<String> convertStringToList(String value) {
        List<String> list = new ArrayList<>();
        if (value != null && !value.trim().isEmpty()) {
            list.add(value);
        }
        return list;
    }

    // Helper method untuk handle legacy data
    public List<String> handleLegacyFormat(String dbData) {
        try {
            // Try parsing as array first
            return objectMapper.readValue(dbData, new TypeReference<List<String>>() {});
        } catch (IOException e) {
            try {
                // If failed, try parsing as single string
                String singleValue = objectMapper.readValue(dbData, String.class);
                return convertStringToList(singleValue);
            } catch (IOException ex) {
                logger.error("Error handling legacy format: {}", ex.getMessage());
                return new ArrayList<>();
            }
        }
    }
}