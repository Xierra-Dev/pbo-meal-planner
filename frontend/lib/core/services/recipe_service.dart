import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/recipe.dart';
import 'package:flutter/foundation.dart';

class RecipeService extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = ApiConstants.baseUrl;

  // Get recommended recipes
  Future<List<Recipe>> getRecommendedRecipes(int count) async {
    List<Recipe> recipes = [];
    try {
      for (var i = 0; i < count; i++) {
        final response = await _dio.get('${ApiConstants.mealDbUrl}/random.php');
        
        if (response.statusCode == 200 && response.data['meals'] != null) {
          recipes.add(Recipe.fromMealDB(response.data['meals'][0]));
        }
      }
      return recipes;
    } catch (e) {
      debugPrint('Error fetching recommended recipes: $e');
      throw Exception('Failed to load recommended recipes');
    }
  }

  // Get popular recipes
  Future<List<Recipe>> getPopularRecipes(int count) async {
    List<Recipe> recipes = [];
    try {
      for (var i = 0; i < count; i++) {
        final response = await _dio.get('${ApiConstants.mealDbUrl}/random.php');
        
        if (response.statusCode == 200 && response.data['meals'] != null) {
          recipes.add(Recipe.fromMealDB(response.data['meals'][0]));
        }
      }
      return recipes;
    } catch (e) {
      debugPrint('Error fetching popular recipes: $e');
      throw Exception('Failed to load popular recipes');
    }
  }

  // Get random recipes
  Future<List<Recipe>> getRandomRecipes(int count) async {
    List<Recipe> recipes = [];
    try {
      for (var i = 0; i < count; i++) {
        final response = await _dio.get('${ApiConstants.mealDbUrl}/random.php');
        
        if (response.statusCode == 200 && response.data['meals'] != null) {
          recipes.add(Recipe.fromMealDB(response.data['meals'][0]));
        }
      }
      return recipes;
    } catch (e) {
      debugPrint('Error fetching random recipes: $e');
      throw Exception('Failed to load random recipes');
    }
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.mealDbUrl}/filter.php',
        queryParameters: {'c': category},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        List<Recipe> recipes = [];
        for (var meal in response.data['meals']) {
          // Get full recipe details
          final detailResponse = await _dio.get(
            '${ApiConstants.mealDbUrl}/lookup.php',
            queryParameters: {'i': meal['idMeal']},
          );
          
          if (detailResponse.statusCode == 200 && 
              detailResponse.data['meals'] != null) {
            recipes.add(Recipe.fromMealDB(detailResponse.data['meals'][0]));
          }
        }
        return recipes;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching category recipes: $e');
      throw Exception('Failed to load category recipes');
    }
  }

  // Search recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.mealDbUrl}/search.php',
        queryParameters: {'s': query},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        return (response.data['meals'] as List)
            .map((meal) => Recipe.fromMealDB(meal))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching recipes: $e');
      throw Exception('Failed to search recipes');
    }
  }

  // Search recipes by ingredient
  Future<List<Recipe>> searchRecipesByIngredient(String ingredient) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.mealDbUrl}/filter.php',
        queryParameters: {'i': ingredient},
      );

      if (response.data['meals'] == null) {
        return [];
      }

      List<Recipe> recipes = [];
      for (var meal in response.data['meals']) {
        // Get full recipe details since filter endpoint doesn't provide all info
        final detailResponse = await _dio.get(
          '${ApiConstants.mealDbUrl}/lookup.php',
          queryParameters: {'i': meal['idMeal']},
        );
        
        if (detailResponse.statusCode == 200 && 
            detailResponse.data['meals'] != null) {
          recipes.add(Recipe.fromMealDB(detailResponse.data['meals'][0]));
        }
      }

      return recipes;
    } catch (e) {
      debugPrint('Error searching recipes by ingredient: $e');
      throw Exception('Failed to search recipes by ingredient');
    }
  }

  // Get recipe categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('${ApiConstants.mealDbUrl}/list.php?c=list');
      
      if (response.statusCode == 200 && response.data['meals'] != null) {
        return (response.data['meals'] as List)
            .map((category) => category['strCategory'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Failed to load categories');
    }
  }

  // Get recipe areas/cuisines
  Future<List<String>> getAreas() async {
    try {
      final response = await _dio.get('${ApiConstants.mealDbUrl}/list.php?a=list');
      
      if (response.statusCode == 200 && response.data['meals'] != null) {
        return (response.data['meals'] as List)
            .map((area) => area['strArea'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching areas: $e');
      throw Exception('Failed to load areas');
    }
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.mealDbUrl}/lookup.php',
        queryParameters: {'i': id},
      );

      if (response.statusCode == 200 && 
          response.data['meals'] != null &&
          response.data['meals'].isNotEmpty) {
        return Recipe.fromMealDB(response.data['meals'][0]);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching recipe details: $e');
      throw Exception('Failed to load recipe details');
    }
  }

  // Get recipes by area/cuisine
  Future<List<Recipe>> getRecipesByArea(String area) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.mealDbUrl}/filter.php',
        queryParameters: {'a': area},
      );

      if (response.statusCode == 200 && response.data['meals'] != null) {
        List<Recipe> recipes = [];
        for (var meal in response.data['meals']) {
          // Get full recipe details
          final detailResponse = await _dio.get(
            '${ApiConstants.mealDbUrl}/lookup.php',
            queryParameters: {'i': meal['idMeal']},
          );
          
          if (detailResponse.statusCode == 200 && 
              detailResponse.data['meals'] != null) {
            recipes.add(Recipe.fromMealDB(detailResponse.data['meals'][0]));
          }
        }
        return recipes;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching area recipes: $e');
      throw Exception('Failed to load area recipes');
    }
  }
}