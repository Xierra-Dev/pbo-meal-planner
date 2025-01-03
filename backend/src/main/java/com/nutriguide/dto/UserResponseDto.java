package com.nutriguide.dto;

import com.nutriguide.enums.UserType;
import lombok.Data;

@Data
public class UserResponseDto {
    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private UserType userType;
    private Boolean isActive;
    private String role;
}