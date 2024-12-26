import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/recipe.dart';
import 'auth_service.dart';

class SavedRecipeService with ChangeNotifier {
  final String baseUrl = '${ApiConstants.baseUrl}/saved-recipes';
  final AuthService _authService;
  bool _disposed = false;
  bool _isInitialized = false;

  final Map<String, Recipe> _savedRecipes = {};
  final Set<String> _savedRecipeIds = {};
  List<Recipe>? _cachedRecipes;

  SavedRecipeService(this._authService);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  Future<void> _ensureInitialized() async {
    if (_disposed) return;
    if (_isInitialized) return;
    
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        _isInitialized = true;
        if (!_disposed) {
          notifyListeners();
        }
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      print('Error initializing SavedRecipeService: $e');
      rethrow;
    }
  }

  bool isRecipeSaved(String recipeId) {
    return _savedRecipeIds.contains(recipeId);
  }

  Future<List<Recipe>> getSavedRecipes() async {
    if (_disposed) return [];
    
    try {
      await _ensureInitialized();
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      print('Fetching saved recipes for user: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Save recipes response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final recipes = data.map((json) => Recipe.fromJson(json)).toList();
        
        if (!_disposed) {
          _savedRecipes.clear();
          _savedRecipeIds.clear();
          for (var recipe in recipes) {
            _savedRecipes[recipe.id] = recipe;
            _savedRecipeIds.add(recipe.id);
          }
          
          _cachedRecipes = recipes;
          notifyListeners();
        }
        return recipes;
      }
      throw Exception('Failed to get saved recipes: ${response.body}');
    } catch (e) {
      print('Error getting saved recipes: $e');
      rethrow;
    }
  }

  Future<void> saveRecipe(Recipe recipe) async {
    if (_disposed) return;
    
    try {
      await _ensureInitialized();
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      print('Saving recipe: ${recipe.id} for user: $userId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/${recipe.id}?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recipe.toJson()),
      );

      if (_disposed) return;

      if (response.statusCode == 200) {
        _savedRecipeIds.add(recipe.id);
        _savedRecipes[recipe.id] = recipe;
        _cachedRecipes = null;
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
    if (_disposed) return;
    
    try {
      await _ensureInitialized();
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      print('Unsaving recipe: $recipeId for user: $userId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$recipeId?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (_disposed) return;

      if (response.statusCode == 200) {
        _savedRecipeIds.remove(recipeId);
        _savedRecipes.remove(recipeId);
        _cachedRecipes = null;
        notifyListeners();
      } else {
        throw Exception('Failed to unsave recipe: ${response.body}');
      }
    } catch (e) {
      print('Error unsaving recipe: $e');
      rethrow;
    }
  }

  Future<void> resetService() async {
    if (_disposed) return;
    
    try {
      _isInitialized = false;
      _cachedRecipes = null;
      _savedRecipes.clear();
      _savedRecipeIds.clear();
      await _ensureInitialized();
      notifyListeners();
    } catch (e) {
      print('Error resetting SavedRecipeService: $e');
      rethrow;
    }
  }

  void clearCache() {
    if (_disposed) return;
    _cachedRecipes = null;
    notifyListeners();
  }
}