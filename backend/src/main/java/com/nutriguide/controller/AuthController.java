package com.nutriguide.controller;

import com.nutriguide.dto.ApiResponse;
import com.nutriguide.dto.LoginRequest;
import com.nutriguide.dto.RegisterRequest;
import com.nutriguide.service.AuthService;
import com.nutriguide.model.UserRole;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.concurrent.Future;


@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            System.out.println("Register request received: " + request);
            
            // Basic input validation
            if (request.getUsername() == null || request.getUsername().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Username is required"));
            }
            
            if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Email is required"));
            }
            
            if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Password is required"));
            }

            // Account type validation
            if (request.getAccountType() == null) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Account type is required"));
            }

            // Validate account type is one of the allowed values
            if (request.getAccountType() != UserRole.REGULAR_USER && 
                request.getAccountType() != UserRole.PREMIUM_USER && 
                request.getAccountType() != UserRole.ADMIN) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Invalid account type selected"));
            }

            // Log the account type being registered
            System.out.println("Registering new account with type: " + request.getAccountType());

            return authService.register(request);
        } catch (Exception e) {
            System.out.println("Registration error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            System.out.println("Login request received for email: " + request.getEmail());
            
            if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Email is required"));
            }
            
            if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Password is required"));
            }

            return authService.login(request);
        } catch (Exception e) {
            System.out.println("Login error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Login failed", e.getMessage()));
        }
    }

    @GetMapping("/check-email")
    public ResponseEntity<?> checkEmailAvailability(@RequestParam String email) {
        try {
            System.out.println("Checking email availability: " + email);
            boolean isAvailable = authService.isEmailAvailable(email);
            return ResponseEntity.ok(new ApiResponse(true, isAvailable ? "Email is available" : "Email is taken"));
        } catch (Exception e) {
            System.out.println("Email check error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, e.getMessage()));
        }
    }

    @GetMapping("/check-username")
    public ResponseEntity<?> checkUsernameAvailability(@RequestParam String username) {
        try {
            System.out.println("Checking username availability: " + username);
            boolean isAvailable = authService.isUsernameAvailable(username);
            return ResponseEntity.ok(new ApiResponse(true, isAvailable ? "Username is available" : "Username is taken"));
        } catch (Exception e) {
            System.out.println("Username check error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, e.getMessage()));
        }
    }

    // Add a new endpoint to get available account types
    @GetMapping("/account-types")
    public ResponseEntity<?> getAccountTypes() {
        try {
            // Create a list of account type information
            var accountTypes = new Object[] {
                Map.of(
                    "type", "REGULAR_USER",
                    "name", "Free User",
                    "description", "Basic features and recipes",
                    "price", "Free"
                ),
                Map.of(
                    "type", "PREMIUM_USER",
                    "name", "Premium User",
                    "description", "Access chatbot",
                    "price", "$5/month"
                ),
                Map.of(
                    "type", "ADMIN",
                    "name", "Admin",
                    "description", "Professional account as editor",
                    "price", "Contact us"
                )
            };

            return ResponseEntity.ok(new ApiResponse(true, "Account types retrieved successfully", accountTypes));
        } catch (Exception e) {
            System.out.println("Error retrieving account types: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, e.getMessage()));
        }
    }
}