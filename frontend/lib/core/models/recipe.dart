import 'dart:math';

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
  final double healthScore;
  final NutritionInfo nutritionInfo;

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
    required this.healthScore,
    required this.nutritionInfo,
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
      'healthScore': healthScore,
      'nutritionInfo': nutritionInfo.toJson(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      externalId: json['externalId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      instructions: json['instructions'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      measures: List<String>.from(json['measures'] ?? []),
      area: json['area'] ?? '',
      healthScore: (json['healthScore'] ?? 5.0).toDouble(),
      nutritionInfo: json['nutritionInfo'] != null 
          ? NutritionInfo.fromJson(json['nutritionInfo'])
          : NutritionInfo.generateRandom(),
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
      id: json['idMeal'] ?? '',
      externalId: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      ingredients: ingredients,
      measures: measures,
      area: json['strArea'] ?? '',
      healthScore: calculateHealthScore(ingredients),
      nutritionInfo: NutritionInfo.generateRandom(),
    );
  }

  static double calculateHealthScore(List<String> ingredients) {
    double score = 5.0; // Base score
    
    // Keywords that affect health score with different weights
    final Map<String, double> healthyKeywords = {
      'vegetable': 0.8,
      'vegetables': 0.8,
      'fruit': 0.7,
      'fruits': 0.7,
      'fish': 0.6,
      'salmon': 0.7,
      'tuna': 0.6,
      'chicken': 0.5,
      'turkey': 0.5,
      'lean': 0.4,
      'olive oil': 0.4,
      'garlic': 0.3,
      'herb': 0.3,
      'herbs': 0.3,
      'spice': 0.2,
      'spices': 0.2,
      'grain': 0.4,
      'grains': 0.4,
      'quinoa': 0.6,
      'brown rice': 0.5,
      'oats': 0.5,
      'nuts': 0.6,
      'seeds': 0.5,
      'yogurt': 0.4,
      'egg': 0.3,
      'beans': 0.6,
      'lentils': 0.6,
      'tofu': 0.5,
      'tomato': 0.5,
      'spinach': 0.7,
      'kale': 0.7,
      'broccoli': 0.7,
      'carrot': 0.6,
      'sweet potato': 0.6,
      'avocado': 0.6,
      'green': 0.5,
      'fresh': 0.4,
      'lean meat': 0.5,
      'white meat': 0.4,
    };
    
    final Map<String, double> unhealthyKeywords = {
      'sugar': -0.8,
      'syrup': -0.7,
      'corn syrup': -0.9,
      'cream': -0.6,
      'heavy cream': -0.7,
      'fried': -0.8,
      'deep fried': -0.9,
      'butter': -0.5,
      'margarine': -0.7,
      'oil': -0.4,
      'vegetable oil': -0.5,
      'bacon': -0.7,
      'sausage': -0.6,
      'processed': -0.7,
      'white flour': -0.5,
      'chocolate': -0.4,
      'candy': -0.8,
      'caramel': -0.6,
      'soda': -0.8,
      'mayo': -0.6,
      'mayonnaise': -0.6,
      'white bread': -0.5,
      'artificial': -0.7,
      'fat': -0.6,
      'lard': -0.8,
      'shortening': -0.7,
      'processed meat': -0.8,
      'canned': -0.3,
      'instant': -0.4,
      'packaged': -0.4,
      'preservative': -0.5,
      'food coloring': -0.6,
      'msg': -0.7,
    };
    
    // Check ingredients
    for (var ingredient in ingredients) {
      final lowerIngredient = ingredient.toLowerCase();
      
      // Check healthy ingredients
      for (var entry in healthyKeywords.entries) {
        if (lowerIngredient.contains(entry.key)) {
          score += entry.value;
          break; // Break after first match to avoid multiple additions
        }
      }
      
      // Check unhealthy ingredients
      for (var entry in unhealthyKeywords.entries) {
        if (lowerIngredient.contains(entry.key)) {
          score += entry.value;
          break; // Break after first match to avoid multiple deductions
        }
      }
    }

    // Additional factors
    final uniqueIngredientCount = ingredients.toSet().length;
    if (uniqueIngredientCount >= 10) score += 0.5; // Variety bonus
    if (uniqueIngredientCount <= 3) score -= 0.5; // Simplicity penalty
    
    // Category-based adjustments
    if (ingredients.any((i) => i.toLowerCase().contains('salad'))) score += 0.5;
    if (ingredients.any((i) => i.toLowerCase().contains('soup'))) score += 0.3;
    if (ingredients.any((i) => i.toLowerCase().contains('dessert'))) score -= 0.3;
    
    // Normalize score between 0 and 10
    score = score.clamp(0, 10);
    
    // Round to 1 decimal place
    return (score * 10).round() / 10;
  }
}

class NutritionInfo {
  final int calories;
  final double totalFat;
  final double saturatedFat;
  final double carbs;
  final double sugars;
  final double protein;
  final int sodium;
  final double fiber;

  NutritionInfo({
    required this.calories,
    required this.totalFat,
    required this.saturatedFat,
    required this.carbs,
    required this.sugars,
    required this.protein,
    required this.sodium,
    required this.fiber,
  });

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'totalFat': totalFat,
      'saturatedFat': saturatedFat,
      'carbs': carbs,
      'sugars': sugars,
      'protein': protein,
      'sodium': sodium,
      'fiber': fiber,
    };
  }

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] ?? 0,
      totalFat: (json['totalFat'] ?? 0).toDouble(),
      saturatedFat: (json['saturatedFat'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      sugars: (json['sugars'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      sodium: json['sodium'] ?? 0,
      fiber: (json['fiber'] ?? 0).toDouble(),
    );
  }

  factory NutritionInfo.generateRandom() {
    final random = Random();
    return NutritionInfo(
      calories: 200 + random.nextInt(800),
      totalFat: (5 + random.nextInt(25)).toDouble(),
      saturatedFat: (1 + random.nextInt(8)).toDouble(),
      carbs: (10 + random.nextInt(40)).toDouble(),
      sugars: (2 + random.nextInt(15)).toDouble(),
      protein: (8 + random.nextInt(30)).toDouble(),
      sodium: 100 + random.nextInt(900),
      fiber: (random.nextInt(5)).toDouble(),
    );
  }
}