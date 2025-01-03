import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/recipe.dart';
import '../../../core/services/planner_service.dart';
import '../../../core/services/saved_recipe_service.dart';

class RecipeDetailsDialog extends StatefulWidget {
  final Recipe recipe;
  final bool isSaved;
  final Function(Recipe, bool)? onSaveRecipe;

  const RecipeDetailsDialog({
    super.key,
    required this.recipe,
    this.isSaved = false,
    this.onSaveRecipe,
  });

  @override
  State<RecipeDetailsDialog> createState() => _RecipeDetailsDialogState();
}

class _RecipeDetailsDialogState extends State<RecipeDetailsDialog> {
  late bool _isSaved;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  void _showSuccessNotification(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSaveRecipe() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final savedRecipeService = Provider.of<SavedRecipeService>(
        context, 
        listen: false
      );
      
      if (_isSaved) {
        await savedRecipeService.unsaveRecipe(widget.recipe.id);
        if (mounted) {
          setState(() {
            _isSaved = false;
            _isProcessing = false;
          });
          _showSuccessNotification('Recipe removed from saved');
        }
      } else {
        await savedRecipeService.saveRecipe(widget.recipe);
        if (mounted) {
          setState(() {
            _isSaved = true;
            _isProcessing = false;
          });
          _showSuccessNotification('Recipe saved successfully');
        }
      }

      // Hapus callback ini karena menyebabkan double action
      // if (widget.onSaveRecipe != null && mounted) {
      //   widget.onSaveRecipe!(widget.recipe, _isSaved);
      // }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isSaved ? 'unsave' : 'save'} recipe: $e'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    try {
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (selectedDate != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final plannerService = context.read<PlannerService>();
        await plannerService.addToPlan(widget.recipe.id, selectedDate, widget.recipe);
        
        if (mounted) {
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Recipe planned for ${DateFormat('EEEE, MMMM d').format(selectedDate)}'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to plan recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 7.5) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildNutritionItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image and Close Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    widget.recipe.thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Health Score
                    Text(
                      'Health Score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: widget.recipe.healthScore / 10,
                              backgroundColor: Colors.grey[200],
                              color: _getHealthScoreColor(widget.recipe.healthScore),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.recipe.healthScore.toStringAsFixed(1)} / 10',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Nutrition Information
                    Text(
                      'Nutrition Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildNutritionItem('Calories', '${widget.recipe.nutritionInfo.calories} kcal'),
                            const Divider(),
                            _buildNutritionItem('Total Fat', '${widget.recipe.nutritionInfo.totalFat}g'),
                            const Divider(),
                            _buildNutritionItem('Saturated Fat', '${widget.recipe.nutritionInfo.saturatedFat}g'),
                            const Divider(),
                            _buildNutritionItem('Carbs', '${widget.recipe.nutritionInfo.carbs}g'),
                            const Divider(),
                            _buildNutritionItem('Sugars', '${widget.recipe.nutritionInfo.sugars}g'),
                            const Divider(),
                            _buildNutritionItem('Protein', '${widget.recipe.nutritionInfo.protein}g'),
                            const Divider(),
                            _buildNutritionItem('Sodium', '${widget.recipe.nutritionInfo.sodium}mg'),
                            const Divider(),
                            _buildNutritionItem('Fiber', '${widget.recipe.nutritionInfo.fiber}g'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ingredients
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.recipe.ingredients?.length ?? 0,
                      itemBuilder: (context, index) {
                        final ingredient = widget.recipe.ingredients?[index] ?? '';
                        final measure = index < (widget.recipe.measures?.length ?? 0) 
                            ? widget.recipe.measures![index] 
                            : '';

                        if (ingredient.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$measure $ingredient'.trim(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Instructions
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.recipe.instructions,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _handleSaveRecipe,
                      icon: _isProcessing 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                          ),
                      label: Text(_isSaved ? 'Saved' : 'Save Recipe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDatePicker(context),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Plan Recipe'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}