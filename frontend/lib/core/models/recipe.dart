class Recipe {
  final String id;
  final String externalId;
  final String title;
  final String category;
  final String thumbnailUrl;
  final String instructions;
  final List<String> ingredients;
  final List<String> measures;
  final String area;

  Recipe({
    required this.id,
    required this.externalId,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
    required this.instructions,
    required this.ingredients,
    required this.measures,
    required this.area,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalId': externalId,
      'title': title,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'instructions': instructions,
      'ingredients': ingredients,
      'measures': measures,
      'area': area,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      externalId: json['externalId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      instructions: json['instructions'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      measures: List<String>.from(json['measures'] ?? []),
      area: json['area'] ?? '',
    );
  }

  factory Recipe.fromMealDB(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    for (var i = 1; i <= 20; i++) {
      if (json['strIngredient$i'] != null && json['strIngredient$i'].toString().isNotEmpty) {
        ingredients.add(json['strIngredient$i']);
        measures.add(json['strMeasure$i'] ?? '');
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      externalId: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      ingredients: ingredients,
      measures: measures,
      area: json['strArea'] ?? '',
    );
  }
}