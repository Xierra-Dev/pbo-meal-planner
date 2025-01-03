import 'package:flutter/material.dart';
import '../../core/models/recipe.dart';
import 'package:provider/provider.dart';
import '../../core/services/saved_recipe_service.dart';
import '../../core/services/auth_service.dart';
import '../widgets/dialogs/recipe_save_limit_dialog.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final double titleFontSize;
  final bool isSaved;
  final Function(Recipe)? onTap;
  final Function(Recipe, bool)? onSaveRecipe;
  final bool showSaveButton;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.titleFontSize = 16,
    this.isSaved = false,
    this.onTap,
    this.onSaveRecipe,
    this.showSaveButton = true,
  });

  Color _getHealthScoreColor(double score) {
    if (score >= 7.5) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _handleSaveRecipe(BuildContext context, Recipe recipe, bool isSaved) async {
    try {
      if (!isSaved) {
        // Cek batasan sebelum menyimpan
        final savedRecipeService = Provider.of<SavedRecipeService>(context, listen: false);
        final canSave = await savedRecipeService.canSaveMoreRecipes();
        
        if (!canSave) {
          if (context.mounted) {
            final userType = await Provider.of<AuthService>(context, listen: false).getUserType();
            
            showDialog(
              context: context,
              builder: (context) => RecipeSaveLimitDialog(
                userType: userType ?? 'REGULAR',
              ),
            );
          }
          return;
        }
      }
      
      // Proses save/unsave recipe
      if (onSaveRecipe != null) {
        await onSaveRecipe!(recipe, isSaved);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // Di dalam method build
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap != null ? () => onTap!(recipe) : null,
        child: Stack(
          children: [
            // Recipe Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        recipe.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      // Area Label - Top Left
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recipe.area,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Health Score - Bottom Right
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getHealthScoreColor(recipe.healthScore)
                                .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.healthScore.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Recipe Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          recipe.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Category and Calories
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                recipe.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.local_fire_department_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.nutritionInfo.calories} cal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Save Button
            if (showSaveButton && onSaveRecipe != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: () => _handleSaveRecipe(context, recipe, isSaved),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}