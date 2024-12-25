import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/saved_recipe_service.dart';
import '../../core/models/recipe.dart';
import '../widgets/recipe_grid_item.dart';

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
    _savedRecipesFuture = context.read<SavedRecipeService>().getSavedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: Consumer<SavedRecipeService>(
        builder: (context, savedRecipeService, child) {
          return FutureBuilder<List<Recipe>>(
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
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _savedRecipesFuture = savedRecipeService.getSavedRecipes();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final recipes = snapshot.data ?? [];

              if (recipes.isEmpty) {
                return const Center(
                  child: Text('No saved recipes yet'),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeGridItem(
                      recipe: recipes[index],
                      isSaved: true,
                      onSaveRecipe: (recipe, isSaved) async {
                        if (!isSaved) {
                          await savedRecipeService.unsaveRecipe(recipe.id);
                          setState(() {
                            _savedRecipesFuture = savedRecipeService.getSavedRecipes();
                          });
                        }
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}