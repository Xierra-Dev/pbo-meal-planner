package com.nutriguide.controller;

import com.nutriguide.dto.ApiResponse;
import com.nutriguide.dto.LoginRequest;
import com.nutriguide.dto.RegisterRequest;
import com.nutriguide.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
            
            // Validasi input
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
            return authService.login(request);
        } catch (Exception e) {
            System.out.println("Login error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, e.getMessage()));
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
}