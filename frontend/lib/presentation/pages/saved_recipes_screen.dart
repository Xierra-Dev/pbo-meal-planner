import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/recipe.dart';
import '../../core/services/saved_recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/dialogs/recipe_details_dialog.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  late Future<List<Recipe>> _savedRecipesFuture;

  @override
  void initState() {
    super.initState();
    _refreshSavedRecipes();
  }

  void _refreshSavedRecipes() {
    final savedRecipeService = context.read<SavedRecipeService>();
    _savedRecipesFuture = savedRecipeService.getSavedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1600), // Sama dengan konten
            child: AppBar(
              automaticallyImplyLeading: false,
              title: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0), // Sama dengan konten
                child: Text('Saved Recipes'),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: FutureBuilder<List<Recipe>>(
              future: _savedRecipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading saved recipes\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshSavedRecipes,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final recipes = snapshot.data ?? [];

                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved recipes yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your saved recipes will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Increased for wider screens
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      isSaved: true,
                      onTap: (recipe) {
                        showDialog(
                          context: context,
                          builder: (context) => RecipeDetailsDialog(
                            recipe: recipe,
                            isSaved: true,
                            onSaveRecipe: (recipe, isSaved) async {
                              try {
                                final savedRecipeService = context.read<SavedRecipeService>();
                                await savedRecipeService.unsaveRecipe(recipe.id);
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  _refreshSavedRecipes();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Recipe removed from saved'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to remove recipe: $e'),
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
                        try {
                          final savedRecipeService = context.read<SavedRecipeService>();
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          
                          // Unsave recipe
                          await savedRecipeService.unsaveRecipe(recipe.id);
                          
                          if (mounted) {
                            // Close loading indicator
                            Navigator.of(context).pop();
                            
                            // Update the list
                            setState(() {
                              _savedRecipesFuture = Future.value(
                                recipes.where((r) => r.id != recipe.id).toList()
                              );
                            });
                            
                            // Show confirmation snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Recipe removed from saved'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () async {
                                    try {
                                      await savedRecipeService.saveRecipe(recipe);
                                      if (mounted) {
                                        _refreshSavedRecipes();
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to restore recipe: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            // Close loading if showing
                            Navigator.of(context).pop();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to remove recipe: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}