import 'package:flutter/foundation.dart';
import '../models/planner.dart';
import '../models/recipe.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PlannerService with ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  bool _disposed = false;

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
      // Wait for auth to be initialized
      await _authService.isInitialized;
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      print('Fetching planned meals: userId=$userId, startDate=$startDateStr, endDate=$endDateStr');

      final response = await _apiService.get(
        'planner?userId=$userId&startDate=$startDateStr&endDate=$endDateStr'
      );
      
      print('Planner API Response: $response');

      if (response == null) return [];
      
      final meals = (response as List).map((json) => Planner.fromJson(json)).toList();
      print('Parsed ${meals.length} planned meals');
      print('Meals data: $meals');
      
      return meals;
    } catch (e) {
      print('Error fetching planned meals: $e');
      return [];
    }
  }

  Future<void> addToPlan(String recipeId, DateTime plannedDate, Recipe recipe) async {
    try {
      // Wait for auth to be initialized
      await _authService.isInitialized;
      
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');
      
      final formattedDate = plannedDate.toIso8601String().split('T')[0];
      
      print('Adding to plan: userId=$userId, recipeId=$recipeId, date=$formattedDate');
      
      final response = await _apiService.post(
        'planner?userId=$userId&recipeId=$recipeId&plannedDate=$formattedDate',
        {
          'recipe': recipe.toJson(),
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
}