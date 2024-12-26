import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/saved_recipe_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/recipe.dart';
import '../widgets/recipe_grid_item.dart';
import '../widgets/recipe_details_dialog.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> with AutomaticKeepAliveClientMixin {
  Future<List<Recipe>> _savedRecipesFuture = Future.value([]);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isLoggedIn = await authService.isLoggedIn();
      
      if (!mounted || !isLoggedIn) return;

      final savedRecipeService = Provider.of<SavedRecipeService>(context, listen: false);
      await savedRecipeService.resetService();
      
      if (!mounted) return;

      setState(() {
        _savedRecipesFuture = savedRecipeService.getSavedRecipes().then((recipes) {
          print('Loaded ${recipes.length} saved recipes');
          return recipes;
        }).catchError((error) {
          print('Error loading saved recipes: $error');
          throw error;
        });
      });
    } catch (e) {
      print('Error in initial load: $e');
      if (mounted) {
        setState(() {
          _savedRecipesFuture = Future.error(e);
        });
      }
    }
  }

  Future<void> _refreshSavedRecipes() async {
    if (!mounted) return;
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isLoggedIn = await authService.isLoggedIn();
      
      if (!mounted || !isLoggedIn) return;
      
      final savedRecipeService = Provider.of<SavedRecipeService>(context, listen: false);
      
      setState(() {
        _savedRecipesFuture = savedRecipeService.getSavedRecipes().then((recipes) {
          print('Refreshed ${recipes.length} saved recipes');
          return recipes;
        }).catchError((error) {
          print('Error refreshing saved recipes: $error');
          throw error;
        });
      });
    } catch (e) {
      print('Error in refresh: $e');
      if (mounted) {
        setState(() {
          _savedRecipesFuture = Future.error(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              children: [
                const Text('Saved Recipes'),
              ],
            ),
          ),
        ),
        centerTitle: false,
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSavedRecipes,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSavedRecipes,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshSavedRecipes,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final recipes = snapshot.data ?? [];

                if (recipes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshSavedRecipes,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Text('No saved recipes yet'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => RecipeDetailsDialog(
                              recipe: recipes[index],
                              isSaved: true,
                              onSaveRecipe: (recipe, isSaved) async {
                                Navigator.of(context).pop(); // Tutup dialog
                                if (!mounted) return;
                                
                                try {
                                  final savedRecipeService = Provider.of<SavedRecipeService>(
                                    context, 
                                    listen: false
                                  );
                                  
                                  // Tampilkan loading indicator
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
                                    // Tutup loading indicator
                                    Navigator.of(context).pop();
                                    
                                    // Refresh list untuk menghilangkan resep yang di-unsave
                                    setState(() {
                                      _savedRecipesFuture = Future.value(
                                        recipes.where((r) => r.id != recipe.id).toList()
                                      );
                                    });
                                    
                                    // Tampilkan snackbar konfirmasi
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
                                                  SnackBar(content: Text('Error: $e')),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Tutup loading indicator jika terjadi error
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                        child: RecipeGridItem(
                          recipe: recipes[index],
                          isSaved: true,
                          onSaveRecipe: (recipe, isSaved) async {
                            if (!mounted) return;
                            
                            try {
                              final savedRecipeService = Provider.of<SavedRecipeService>(
                                context, 
                                listen: false
                              );
                              
                              // Tampilkan loading indicator
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
                                // Tutup loading indicator
                                Navigator.of(context).pop();
                                
                                // Refresh list untuk menghilangkan resep yang di-unsave
                                setState(() {
                                  _savedRecipesFuture = Future.value(
                                    recipes.where((r) => r.id != recipe.id).toList()
                                  );
                                });
                                
                                // Tampilkan snackbar konfirmasi
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
                                              SnackBar(content: Text('Error: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Tutup loading indicator jika terjadi error
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}