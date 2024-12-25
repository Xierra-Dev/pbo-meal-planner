import 'package:flutter/material.dart';
import '../../core/models/recipe.dart';
import 'recipe_card.dart';

class AllRecipesDialog extends StatelessWidget {
  final String title;
  final List<Recipe> recipes;
  final Function(Recipe, bool) onSaveRecipe;
  final Function(String) isRecipeSaved;

  const AllRecipesDialog({
    super.key,
    required this.title,
    required this.recipes,
    required this.onSaveRecipe,
    required this.isRecipeSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1000,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeCard(
                      recipe: recipes[index],
                      titleFontSize: 14,
                      isSaved: isRecipeSaved(recipes[index].id),
                      onSaveRecipe: onSaveRecipe,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}