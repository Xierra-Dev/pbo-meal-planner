import 'package:flutter/material.dart';
import '../../core/models/recipe.dart';
import '../../core/services/saved_recipe_service.dart';
import 'recipe_card.dart';
import 'package:provider/provider.dart';

class PopupRecipeGrid extends StatelessWidget {
  final String title;
  final List<Recipe> recipes;

  const PopupRecipeGrid({
    super.key,
    required this.title,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    recipe: recipes[index],
                    titleFontSize: 16,
                    isSaved: context.watch<SavedRecipeService>().isRecipeSaved(recipes[index].id),
                    onSaveRecipe: (recipe, isSaved) async {
                      final savedRecipeService = context.read<SavedRecipeService>();
                      try {
                        if (isSaved) {
                          await savedRecipeService.saveRecipe(recipe);
                        } else {
                          await savedRecipeService.unsaveRecipe(recipe.id);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to ${isSaved ? 'save' : 'unsave'} recipe')),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}