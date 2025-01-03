import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/recipe.dart';
import 'auth_service.dart';
import 'dart:async';

class SavedRecipeService with ChangeNotifier {
  final String baseUrl = '${ApiConstants.baseUrl}/saved-recipes';
  final AuthService _authService;
  bool _disposed = false;
  bool _isInitialized = false;

  Timer? _debounceTimer;
  DateTime? _lastFetch;
  static const fetchCooldown = Duration(seconds: 5); // Minimal jarak antar fetch

  final Map<String, Recipe> _savedRecipes = {};
  final Set<String> _savedRecipeIds = {};
  List<Recipe>? _cachedRecipes;

  SavedRecipeService(this._authService);

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
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

  Future<bool> canSaveMoreRecipes() async {
    try {
      final userType = await _authService.getUserType();
      if (userType == 'PREMIUM') return true;

      // Untuk user regular, cek jumlah resep yang sudah disimpan
      final savedRecipes = await getSavedRecipes();
      return savedRecipes.length < 10; // Batasan untuk user regular
    } catch (e) {
      print('Error checking save limit: $e');
      return false;
    }
  }

  Future<List<Recipe>> getSavedRecipes() async {
    if (_disposed) return [];
    
    // Cek apakah sudah waktunya fetch lagi
    if (_lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < fetchCooldown) {
      return _cachedRecipes ?? [];
    }
    
    try {
      await _ensureInitialized();
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      _lastFetch = DateTime.now();
      final response = await http.get(
        Uri.parse('$baseUrl?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

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

      // Cek batasan sebelum menyimpan
      final canSave = await canSaveMoreRecipes();
      if (!canSave) {
        throw Exception('You have reached the maximum limit of saved recipes. Upgrade to Premium to save more!');
      }
      
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