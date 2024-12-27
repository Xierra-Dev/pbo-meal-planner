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
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (meals.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No meals planned'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Stack(
                    children: [
                      RecipeCard(
                        recipe: meal.recipe,
                        onTap: (recipe) {
                          showDialog(
                            context: context,
                            builder: (context) => RecipeDetailsDialog(recipe: meal.recipe),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _removePlannedMeal(meal),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}