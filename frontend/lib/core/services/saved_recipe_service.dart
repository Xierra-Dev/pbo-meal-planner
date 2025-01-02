import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/recipe.dart';
import 'auth_service.dart';

class SavedRecipeService with ChangeNotifier {
  final String baseUrl = '${ApiConstants.baseUrl}/api/saved-recipes';
  final AuthService _authService;
  bool _disposed = false;
  bool _isInitialized = false;
  String? _token;

  final Map<String, Recipe> _savedRecipes = {};
  final Set<String> _savedRecipeIds = {};
  List<Recipe>? _cachedRecipes;

  SavedRecipeService(this._authService);

  Future<String?> get token async {
    if (_token == null) {
      _token = await _authService.getToken();
    }
    return _token;
  }

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

      final currentToken = await token;
      if (currentToken == null) throw Exception('No authentication token available');

      print('Fetching saved recipes for user: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      print('Save recipes response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> recipeData = responseData['data'];
          final recipes = recipeData.map((json) => Recipe.fromJson(json)).toList();
          
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
        throw Exception(responseData['message'] ?? 'Unknown error occurred');
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

      final currentToken = await token;
      if (currentToken == null) throw Exception('No authentication token available');

      print('Saving recipe: ${recipe.id} for user: $userId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/save'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
        body: json.encode({
          'userId': int.parse(userId), // Pastikan userId dikonversi ke integer
          'recipeId': recipe.id,
          'recipeDto': recipe.toJson(),
        }),
      );

      if (_disposed) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          _savedRecipeIds.add(recipe.id);
          _savedRecipes[recipe.id] = recipe;
          _cachedRecipes = null;
          notifyListeners();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to save recipe');
        }
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

      final currentToken = await token;
      if (currentToken == null) throw Exception('No authentication token available');

      print('Unsaving recipe: $recipeId for user: $userId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/unsave?userId=$userId&recipeId=$recipeId'), // Ubah endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
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