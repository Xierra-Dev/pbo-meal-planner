package com.nutriguide.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse {
    private boolean success;
    private String message;
    private Object data;
    private String error;
    private String timestamp;

    public ApiResponse() {
        this.timestamp = LocalDateTime.now().toString();
    }

    public ApiResponse(boolean success, String message) {
        this();
        this.success = success;
        this.message = message;
    }

    public ApiResponse(boolean success, String message, Object data) {
        this();
        this.success = success;
        this.message = message;
        this.data = data;
    }

    public ApiResponse(boolean success, String message, String error) {
        this();
        this.success = success;
        this.message = message;
        this.error = error;
    }

    public static ApiResponse success(String message) {
        return new ApiResponse(true, message);
    }

    public static ApiResponse success(String message, Object data) {
        return new ApiResponse(true, message, data);
    }

    public static ApiResponse error(String message) {
        return new ApiResponse(false, message);
    }

    public static ApiResponse error(String message, String error) {
        return new ApiResponse(false, message, error);
    }
}