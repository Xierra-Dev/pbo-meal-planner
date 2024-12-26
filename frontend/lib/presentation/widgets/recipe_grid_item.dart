import 'package:flutter/material.dart';
import '../../core/models/recipe.dart';

class RecipeGridItem extends StatelessWidget {
  final Recipe recipe;
  final bool isSaved;
  final Function(Recipe, bool) onSaveRecipe;

  const RecipeGridItem({
    super.key,
    required this.recipe,
    required this.isSaved,
    required this.onSaveRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image dan konten lainnya
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  recipe.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Tombol Save/Unsave
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () => onSaveRecipe(recipe, isSaved),
              ),
            ),
          ),
        ],
      ),
    );
  }
}