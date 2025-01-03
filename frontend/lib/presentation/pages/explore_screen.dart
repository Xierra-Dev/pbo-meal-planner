import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/models/recipe.dart';
import '../../core/services/recipe_service.dart';
import '../../core/services/saved_recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/dialogs/recipe_details_dialog.dart';
import 'package:flutter/gestures.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  Timer? _debounce;
  String? _selectedIngredient;

  final ScrollController _ingredientScrollController = ScrollController();

  // Daftar bahan populer dengan icon
  final List<Map<String, dynamic>> _popularIngredients = [
    {
      'name': 'Chicken',
      'icon': Icons.egg_alt_outlined,
    },
    {
      'name': 'Beef',
      'icon': Icons.lunch_dining,
    },
    {
      'name': 'Salmon',
      'icon': Icons.set_meal_outlined,
    },
    {
      'name': 'Rice',
      'icon': Icons.rice_bowl_outlined,
    },
    {
      'name': 'Potato',
      'icon': Icons.breakfast_dining_outlined,
    },
    {
      'name': 'Tomato',
      'icon': Icons.local_florist_outlined,
    },
    {
      'name': 'Egg',
      'icon': Icons.egg_outlined,
    },
    {
      'name': 'Cheese',
      'icon': Icons.local_pizza_outlined,
    },
    {
      'name': 'Garlic',
      'icon': Icons.spa_outlined,
    },
    {
      'name': 'Onion',
      'icon': Icons.radio_button_unchecked_outlined,
    },
    {
      'name': 'Carrot',
      'icon': Icons.eco_outlined,
    },
    {
      'name': 'Spinach',
      'icon': Icons.local_florist_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ingredientScrollController.dispose(); // Tambahkan ini
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await _recipeService.getRandomRecipes(10);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipes: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _selectedIngredient = null;
        _loadRecipes();
        return;
      }

      setState(() => _isLoading = true);
      try {
        final recipes = await _recipeService.searchRecipes(query);
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching recipes: $e')),
          );
        }
      }
    });
  }

  Future<void> _searchByIngredient(String ingredient) async {
    setState(() => _isLoading = true);
    try {
      final recipes = await _recipeService.searchRecipesByIngredient(ingredient);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching recipes: $e')),
        );
      }
    }
  }

  void _showRecipeDetails(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeDetailsDialog(
        recipe: recipe,
        isSaved: context.read<SavedRecipeService>().isRecipeSaved(recipe.id),
        onSaveRecipe: _handleSaveRecipe,
      ),
    );
  }

  Future<void> _handleSaveRecipe(Recipe recipe, bool isSaved) async {
    final savedRecipeService = context.read<SavedRecipeService>();
    try {
      if (!isSaved) {
        await savedRecipeService.saveRecipe(recipe);
        if (mounted) {
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
        if (mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${!isSaved ? 'save' : 'unsave'} recipe'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _selectedIngredient = null;
                                _loadRecipes();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter by Ingredient Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Ingredient',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select an ingredient to find matching recipes',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Popular Ingredients
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      children: [
                        ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: ListView.builder(
                            controller: _ingredientScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _popularIngredients.length,
                            itemBuilder: (context, index) {
                              final ingredient = _popularIngredients[index];
                              final isSelected = _selectedIngredient == ingredient['name'];
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  showCheckmark: false,
                                  avatar: Icon(
                                    ingredient['icon'],
                                    size: 20,
                                    color: isSelected 
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[600],
                                  ),
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      ingredient['name'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedIngredient = ingredient['name'];
                                        _searchController.clear();
                                        _searchByIngredient(ingredient['name']);
                                      } else {
                                        _selectedIngredient = null;
                                        _loadRecipes();
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.grey[100],
                                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected 
                                        ? Theme.of(context).primaryColor
                                        : Colors.black87,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient edges
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Recipe Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _loadRecipes,
                            child: _recipes.isEmpty
                                ? const Center(
                                    child: Text('No recipes found'),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: _recipes.length,
                                    itemBuilder: (context, index) {
                                      return RecipeCard(
                                        recipe: _recipes[index],
                                        titleFontSize: 16,
                                        isSaved: context.watch<SavedRecipeService>().isRecipeSaved(_recipes[index].id),
                                        onTap: (recipe) => _showRecipeDetails(recipe),
                                        onSaveRecipe: _handleSaveRecipe,
                                      );
                                    },
                                  ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}