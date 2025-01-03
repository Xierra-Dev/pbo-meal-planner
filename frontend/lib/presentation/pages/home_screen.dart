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
import '../widgets/chat_bubble_button.dart';
import '../widgets/sidebars/left_sidebar.dart';
import '../widgets/sidebars/right_sidebar.dart';


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
    final authService = Provider.of<AuthService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
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
                    PopupMenuButton<String>(
                      offset: const Offset(0, 8),
                      position: PopupMenuPosition.under,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundImage: AssetImage('assets/images/profile.jpg'),
                            ),
                            const SizedBox(width: 8),
                            FutureBuilder<String?>(
                              future: authService.getUsername(),
                              builder: (context, snapshot) => Row(
                                children: [
                                  Text(
                                    snapshot.data ?? 'Guest',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  if (authService.isPremiumUser())
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.amber[200]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star, color: Colors.amber[700], size: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            'PREMIUM',
                                            style: TextStyle(
                                              color: Colors.amber[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        // Profile Item
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'View your profile',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Settings Item
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.settings_outlined,
                                    color: Colors.purple[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Settings',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Customize your preferences',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        const PopupMenuDivider(),
                        // Logout Item
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Sign out from your account',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onSelected: (String value) {
                        switch (value) {
                          case 'profile':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                            break;
                          case 'settings':
                            showDialog(
                              context: context,
                              builder: (context) => const SettingsDialog(),
                            );
                            break;
                          case 'logout':
                            authService.logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                            break;
                        }
                      },
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
      body: Stack(
        children: [
          // Sidebars Container
          if (screenWidth > 1200)
            Row(
              children: [
                // Left Sidebar - Fixed position
                const SizedBox(
                  width: 250,
                  child: LeftSidebar(),
                ),
                
                // Spacer for main content
                const Spacer(),
                
                // Right Sidebar - Fixed position
                const SizedBox(
                  width: 250,
                  child: RightSidebar(),
                ),
              ],
            ),
            
          // Main Content - Scrollable
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth > 1200 ? 300 : 0,
              right: screenWidth > 1200 ? 300 : 0,
            ),
            child: _screens[_selectedIndex],
          ),

          // Chat Bubble
          Consumer<AuthService>(
            builder: (context, authService, _) {
              final bool isPremium = authService.isPremiumUser();
              return ChatBubbleButton(isPremium: isPremium);
            },
          ),
        ],
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

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          
          // Main content
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
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
                                          onTap: (recipe) => _showRecipeDetails(context, recipe),
                                          onSaveRecipe: (recipe, isSaved) => _handleSaveRecipe(context, recipe, isSaved),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            _buildScrollButtons(_recommendedController),
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
                                          onTap: (recipe) => _showRecipeDetails(context, recipe),
                                          onSaveRecipe: (recipe, isSaved) => _handleSaveRecipe(context, recipe, isSaved),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            _buildScrollButtons(_popularController),
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
                                    onTap: (recipe) => _showRecipeDetails(context, recipe),
                                    onSaveRecipe: (recipe, isSaved) => _handleSaveRecipe(context, recipe, isSaved),
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
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeDetailsDialog(
        recipe: recipe,
        isSaved: context.read<SavedRecipeService>().isRecipeSaved(recipe.id),
        onSaveRecipe: (recipe, isSaved) => _handleSaveRecipe(context, recipe, isSaved),
      ),
    );
  }

  Future<void> _handleSaveRecipe(BuildContext context, Recipe recipe, bool isSaved) async {
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

  Widget _buildScrollButtons(ScrollController controller) {
    return Positioned.fill(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _scrollLeft(controller),
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
                onPressed: () => _scrollRight(controller),
                color: Colors.black87,
              ),
            ),
          ),
        ],
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