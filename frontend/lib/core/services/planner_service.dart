import 'package:flutter/foundation.dart';
import '../models/planner.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PlannerService with ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  bool _disposed = false;

  PlannerService(this._apiService, this._authService);

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

  Future<List<Planner>> getPlannedMeals(DateTime startDate, DateTime endDate) async {
    try {
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

  Future<void> addToPlan(String recipeId, DateTime plannedDate) async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');
      
      final formattedDate = plannedDate.toIso8601String().split('T')[0];
      
      print('Adding to plan: userId=$userId, recipeId=$recipeId, date=$formattedDate');
      
      final response = await _apiService.post(
        'planner?userId=$userId&recipeId=$recipeId&plannedDate=$formattedDate',
        {}
      );
      
      print('Add to plan response: $response');
      
      if (response == null) {
        throw Exception('Failed to add recipe to plan: No response from server');
      }
      
      // Refresh data and notify listeners
      await getPlannedMeals(plannedDate, plannedDate.add(const Duration(days: 7)));
      notifyListeners();
      
    } catch (e) {
      print('Error adding to plan: $e');
      throw Exception('Failed to add recipe to plan: $e');
    }
  }

  Future<void> removeFromPlan(String plannerId) async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      print('Removing from plan: plannerId=$plannerId');

      final response = await _apiService.delete('planner/$plannerId?userId=$userId');
      
      print('Remove from plan response: $response');

      if (response == null) {
        throw Exception('Failed to remove recipe from plan: No response from server');
      }

      notifyListeners();
    } catch (e) {
      print('Error removing from plan: $e');
      throw Exception('Failed to remove recipe from plan: $e');
    }
  }
}