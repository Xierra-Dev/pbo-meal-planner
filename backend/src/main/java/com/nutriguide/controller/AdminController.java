package com.nutriguide.controller;

import com.nutriguide.dto.UserProfileDto;
import com.nutriguide.dto.UserResponseDto;
import com.nutriguide.model.User;
import com.nutriguide.service.AdminService;
import com.nutriguide.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {
    private static final Logger logger = LoggerFactory.getLogger(AdminController.class);

    @Autowired
    private AdminService adminService;

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> adminLogin(@RequestBody Map<String, String> credentials) {
        try {
            boolean isValid = adminService.validateAdminCredentials(
                credentials.get("email"), 
                credentials.get("password")
            );
            
            if (isValid) {
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Login successful",
                    "role", "ADMIN"
                ));
            } else {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Invalid credentials"
                ));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserProfileDto>> getAllUsers() {
        return ResponseEntity.ok(adminService.getAllUsers());
    }

    @GetMapping("/users/{userId}")
    public ResponseEntity<User> getUser(@PathVariable Long userId) {
        return ResponseEntity.ok(userService.getUserById(userId));
    }

    @PutMapping("/users/{userId}")
    public ResponseEntity<?> updateUser(@PathVariable Long userId, @RequestBody Map<String, String> userData) {
        logger.debug("Updating user {} with data: {}", userId, userData); // Debug log
        
        try {
            if (userId == null) {
                throw new IllegalArgumentException("User ID cannot be null");
            }
            
            UserResponseDto result = userService.updateUser(userId, userData);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("Error updating user: ", e); // Debug log
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }

    @DeleteMapping("/users/{userId}")
    public ResponseEntity<?> deleteUser(@PathVariable Long userId) {
        try {
            userService.deleteUser(userId);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "User deleted successfully"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", e.getMessage()
            ));
        }
    }
}