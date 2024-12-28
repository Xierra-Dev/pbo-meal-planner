import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class UserPreferences extends Equatable {
  final HealthData? healthData;
  final List<String> goals;
  final List<String> allergies;

  const UserPreferences({
    this.healthData,
    this.goals = const [],
    this.allergies = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      healthData: json['healthData'] != null 
          ? HealthData.fromJson(json['healthData']) 
          : null,
      goals: List<String>.from(json['goals'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthData': healthData?.toJson(),
      'goals': goals,
      'allergies': allergies,
    };
  }

  UserPreferences copyWith({
    HealthData? healthData,
    List<String>? goals,
    List<String>? allergies,
  }) {
    return UserPreferences(
      healthData: healthData ?? this.healthData,
      goals: goals ?? this.goals,
      allergies: allergies ?? this.allergies,
    );
  }

  @override
  List<Object?> get props => [healthData, goals, allergies];
}

class HealthData extends Equatable {
  final String? sex;
  final int? birthYear;
  final int? height;
  final double? weight;
  final String? activityLevel;

  const HealthData({
    this.sex,
    this.birthYear,
    this.height,
    this.weight,
    this.activityLevel,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      sex: json['sex'],
      birthYear: json['birthYear'],
      height: json['height'],
      weight: json['weight']?.toDouble(),
      activityLevel: json['activityLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sex': sex,
      'birthYear': birthYear,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
    };
  }

  HealthData copyWith({
    String? sex,
    int? birthYear,
    int? height,
    double? weight,
    String? activityLevel,
  }) {
    return HealthData(
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  @override
  List<Object?> get props => [sex, birthYear, height, weight, activityLevel];
}

class GoalItem extends Equatable {
  final String title;
  final IconData icon;
  final String description;
  bool isSelected;

  GoalItem({
    required this.title,
    required this.icon,
    required this.description,
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [title, icon, description, isSelected];
}

class AllergyItem extends Equatable {
  final String name;
  final IconData icon;
  final String examples;
  bool isSelected;

  AllergyItem({
    required this.name,
    required this.icon,
    required this.examples,
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [name, icon, examples, isSelected];
}