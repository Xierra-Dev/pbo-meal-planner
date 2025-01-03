import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/planner.dart';
import '../../core/services/planner_service.dart';
import '../../core/services/profile_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import 'upgrade_screen.dart';
import '../../core/models/recipe.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;
  Map<DateTime, List<Planner>> _plannedMeals = {};

  @override
  void initState() {
    super.initState();
    _loadPlannedMeals();
  }

    Future<void> _addToPlanner(Recipe recipe) async {
    try {
      final plannedDate = _selectedDate;
      await context.read<PlannerService>().addToPlan(recipe.id, plannedDate, recipe);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe added to planner')),
        );
      }
      _loadPlannedMeals();
    } catch (e) {
      if (e.toString().contains('maximum number of meal plans')) {
        // Show upgrade dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => const Dialog(
              child: UpgradeScreen(),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add recipe: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _loadPlannedMeals() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final startDate = _selectedDate.subtract(const Duration(days: 7));
      final endDate = _selectedDate.add(const Duration(days: 7));
      
      final plannedMeals = await context
          .read<PlannerService>()
          .getPlannedMeals(startDate, endDate);

      final groupedMeals = <DateTime, List<Planner>>{};
      for (var meal in plannedMeals) {
        final date = DateTime(
          meal.plannedDate.year,
          meal.plannedDate.month,
          meal.plannedDate.day,
        );
        
        if (!groupedMeals.containsKey(date)) {
          groupedMeals[date] = [];
        }
        groupedMeals[date]!.add(meal);
      }

      if (mounted) {
        setState(() {
          _plannedMeals = groupedMeals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load planned meals: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePlannedMeal(Planner meal) async {
    try {
      await context.read<PlannerService>().removePlannedMeal(meal);
      _loadPlannedMeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Meal Planner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                              });
                              _loadPlannedMeals();
                            },
                          ),
                          Text(
                            '${DateFormat('MMM d').format(_selectedDate)} - ${DateFormat('MMM d').format(_selectedDate.add(const Duration(days: 6)))}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.add(const Duration(days: 7));
                              });
                              _loadPlannedMeals();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 100),
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
          constraints: const BoxConstraints(maxWidth: 1600),
          child: RefreshIndicator(
            onRefresh: _loadPlannedMeals,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day + index,
                );
                return _buildDayCard(date);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(DateTime date) {
    final meals = _plannedMeals[date] ?? [];
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    
    final ScrollController scrollController = ScrollController();

    void scroll(double offset) {
      scrollController.animateTo(
        scrollController.offset + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    final arrowButtonStyle = BoxDecoration(
      color: Colors.black.withOpacity(0.3),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isToday ? Colors.blue.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (meals.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No meals planned for this day',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: meals.map((meal) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 300,
                          child: MealCard(
                            meal: meal,
                            onDelete: () => _deletePlannedMeal(meal),
                            onToggleComplete: (meal) async {
                              try {
                                // Jika meal sudah completed, kita akan un-complete
                                if (meal.isCompleted) {
                                  await context.read<PlannerService>().toggleMealCompletion(meal);
                                  
                                  if (meal.isToday && context.mounted) {
                                    // Kurangi nutrisi karena meal di-uncomplete
                                    context.read<ProfileService>().updateTodayNutrition(
                                      meal.recipe.nutritionInfo,
                                      false, // false untuk mengurangi nutrisi
                                    );
                                  }
                                } else {
                                  // Jika meal belum completed
                                  await context.read<PlannerService>().toggleMealCompletion(meal);
                                  
                                  if (meal.isToday && context.mounted) {
                                    // Tambah nutrisi karena meal completed
                                    context.read<ProfileService>().updateTodayNutrition(
                                      meal.recipe.nutritionInfo,
                                      true, // true untuk menambah nutrisi
                                    );
                                  }
                                }
                                
                                _loadPlannedMeals();

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        meal.isCompleted ? 'Meal marked as incomplete' : 'Meal marked as complete'
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update meal status: $e'),
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
                            },
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                if (meals.length > 1) ...[
                  Positioned(
                    left: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => scroll(-300),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: arrowButtonStyle,
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => scroll(300),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: arrowButtonStyle,
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}