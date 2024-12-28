import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/recipe.dart';
import '../../core/services/recipe_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/saved_recipe_service.dart';
import 'explore_screen.dart';
import 'planner_screen.dart';
import 'saved_recipes_screen.dart';
import 'profile_screen.dart';
import 'auth/login_screen.dart';
import '../widgets/recipe_card.dart';
import '../widgets/popup_recipe_grid.dart';
import '../widgets/dialogs/recipe_details_dialog.dart';
import '../widgets/dialogs/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ExploreScreen(),
    const SavedRecipesScreen(),
    const PlannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo dan Nama Aplikasi
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 32,
                          width: 32,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'NutriGuide',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    
                    // Navigation Buttons di tengah
                    Expanded(
                      child: Center(
                        child: NavigationButtons(
                          selectedIndex: _selectedIndex,
                          onIndexChanged: (index) {
                            setState(() => _selectedIndex = index);
                          },
                        ),
                      ),
                    ),

                    // Profile Menu with Arrow
                    PopupMenuButton(
                      offset: const Offset(0, 40),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 15,
                            backgroundImage: AssetImage('assets/images/profile.jpg'),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline),
                              const SizedBox(width: 8),
                              const Text('Profile'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.settings_outlined),
                              const SizedBox(width: 8),
                              const Text('Settings'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 10), () {
                              showDialog(
                                context: context,
                                builder: (context) => const SettingsDialog(),
                              );
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Logout', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () async {
                            final authService = Provider.of<AuthService>(context, listen: false);
                            await authService.logout();
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _screens[_selectedIndex],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ScrollController _recommendedController = ScrollController();
  final ScrollController _popularController = ScrollController();

  void _scrollLeft(ScrollController controller) {
    controller.animateTo(
      controller.offset - 500,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight(ScrollController controller) {
    controller.animateTo(
      controller.offset + 500,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _recommendedController.dispose();
    _popularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recommended Section
                _buildSectionHeader(
                  context,
                  title: 'Recommended',
                  onSeeAll: () {
                    final recipes = context.read<RecipeService>().getRecommendedRecipes(6);
                    showDialog(
                      context: context,
                      builder: (context) => FutureBuilder<List<Recipe>>(
                        future: recipes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return PopupRecipeGrid(
                            title: 'Recommended Recipes',
                            recipes: snapshot.data ?? [],
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 380,
                  child: Stack(
                    children: [
                      Consumer<RecipeService>(
                        builder: (context, recipeService, child) {
                          return FutureBuilder<List<Recipe>>(
                            future: recipeService.getRecommendedRecipes(7),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final recipes = snapshot.data ?? [];
                              return GridView.builder(
                                controller: _recommendedController,
                                scrollDirection: Axis.horizontal,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1.15,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: recipes.length,
                                itemBuilder: (context, index) {
                                  return RecipeCard(
                                    recipe: recipes[index],
                                    titleFontSize: 16,
                                    isSaved: context.watch<SavedRecipeService>().isRecipeSaved(recipes[index].id),
                                    onTap: (recipe) {
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
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      Positioned.fill(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 8),
                              alignment: Alignment.centerLeft,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: () => _scrollLeft(_recommendedController),
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.only(right: 8),
                              alignment: Alignment.centerRight,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () => _scrollRight(_recommendedController),
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Popular Section
                _buildSectionHeader(
                  context,
                  title: 'Popular',
                  onSeeAll: () {
                    final recipes = context.read<RecipeService>().getPopularRecipes(6);
                    showDialog(
                      context: context,
                      builder: (context) => FutureBuilder<List<Recipe>>(
                        future: recipes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return PopupRecipeGrid(
                            title: 'Popular Recipes',
                            recipes: snapshot.data ?? [],
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 380,
                  child: Stack(
                    children: [
                      Consumer<RecipeService>(
                        builder: (context, recipeService, child) {
                          return FutureBuilder<List<Recipe>>(
                            future: recipeService.getPopularRecipes(7),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final recipes = snapshot.data ?? [];
                              return GridView.builder(
                                controller: _popularController,
                                scrollDirection: Axis.horizontal,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1.15,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: recipes.length,
                                itemBuilder: (context, index) {
                                  return RecipeCard(
                                    recipe: recipes[index],
                                    titleFontSize: 16,
                                    isSaved: context.watch<SavedRecipeService>().isRecipeSaved(recipes[index].id),
                                    onTap: (recipe) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => RecipeDetailsDialog(
                                          recipe: recipe,
                                          isSaved: context.read<SavedRecipeService>().isRecipeSaved(recipe.id),
                                          onSaveRecipe: (recipe, isSaved) async {
                                            // Same save recipe handler as above
                                            final savedRecipeService = context.read<SavedRecipeService>();
                                            try {
                                              if (isSaved) {
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
                                      // Same save recipe handler as above
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
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      Positioned.fill(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 8),
                              alignment: Alignment.centerLeft,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: () => _scrollLeft(_popularController),
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.only(right: 8),
                              alignment: Alignment.centerRight,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () => _scrollRight(_popularController),
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Recipe Feed
                const Text(
                  'Recipe Feed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<RecipeService>(
                  builder: (context, recipeService, child) {
                    return FutureBuilder<List<Recipe>>(
                      future: recipeService.getRandomRecipes(2),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final recipes = snapshot.data ?? [];
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
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
                                showDialog(
                                  context: context,
                                  builder: (context) => RecipeDetailsDialog(
                                    recipe: recipe,
                                    isSaved: context.read<SavedRecipeService>().isRecipeSaved(recipe.id),
                                    onSaveRecipe: (recipe, isSaved) async {
                                      // Same save recipe handler as above
                                      final savedRecipeService = context.read<SavedRecipeService>();
                                      try {
                                        if (isSaved) {
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
                                // Same save recipe handler as above
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
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }
}

class NavigationButtons extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const NavigationButtons({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavButton(
            icon: Icons.home_outlined,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          _NavButton(
            icon: Icons.explore_outlined,
            label: 'Explore',
            isSelected: selectedIndex == 1,
            onTap: () => onIndexChanged(1),
          ),
          _NavButton(
            icon: Icons.bookmark_outline,
            label: 'Saved',
            isSelected: selectedIndex == 2,
            onTap: () => onIndexChanged(2),
          ),
          _NavButton(
            icon: Icons.calendar_today_outlined,
            label: 'Planner',
            isSelected: selectedIndex == 3,
            onTap: () => onIndexChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}