import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/planner.dart';
import '../../core/services/planner_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final PlannerService _plannerService = PlannerService();
  Map<DateTime, List<Planner>> _plannedMeals = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
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
      final plannedMeals = await _plannerService.getPlannedMeals(startDate, endDate);
      
      final groupedMeals = <DateTime, List<Planner>>{};
      for (var meal in plannedMeals) {
        final date = DateTime(
          meal.plannedDate.year,
          meal.plannedDate.month,
          meal.plannedDate.day,
        );
        groupedMeals.putIfAbsent(date, () => []).add(meal);
      }
      
      setState(() {
        _plannedMeals = groupedMeals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load planned meals: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removePlannedMeal(Planner planner) async {
    try {
      await _plannerService.removeFromPlan(planner.id);
      _loadPlannedMeals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove planned meal')),
      );
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
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
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
      body: ListView.builder(
        itemCount: 15, // Show 15 days
        itemBuilder: (context, index) {
          final date = _selectedDate.add(Duration(days: index - 7));
          final meals = _plannedMeals[date] ?? [];
          return _buildDayCard(date, meals);
        },
      ),
    );
  }

  Widget _buildDayCard(DateTime date, List<Planner> meals) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              DateFormat('EEEE, MMMM d').format(date),
              style: Theme.of(context).textTheme.titleLarge,
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
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(meals[index].recipe.thumbnailUrl),
                ),
                title: Text(meals[index].recipe.title),
                subtitle: Text(meals[index].recipe.category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removePlannedMeal(meals[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}