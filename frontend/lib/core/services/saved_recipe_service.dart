import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/recipe.dart';

class SavedRecipeService extends ChangeNotifier {
  final String baseUrl = '${ApiConstants.baseUrl}/saved-recipes';
  final int userId = 1; // Hardcoded for now

  final Map<String, Recipe> _savedRecipes = {};
  final Set<String> _savedRecipeIds = {};
  List<Recipe>? _cachedRecipes;

  bool isRecipeSaved(String recipeId) {
    return _savedRecipeIds.contains(recipeId);
  }

  Future<List<Recipe>> getSavedRecipes() async {
    if (_cachedRecipes != null) {
      print('Returning cached recipes');
      return _cachedRecipes!;
    }

    try {
      print('Fetching saved recipes from API');
      final response = await http.get(
        Uri.parse('$baseUrl?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Save recipes response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final recipes = data.map((json) => Recipe.fromJson(json)).toList();
        
        _savedRecipes.clear();
        _savedRecipeIds.clear();
        for (var recipe in recipes) {
          _savedRecipes[recipe.id] = recipe;
          _savedRecipeIds.add(recipe.id);
        }
        
        _cachedRecipes = recipes;
        notifyListeners();
        return recipes;
      }
      throw Exception('Failed to get saved recipes: ${response.body}');
    } catch (e) {
      print('Error getting saved recipes: $e');
      rethrow;
    }
  }

  Future<void> saveRecipe(Recipe recipe) async {
    try {
      print('Saving recipe: ${recipe.id}');
      print('Recipe data: ${json.encode(recipe.toJson())}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/${recipe.id}?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recipe.toJson()),
      );

      print('Save recipe response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _savedRecipeIds.add(recipe.id);
        _savedRecipes[recipe.id] = recipe;
        _cachedRecipes = null; // Clear cache
        notifyListeners();
      } else {
        throw Exception('Failed to save recipe: ${response.body}');
      }
    } catch (e) {
      print('Error saving recipe: $e');
      rethrow;
    }
  }

  Future<void> unsaveRecipe(String recipeId) async {
    try {
      print('Unsaving recipe: $recipeId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$recipeId?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Unsave recipe response: ${response.statusCode}');

      if (response.statusCode == 200) {
        _savedRecipeIds.remove(recipeId);
        _savedRecipes.remove(recipeId);
        _cachedRecipes = null; // Clear cache
        notifyListeners();
      } else {
        throw Exception('Failed to unsave recipe: ${response.body}');
      }
    } catch (e) {
      print('Error unsaving recipe: $e');
      rethrow;
    }
  }
}