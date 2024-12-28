import 'package:flutter/material.dart';
import '../../core/models/recipe.dart';
import '../../core/services/saved_recipe_service.dart';
import 'recipe_card.dart';
import 'package:provider/provider.dart';
import 'dialogs/recipe_details_dialog.dart';

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
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: GridView.builder(
                shrinkWrap: true,
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
                    onTap: (recipe) {
                      Navigator.pop(context); // Tutup popup grid
                      showDialog(
                        context: context,
                        builder: (context) => RecipeDetailsDialog(
                          recipe: recipe,
                          isSaved: context.read<SavedRecipeService>().isRecipeSaved(recipe.id),
                          onSaveRecipe: (recipe, isSaved) async {
                            final savedRecipeService = context.read<SavedRecipeService>();
                            try {
                              if (isSaved) {
                                await savedRecipeService.saveRecipe(recipe);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Recipe saved successfully'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else {
                                await savedRecipeService.unsaveRecipe(recipe.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Recipe removed from saved'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to ${isSaved ? 'save' : 'unsave'} recipe'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                    onSaveRecipe: (recipe, isSaved) async {
                      final savedRecipeService = context.read<SavedRecipeService>();
                      try {
                        if (!isSaved) {
                          await savedRecipeService.saveRecipe(recipe);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recipe saved successfully'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          await savedRecipeService.unsaveRecipe(recipe.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recipe removed from saved'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to ${!isSaved ? 'save' : 'unsave'} recipe'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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