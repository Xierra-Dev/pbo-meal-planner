import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/planner.dart';
import '../../core/services/planner_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/recipe_details_dialog.dart';
import '../widgets/recipe_card.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late final PlannerService _plannerService;
  Map<DateTime, List<Planner>> _plannedMeals = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _plannerService = Provider.of<PlannerService>(context, listen: false);
    _loadPlannedMeals();
  }

  Future<void> _loadPlannedMeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final startDate = _selectedDate.subtract(const Duration(days: 7));
      final endDate = _selectedDate.add(const Duration(days: 7));
      
      print('Loading meals from $startDate to $endDate');
      
      final plannedMeals = await _plannerService.getPlannedMeals(startDate, endDate);
      
      print('Loaded ${plannedMeals.length} meals');
      
      final groupedMeals = <DateTime, List<Planner>>{};
      for (var meal in plannedMeals) {
        // Normalize both dates to compare only year, month, and day
        final mealDate = DateTime(
          meal.plannedDate.year,
          meal.plannedDate.month,
          meal.plannedDate.day,
        );
        
        print('Processing meal: ${meal.recipe.title} for date $mealDate');
        
        if (!groupedMeals.containsKey(mealDate)) {
          groupedMeals[mealDate] = [];
        }
        groupedMeals[mealDate]!.add(meal);
      }
      
      setState(() {
        _plannedMeals = groupedMeals;
        print('Updated planned meals map with ${groupedMeals.length} dates');
        for (var entry in groupedMeals.entries) {
          print('Date: ${entry.key}, Meals: ${entry.value.length}');
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading meals: $e');
      setState(() {
        _error = 'Failed to load planned meals: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removePlannedMeal(Planner planner) async {
    try {
      await _plannerService.removePlannedMeal(planner); // Changed from removeFromPlan to removePlannedMeal
      _loadPlannedMeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove planned meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlannerService>(
      builder: (context, plannerService, child) {
        if (_isLoading) {
          return const LoadingIndicator(message: 'Loading meal plan...');
        }

        if (_error != null) {
          return ErrorView(
            message: _error!,
            onRetry: _loadPlannedMeals,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    const Text('Meal Planner'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                          _loadPlannedMeals();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: false,
            toolbarHeight: 60,
          ),
          body: RefreshIndicator(
            onRefresh: _loadPlannedMeals,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 15, // Show 15 days
                  itemBuilder: (context, index) {
                    final date = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day + (index - 7),
                    );
                    final meals = _plannedMeals[date] ?? [];
                    print('Building card for date: $date, found ${meals.length} meals');
                    return _buildDayCard(date, meals);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCard(DateTime date, List<Planner> meals) {
    final ScrollController scrollController = ScrollController();
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    void _scrollLeft() {
      scrollController.animateTo(
        scrollController.offset - 300,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    void _scrollRight() {
      scrollController.animateTo(
        scrollController.offset + 300,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isToday ? Colors.blue.shade50 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (meals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'No meals planned',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            SizedBox(
              height: 120, // Increased height
              child: Stack(
                children: [
                  ListView.builder(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Container(
                        width: 320, // Increased width
                        margin: const EdgeInsets.only(right: 16),
                        child: Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => RecipeDetailsDialog(recipe: meal.recipe),
                              );
                            },
                            child: Row(
                              children: [
                                // Recipe image
                                SizedBox(
                                  width: 120, // Increased width
                                  height: 120, // Increased height
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                    child: Image.network(
                                      meal.recipe.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Recipe details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          meal.recipe.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          meal.recipe.category,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Delete button
                                SizedBox(
                                  width: 48,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 24,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removePlannedMeal(meal),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (meals.length > 1) ...[
                    // Left scroll button
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: _scrollLeft,
                          ),
                        ),
                      ),
                    ),
                    // Right scroll button
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.white),
                            onPressed: _scrollRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}