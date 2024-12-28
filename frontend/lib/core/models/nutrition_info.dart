import 'dart:math';

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double totalFat;
  final double saturatedFat;
  final double sugars;
  final double sodium;
  final double fiber;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.totalFat,
    required this.saturatedFat,
    required this.sugars,
    required this.sodium,
    required this.fiber,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      saturatedFat: (json['saturatedFat'] as num).toDouble(),
      sugars: (json['sugars'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
    );
  }

  factory NutritionInfo.generateRandom() {
    final random = Random();
    return NutritionInfo(
      calories: 200 + random.nextInt(800).toDouble(),
      protein: 5 + random.nextInt(45).toDouble(),
      carbs: 10 + random.nextInt(90).toDouble(),
      totalFat: 5 + random.nextInt(45).toDouble(),
      saturatedFat: 2 + random.nextInt(18).toDouble(),
      sugars: 2 + random.nextInt(28).toDouble(),
      sodium: 100 + random.nextInt(900).toDouble(),
      fiber: 1 + random.nextInt(14).toDouble(),
    );
  }

  factory NutritionInfo.zero() {
    return const NutritionInfo(
      calories: 0,
      protein: 0,
      carbs: 0,
      totalFat: 0,
      saturatedFat: 0,
      sugars: 0,
      sodium: 0,
      fiber: 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'totalFat': totalFat,
    'saturatedFat': saturatedFat,
    'sugars': sugars,
    'sodium': sodium,
    'fiber': fiber,
  };

  NutritionInfo copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? totalFat,
    double? saturatedFat,
    double? sugars,
    double? sodium,
    double? fiber,
  }) {
    return NutritionInfo(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      totalFat: totalFat ?? this.totalFat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      sugars: sugars ?? this.sugars,
      sodium: sodium ?? this.sodium,
      fiber: fiber ?? this.fiber,
    );
  }

  NutritionInfo operator +(NutritionInfo other) {
    return NutritionInfo(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      totalFat: totalFat + other.totalFat,
      saturatedFat: saturatedFat + other.saturatedFat,
      sugars: sugars + other.sugars,
      sodium: sodium + other.sodium,
      fiber: fiber + other.fiber,
    );
  }

  NutritionInfo operator -(NutritionInfo other) {
    return NutritionInfo(
      calories: max(0, calories - other.calories),
      protein: max(0, protein - other.protein),
      carbs: max(0, carbs - other.carbs),
      totalFat: max(0, totalFat - other.totalFat),
      saturatedFat: max(0, saturatedFat - other.saturatedFat),
      sugars: max(0, sugars - other.sugars),
      sodium: max(0, sodium - other.sodium),
      fiber: max(0, fiber - other.fiber),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NutritionInfo &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.totalFat == totalFat &&
        other.saturatedFat == saturatedFat &&
        other.sugars == sugars &&
        other.sodium == sodium &&
        other.fiber == fiber;
  }

  @override
  int get hashCode {
    return Object.hash(
      calories,
      protein,
      carbs,
      totalFat,
      saturatedFat,
      sugars,
      sodium,
      fiber,
    );
  }

  @override
  String toString() {
    return 'NutritionInfo(calories: $calories, protein: ${protein}g, carbs: ${carbs}g, fat: ${totalFat}g)';
  }

  // Helper methods untuk persentase daily value berdasarkan 2000 calorie diet
  double get proteinDV => (protein / 50) * 100;
  double get carbsDV => (carbs / 300) * 100;
  double get totalFatDV => (totalFat / 65) * 100;
  double get saturatedFatDV => (saturatedFat / 20) * 100;
  double get sugarsDV => (sugars / 50) * 100;
  double get sodiumDV => (sodium / 2300) * 100;
  double get fiberDV => (fiber / 25) * 100;
}