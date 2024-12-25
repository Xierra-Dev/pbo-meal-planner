import 'package:flutter/foundation.dart';
import '../models/planner.dart';
import 'api_service.dart';

class PlannerService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Future<List<Planner>> getPlannedMeals(DateTime startDate, DateTime endDate) async {
    try {
      final response = await _apiService.get(
        'planner?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'
      );
      return (response as List).map((json) => Planner.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching planned meals: $e');
      return [];
    }
  }

  Future<void> addToPlan(String recipeId, DateTime plannedDate) async {
    await _apiService.post('planner', {
      'recipeId': recipeId,
      'plannedDate': plannedDate.toIso8601String(),
    });
  }

  Future<void> removeFromPlan(String plannerId) async {
    await _apiService.delete('planner/$plannerId');
  }
}