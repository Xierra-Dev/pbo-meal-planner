import 'recipe.dart';

class Planner {
  final String id;
  final Recipe recipe;
  final DateTime plannedDate;

  Planner({
    required this.id,
    required this.recipe,
    required this.plannedDate,
  });

  factory Planner.fromJson(Map<String, dynamic> json) {
    print('Parsing planner JSON: $json');
    try {
      return Planner(
        id: json['id'].toString(),
        recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
        plannedDate: DateTime.parse(json['plannedDate']),
      );
    } catch (e) {
      print('Error parsing planner: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipe': recipe.toJson(),
    'plannedDate': plannedDate.toIso8601String(),
  };

  @override
  String toString() {
    return 'Planner{id: $id, recipe: ${recipe.title}, plannedDate: $plannedDate}';
  }
}