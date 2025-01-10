import 'dart:math';
import 'nutrition_info.dart';

class Recipe {
  final String id;
  final String externalId;
  final String title;
  final String category;
  final String thumbnailUrl;
  final String instructions;
  final List<String> ingredients;
  final List<String> measures;
  final String area;
  final NutritionInfo nutritionInfo;
  final int cookingTime;

  Recipe({
    required this.id,
    required this.externalId,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
    required this.instructions,
    required this.ingredients,
    required this.measures,
    required this.area,
    required this.nutritionInfo,
    this.cookingTime = 30,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalId': externalId,
      'title': title,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'instructions': instructions,
      'ingredients': ingredients,
      'measures': measures,
      'area': area,
      'nutritionInfo': nutritionInfo.toJson(),
      'cookingTime': cookingTime,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      externalId: json['externalId']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      instructions: json['instructions'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      measures: List<String>.from(json['measures'] ?? []),
      area: json['area'] ?? '',
      nutritionInfo: json['nutritionInfo'] != null 
          ? NutritionInfo.fromJson(json['nutritionInfo'])
          : NutritionInfo.generateRandom(),
      cookingTime: json['cookingTime'] ?? 30,
    );
  }

  factory Recipe.fromMealDB(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    for (var i = 1; i <= 20; i++) {
      if (json['strIngredient$i'] != null && json['strIngredient$i'].toString().isNotEmpty) {
        ingredients.add(json['strIngredient$i']);
        measures.add(json['strMeasure$i'] ?? '');
      }
    }

    return Recipe(
      id: json['idMeal']?.toString() ?? '',
      externalId: json['idMeal']?.toString() ?? '',
      title: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      ingredients: ingredients,
      measures: measures,
      area: json['strArea'] ?? '',
      nutritionInfo: NutritionInfo.generateRandom(),
      cookingTime: Random().nextInt(45) + 15, // Random time between 15-60 minutes
    );
  }

  Recipe copyWith({
    String? id,
    String? externalId,
    String? title,
    String? category,
    String? thumbnailUrl,
    String? instructions,
    List<String>? ingredients,
    List<String>? measures,
    String? area,
    double? healthScore,
    NutritionInfo? nutritionInfo,
    int? cookingTime,
  }) {
    return Recipe(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      title: title ?? this.title,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructions: instructions ?? this.instructions,
      ingredients: ingredients ?? this.ingredients,
      measures: measures ?? this.measures,
      area: area ?? this.area,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      cookingTime: cookingTime ?? this.cookingTime,
    );
  }

  

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}