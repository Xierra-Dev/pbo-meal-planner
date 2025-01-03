import 'package:flutter/material.dart';
import 'preferences_dialog.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/config/dio_config.dart';

class PersonalizedGoalsDialog extends StatefulWidget {
  const PersonalizedGoalsDialog({super.key});

  @override
  State<PersonalizedGoalsDialog> createState() => _PersonalizedGoalsDialogState();
}

class _PersonalizedGoalsDialogState extends State<PersonalizedGoalsDialog> {
  late PreferencesService _preferencesService;
  bool _isLoading = false;
  UserPreferences? _preferences;

  final List<GoalItem> _goals = [
    GoalItem(
      title: 'Weight Loss',
      description: 'Achieve and maintain a healthy weight',
      icon: Icons.fitness_center,
    ),
    GoalItem(
      title: 'Get Healthier',
      description: 'Improve overall health and wellness',
      icon: Icons.favorite,
    ),
    GoalItem(
      title: 'Look Better',
      description: 'Enhance physical appearance',
      icon: Icons.face,
    ),
    GoalItem(
      title: 'Reduce Stress',
      description: 'Manage and lower stress levels',
      icon: Icons.spa,
    ),
    GoalItem(
      title: 'Sleep Better',
      description: 'Improve sleep quality',
      icon: Icons.nightlight_round,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  // Di _HealthDataDialogState, _PersonalizedGoalsDialogState, dan _AllergiesDialogState
  Future<void> _initializeService() async {
    final userId = await AuthService().getCurrentUserId();
    if (userId != null) {
      final dio = createDio();
      _preferencesService = PreferencesService(dio, userId);
      _loadGoals(); // _loadHealthData() atau _loadGoals() atau _loadAllergies()
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
      }
    }
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      _preferences = await _preferencesService.getPreferences();
      
      // Mark goals as selected if they exist in preferences
      for (var goal in _goals) {
        goal.isSelected = _preferences?.goals.contains(goal.title) ?? false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load goals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveGoals() async {
    final selectedGoals = _goals
        .where((goal) => goal.isSelected)
        .map((goal) => goal.title)
        .toList();

    if (selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one goal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _preferencesService.savePreferences(UserPreferences(
        healthData: _preferences?.healthData,
        goals: selectedGoals,
        allergies: _preferences?.allergies ?? [],
      ));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goals saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save goals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: screenSize.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenSize.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        showDialog(
                          context: context,
                          builder: (context) => const PreferencesDialog(),
                          barrierDismissible: true,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Personalized Goals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Select your health and wellness goals',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: _goals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildGoalItem(goal),
                  )).toList(),
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGoals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(GoalItem goal) {
    return InkWell(
      onTap: () {
        setState(() {
          goal.isSelected = !goal.isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: goal.isSelected ? Colors.deepPurple.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: goal.isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: goal.isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                goal.icon,
                color: goal.isSelected ? Colors.deepPurple : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: goal.isSelected,
              onChanged: (value) {
                setState(() {
                  goal.isSelected = value ?? false;
                });
              },
              activeColor: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}

class GoalItem {
  final String title;
  final String description;
  final IconData icon;
  bool isSelected;

  GoalItem({
    required this.title,
    required this.description,
    required this.icon,
    this.isSelected = false,
  });
}