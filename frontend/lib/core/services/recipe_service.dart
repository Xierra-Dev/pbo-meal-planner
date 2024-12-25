import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/recipe.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class RecipeService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String baseUrl = ApiConstants.baseUrl;

  // Get recommended recipes from NutriGuide API
  Future<List<Recipe>> getRecommendedRecipes(int count) async {
    List<Recipe> recipes = [];
    for (var i = 0; i < count; i++) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConstants.mealDbUrl}/random.php'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            recipes.add(Recipe.fromMealDB(data['meals'][0]));
          }
        }
      } catch (e) {
        print('Error fetching random recipe: $e');
      }
    }
    return recipes;
  }

  // Get popular recipes from NutriGuide API
  Future<List<Recipe>> getPopularRecipes(int count) async {
    List<Recipe> recipes = [];
    for (var i = 0; i < count; i++) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConstants.mealDbUrl}/random.php'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            recipes.add(Recipe.fromMealDB(data['meals'][0]));
          }
        }
      } catch (e) {
        print('Error fetching random recipe: $e');
      }
    }
    return recipes;
  }

  // Get random recipes from TheMealDB API
  Future<List<Recipe>> getRandomRecipes(int count) async {
    List<Recipe> recipes = [];
    for (var i = 0; i < count; i++) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConstants.mealDbUrl}/random.php'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            recipes.add(Recipe.fromMealDB(data['meals'][0]));
          }
        }
      } catch (e) {
        print('Error fetching random recipe: $e');
      }
    }
    return recipes;
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.mealDbUrl}/filter.php?c=$category'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => Recipe.fromMealDB(meal))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching category recipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.mealDbUrl}/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => Recipe.fromMealDB(meal))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }
}