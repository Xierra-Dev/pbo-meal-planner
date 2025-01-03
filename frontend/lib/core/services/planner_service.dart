import 'package:flutter/foundation.dart';
import '../models/planner.dart';
import '../models/recipe.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PlannerService with ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  bool _disposed = false;

  DateTime? _lastFetch;
  List<Planner>? _cachedMeals;
  static const fetchCooldown = Duration(seconds: 5);

  PlannerService(this._apiService, this._authService) {
    // Listen to auth state changes
    _authService.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  Future<List<Planner>> getPlannedMeals(DateTime startDate, DateTime endDate) async {
    try {
      // Cek apakah sudah waktunya fetch lagi
      if (_lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < fetchCooldown) {
        return _cachedMeals ?? [];
      }

      await _authService.isInitialized;
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      _lastFetch = DateTime.now();
      final response = await _apiService.get(
        'planner?userId=$userId&startDate=$startDateStr&endDate=$endDateStr'
      );
      
      if (response == null) return [];
      
      // Handle ApiResponse wrapper
      final apiResponse = response as Map<String, dynamic>;
      if (!apiResponse['success']) {
        throw Exception(apiResponse['message']);
      }
      
      final data = apiResponse['data'] as List;
      final meals = data.map((json) => Planner.fromJson(json)).toList();
      
      if (!_disposed) {
        _cachedMeals = meals;
        notifyListeners();
      }
      
      return meals;
    } catch (e) {
      print('Error fetching planned meals: $e');
      return _cachedMeals ?? [];
    }
  }

  Future<void> addToPlan(String recipeId, DateTime plannedDate, Recipe recipe) async {
    try {
      await _authService.isInitialized;
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');
      
      final formattedDate = plannedDate.toIso8601String().split('T')[0];
      
      print('Recipe data being sent: ${recipe.toJson()}');
      
      final response = await _apiService.post(
        'planner?userId=$userId&recipeId=$recipeId&plannedDate=$formattedDate',
        {
          'recipe': recipe.toJson()
        }
      );
      
      print('Add to plan response: $response');
      
      if (response == null) {
        throw Exception('Failed to add recipe to plan');
      }
      
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error adding to plan: $e');
      rethrow;
    }
  }

  Future<void> removePlannedMeal(Planner meal) async {
    try {
      await _authService.isInitialized;
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      await _apiService.delete('planner/${meal.id}?userId=$userId');
      
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error removing planned meal: $e');
      rethrow;
    }
  }

    Future<void> toggleMealCompletion(Planner meal) async {
    try {
      await _authService.isInitialized;
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      print('Sending completion toggle request:');
      print('URL: planner/${meal.id}/toggle-completion');
      print('Data: userId=$userId, completed=${!meal.isCompleted}');

      // Remove duplicate /api/ prefix
      final response = await _apiService.patch(
        'planner/${meal.id}/toggle-completion?userId=$userId&completed=${!meal.isCompleted}',
        {} // empty body
      );
      
      print('Toggle completion response: $response');
      
      if (response == null) {
        throw Exception('Failed to update meal completion status');
      }
      
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling meal completion: $e');
      rethrow;
    }
  }

  Future<List<Planner>> getTodayMeals() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return getPlannedMeals(today, today);
  }

  Future<bool> isMealPlanned(String recipeId, DateTime date) async {
    try {
      final meals = await getPlannedMeals(date, date);
      return meals.any((meal) => meal.recipe.id == recipeId);
    } catch (e) {
      print('Error checking if meal is planned: $e');
      return false;
    }
  }
}