package com.nutriguide.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserHealthDataDto {
    private String sex;
    private Integer birthYear;
    private Integer height;
    private Double weight;
    private String activityLevel;

    @Override
    public String toString() {
        return "UserHealthDataDto{" +
            "sex='" + sex + '\'' +
            ", birthYear=" + birthYear +
            ", height=" + height +
            ", weight=" + weight +
            ", activityLevel='" + activityLevel + '\'' +
            '}';
    }
}