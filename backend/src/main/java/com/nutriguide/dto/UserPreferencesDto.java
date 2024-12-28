package com.nutriguide.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserPreferencesDto {
    private UserHealthDataDto healthData;
    private List<String> goals;
    private List<String> allergies;

    @Override
    public String toString() {
        return "UserPreferencesDto{" +
            "healthData=" + healthData +
            ", goals=" + goals +
            ", allergies=" + allergies +
            '}';
    }
}