import 'package:flutter/material.dart';
import '../../core/models/recipe.dart';
import 'recipe_details_dialog.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool showSaveButton;
  final bool isExpanded;
  final double imageHeight;
  final double titleFontSize;
  final Function(Recipe)? onTap;
  final Function(Recipe, bool)? onSaveRecipe;
  final bool isSaved;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.showSaveButton = true,
    this.isExpanded = false,
    this.imageHeight = 200,
    this.titleFontSize = 16,
    this.onTap,
    this.onSaveRecipe,
    this.isSaved = false,
  });

  void _showRecipeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RecipeDetailsDialog(
        recipe: recipe,
        isSaved: isSaved,
        onSaveRecipe: onSaveRecipe,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(recipe);
        } else {
          _showRecipeDetails(context);
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4/3,
                  child: Image.network(
                    recipe.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
                // Area Label
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recipe.area ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (showSaveButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Theme.of(context).primaryColor : Colors.grey[700],
                        ),
                        onPressed: () {
                          if (onSaveRecipe != null) {
                            onSaveRecipe!(recipe, !isSaved);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.ingredients.length} ingredients',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '30 min',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}