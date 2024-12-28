import 'package:flutter/material.dart';
import 'preferences_dialog.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/config/dio_config.dart';

class AllergiesDialog extends StatefulWidget {
  const AllergiesDialog({super.key});

  @override
  State<AllergiesDialog> createState() => _AllergiesDialogState();
}

class _AllergiesDialogState extends State<AllergiesDialog> {
  late PreferencesService _preferencesService;
  bool _isLoading = false;
  UserPreferences? _preferences;

  final List<AllergyItem> _allergies = [
    AllergyItem(
      name: 'Dairy',
      icon: Icons.local_drink,
      examples: 'Milk, cheese, yogurt',
    ),
    AllergyItem(
      name: 'Eggs',
      icon: Icons.egg,
      examples: 'Chicken eggs, duck eggs',
    ),
    AllergyItem(
      name: 'Fish',
      icon: Icons.set_meal,
      examples: 'Salmon, tuna, cod',
    ),
    AllergyItem(
      name: 'Shellfish',
      icon: Icons.restaurant,
      examples: 'Shrimp, crab, lobster',
    ),
    AllergyItem(
      name: 'Tree Nuts',
      icon: Icons.grass,
      examples: 'Almonds, walnuts, cashews',
    ),
    AllergyItem(
      name: 'Peanuts',
      icon: Icons.food_bank,
      examples: 'Peanut butter, peanut oil',
    ),
    AllergyItem(
      name: 'Wheat',
      icon: Icons.grain,
      examples: 'Bread, pasta, cereals',
    ),
    AllergyItem(
      name: 'Soy',
      icon: Icons.eco,
      examples: 'Tofu, soy sauce, edamame',
    ),
    AllergyItem(
      name: 'Gluten',
      icon: Icons.bakery_dining,
      examples: 'Wheat, barley, rye',
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
      _loadAllergies(); // _loadHealthData() atau _loadGoals() atau _loadAllergies()
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
      }
    }
  }

  Future<void> _loadAllergies() async {
    setState(() => _isLoading = true);
    try {
      _preferences = await _preferencesService.getPreferences();
      
      // Mark allergies as selected if they exist in preferences
      for (var allergy in _allergies) {
        allergy.isSelected = _preferences?.allergies.contains(allergy.name) ?? false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load allergies: $e'),
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

  Future<void> _saveAllergies() async {
    setState(() => _isLoading = true);
    try {
      final selectedAllergies = _allergies
          .where((allergy) => allergy.isSelected)
          .map((allergy) => allergy.name)
          .toList();

      await _preferencesService.savePreferences(UserPreferences(
        healthData: _preferences?.healthData,
        goals: _preferences?.goals ?? [],
        allergies: selectedAllergies,
      ));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Allergies saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save allergies: $e'),
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                  'Allergies',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select any food allergies you have',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _allergies.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildAllergyItem(_allergies[index]);
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAllergies,
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
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyItem(AllergyItem allergy) {
    return InkWell(
      onTap: () {
        setState(() {
          allergy.isSelected = !allergy.isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: allergy.isSelected ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: allergy.isSelected ? Colors.red : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: allergy.isSelected ? Colors.red.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                allergy.icon,
                color: allergy.isSelected ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allergy.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    allergy.examples,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: allergy.isSelected,
              onChanged: (value) {
                setState(() {
                  allergy.isSelected = value ?? false;
                });
              },
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class AllergyItem {
  final String name;
  final IconData icon;
  final String examples;
  bool isSelected;

  AllergyItem({
    required this.name,
    required this.icon,
    required this.examples,
    this.isSelected = false,
  });
}