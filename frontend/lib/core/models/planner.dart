import 'package:flutter/foundation.dart';
import 'recipe.dart';

@immutable
class Planner {
  final String id;
  final Recipe recipe;
  final DateTime plannedDate;
  final bool isCompleted;
  final String? mealType; // breakfast, lunch, dinner
  final String userId;

  const Planner({
    required this.id,
    required this.recipe,
    required this.plannedDate,
    required this.userId,
    this.isCompleted = false,
    this.mealType,
  });

  factory Planner.fromJson(Map<String, dynamic> json) {
    return Planner(
      id: json['id'].toString(),
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      plannedDate: DateTime.parse(json['plannedDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      mealType: json['mealType'] as String?,
      userId: json['userId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe': recipe.toJson(),
      'plannedDate': plannedDate.toIso8601String(),
      'isCompleted': isCompleted,
      'mealType': mealType,
      'userId': userId,
    };
  }

  Planner copyWith({
    String? id,
    Recipe? recipe,
    DateTime? plannedDate,
    bool? isCompleted,
    String? mealType,
    String? userId,
  }) {
    return Planner(
      id: id ?? this.id,
      recipe: recipe ?? this.recipe,
      plannedDate: plannedDate ?? this.plannedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      mealType: mealType ?? this.mealType,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Planner &&
        other.id == id &&
        other.recipe == recipe &&
        other.plannedDate == plannedDate &&
        other.isCompleted == isCompleted &&
        other.mealType == mealType &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      recipe,
      plannedDate,
      isCompleted,
      mealType,
      userId,
    );
  }

  @override
  String toString() {
    return 'Planner(id: $id, recipe: ${recipe.title}, plannedDate: $plannedDate, isCompleted: $isCompleted, mealType: $mealType, userId: $userId)';
  }

  // Helper methods
  bool get isBreakfast => mealType?.toLowerCase() == 'breakfast';
  bool get isLunch => mealType?.toLowerCase() == 'lunch';
  bool get isDinner => mealType?.toLowerCase() == 'dinner';
  
  bool get isToday {
    final now = DateTime.now();
    return plannedDate.year == now.year &&
           plannedDate.month == now.month &&
           plannedDate.day == now.day;
  }

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(plannedDate.year, plannedDate.month, plannedDate.day);
    return mealDate.isBefore(today);
  }

  bool get isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(plannedDate.year, plannedDate.month, plannedDate.day);
    return mealDate.isAfter(today);
  }
}