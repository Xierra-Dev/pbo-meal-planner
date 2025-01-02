package com.nutriguide.model;

public enum UserRole {
    REGULAR_USER("regular_user"),
    PREMIUM_USER("premium_user"),
    ADMIN("admin");

    private final String value;
    
    UserRole(String value) {
        this.value = value;
    }
    
    public String getValue() {
        return value;
    }
}