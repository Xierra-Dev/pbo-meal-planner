import 'package:flutter/foundation.dart';
import '../models/nutrition_info.dart';
import 'dart:math' show max;

class ProfileService extends ChangeNotifier {
  NutritionInfo _todayNutrition = NutritionInfo(
    calories: 0,
    protein: 0,
    carbs: 0,
    totalFat: 0,
    saturatedFat: 0,
    sugars: 0,
    sodium: 0,
    fiber: 0,
  );
  
  NutritionInfo get todayNutrition => _todayNutrition;

  void updateTodayNutrition(NutritionInfo mealNutrition, bool isCompleted) {
    if (isCompleted) {
      // Add nutrition
      _todayNutrition = NutritionInfo(
        calories: _todayNutrition.calories + mealNutrition.calories,
        protein: _todayNutrition.protein + mealNutrition.protein,
        carbs: _todayNutrition.carbs + mealNutrition.carbs,
        totalFat: _todayNutrition.totalFat + mealNutrition.totalFat,
        saturatedFat: _todayNutrition.saturatedFat + mealNutrition.saturatedFat,
        sugars: _todayNutrition.sugars + mealNutrition.sugars,
        sodium: _todayNutrition.sodium + mealNutrition.sodium,
        fiber: _todayNutrition.fiber + mealNutrition.fiber,
      );
    } else {
      // Subtract nutrition
      _todayNutrition = NutritionInfo(
        calories: max(0, _todayNutrition.calories - mealNutrition.calories),
        protein: max(0, _todayNutrition.protein - mealNutrition.protein),
        carbs: max(0, _todayNutrition.carbs - mealNutrition.carbs),
        totalFat: max(0, _todayNutrition.totalFat - mealNutrition.totalFat),
        saturatedFat: max(0, _todayNutrition.saturatedFat - mealNutrition.saturatedFat),
        sugars: max(0, _todayNutrition.sugars - mealNutrition.sugars),
        sodium: max(0, _todayNutrition.sodium - mealNutrition.sodium),
        fiber: max(0, _todayNutrition.fiber - mealNutrition.fiber),
      );
    }
    notifyListeners();
  }

  void resetTodayNutrition() {
    _todayNutrition = NutritionInfo(
      calories: 0,
      protein: 0,
      carbs: 0,
      totalFat: 0,
      saturatedFat: 0,
      sugars: 0,
      sodium: 0,
      fiber: 0,
    );
    notifyListeners();
  }

  // Method untuk menyimpan nutrisi ke local storage
  Future<void> saveTodayNutrition() async {
    // Implementasi penyimpanan ke local storage
  }

  // Method untuk memuat nutrisi dari local storage
  Future<void> loadTodayNutrition() async {
    // Implementasi loading dari local storage
  }
}