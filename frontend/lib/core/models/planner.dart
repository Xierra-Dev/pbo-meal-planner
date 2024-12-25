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
    return Planner(
      id: json['id'].toString(),
      recipe: Recipe.fromJson(json['recipe']),
      plannedDate: DateTime.parse(json['plannedDate']),
    );
  }
}