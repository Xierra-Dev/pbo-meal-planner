package com.nutriguide.service;

import com.nutriguide.dto.ApiResponse;
import com.nutriguide.dto.LoginRequest;
import com.nutriguide.dto.RegisterRequest;
import com.nutriguide.model.User;
import com.nutriguide.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@Transactional
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    public ResponseEntity<?> register(RegisterRequest request) {
        try {
            System.out.println("Processing registration for: " + request.getUsername());
            
            if (userRepository.existsByUsername(request.getUsername())) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Username is already taken"));
            }

            if (userRepository.existsByEmail(request.getEmail())) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Email is already registered"));
            }

            User user = new User();
            user.setUsername(request.getUsername());
            user.setEmail(request.getEmail());
            user.setPassword(request.getPassword()); // Store password as-is for simplicity

            User savedUser = userRepository.save(user);
            System.out.println("User registered successfully: " + savedUser.getUsername());

            Map<String, Object> response = new HashMap<>();
            response.put("userId", savedUser.getId());
            response.put("username", savedUser.getUsername());
            response.put("email", savedUser.getEmail());

            return ResponseEntity.ok(new ApiResponse(true, "User registered successfully", response));
        } catch (Exception e) {
            System.out.println("Registration error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, "Registration failed", e.getMessage()));
        }
    }

    public ResponseEntity<?> login(LoginRequest request) {
        try {
            System.out.println("Processing login for: " + request.getEmail());
            
            User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

            if (!request.getPassword().equals(user.getPassword())) {
                return ResponseEntity.badRequest()
                    .body(new ApiResponse(false, "Invalid password"));
            }

            Map<String, Object> response = new HashMap<>();
            response.put("userId", user.getId());
            response.put("username", user.getUsername());
            response.put("email", user.getEmail());

            System.out.println("User logged in successfully: " + user.getUsername());
            return ResponseEntity.ok(new ApiResponse(true, "Login successful", response));
        } catch (Exception e) {
            System.out.println("Login error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                .body(new ApiResponse(false, "Login failed", e.getMessage()));
        }
    }

    public boolean isEmailAvailable(String email) {
        return !userRepository.existsByEmail(email);
    }

    public boolean isUsernameAvailable(String username) {
        return !userRepository.existsByUsername(username);
    }
}