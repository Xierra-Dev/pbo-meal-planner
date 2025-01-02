package com.nutriguide.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileDto {
    private Long id;

    @Size(min = 1, max = 100, message = "First name must be between 1 and 100 characters")
    private String firstName;

    @Size(min = 1, max = 100, message = "Last name must be between 1 and 100 characters")
    private String lastName;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @Email(message = "Invalid email format")
    private String email;
    private String role; // Add the role field if needed
    @Size(max = 255, message = "Bio cannot exceed 255 characters")
    private String bio;

    private String profilePictureUrl;

    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;

    // Custom method untuk generate profile URL
    public String getProfileUrl() {
        return String.format("https://app.nutriguide.com/u/%s", username);
    }

    // Method untuk memformat nama lengkap
    public String getFullName() {
        if (firstName == null && lastName == null) {
            return username;
        }
        
        StringBuilder fullName = new StringBuilder();
        if (firstName != null) {
            fullName.append(firstName);
        }
        if (lastName != null) {
            if (fullName.length() > 0) {
                fullName.append(" ");
            }
            fullName.append(lastName);
        }
        return fullName.toString();
    }

    // Method untuk memvalidasi profile picture URL
    public boolean hasValidProfilePicture() {
        return profilePictureUrl != null && !profilePictureUrl.trim().isEmpty();
    }

    // Method untuk mendapatkan default profile picture jika tidak ada
    public String getProfilePicture() {
        return hasValidProfilePicture() 
            ? profilePictureUrl 
            : "https://app.nutriguide.com/assets/default-profile.png";
    }

    // Method untuk mengecek apakah profile sudah lengkap
    public boolean isProfileComplete() {
        return firstName != null && !firstName.trim().isEmpty()
            && lastName != null && !lastName.trim().isEmpty()
            && bio != null && !bio.trim().isEmpty()
            && hasValidProfilePicture();
    }

    // Method untuk mendapatkan completion percentage
    public int getProfileCompletionPercentage() {
        int total = 0;
        int completed = 0;

        // Check first name
        total++;
        if (firstName != null && !firstName.trim().isEmpty()) completed++;

        // Check last name
        total++;
        if (lastName != null && !lastName.trim().isEmpty()) completed++;

        // Check bio
        total++;
        if (bio != null && !bio.trim().isEmpty()) completed++;

        // Check profile picture
        total++;
        if (hasValidProfilePicture()) completed++;

        return (completed * 100) / total;
    }

    // Static factory method untuk membuat instance dari minimal data
    public static UserProfileDto createMinimal(String username, String email) {
        return UserProfileDto.builder()
            .username(username)
            .email(email)
            .createdAt(LocalDateTime.now())
            .updatedAt(LocalDateTime.now())
            .build();
    }

    // Method untuk sanitize data sebelum save
    public void sanitize() {
        if (firstName != null) firstName = firstName.trim();
        if (lastName != null) lastName = lastName.trim();
        if (username != null) username = username.trim().toLowerCase();
        if (email != null) email = email.trim().toLowerCase();
        if (bio != null) bio = bio.trim();
    }
}