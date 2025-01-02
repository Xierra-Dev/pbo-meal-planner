package com.nutriguide.dto;

import com.nutriguide.model.UserRole;
import lombok.Data;

@Data
public class UserDto {
    private Long id;
    private String username;
    private String email;
    private UserRole roleUser;
}