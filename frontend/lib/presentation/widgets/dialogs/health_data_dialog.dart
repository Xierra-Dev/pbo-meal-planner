import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'preferences_dialog.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/config/dio_config.dart';

class HealthDataDialog extends StatefulWidget {
  const HealthDataDialog({super.key});

  @override
  State<HealthDataDialog> createState() => _HealthDataDialogState();
}

class _HealthDataDialogState extends State<HealthDataDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSex;
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedActivity;
  late PreferencesService _preferencesService;
  bool _isLoading = false;
  UserPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final userId = await AuthService().getCurrentUserId();
    if (userId != null) {
      final dio = createDio();
      _preferencesService = PreferencesService(dio, userId);
      _loadHealthData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
      }
    }
  }

  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);
    try {
      _preferences = await _preferencesService.getPreferences();
      if (_preferences?.healthData != null) {
        setState(() {
          _selectedSex = _preferences!.healthData!.sex;
          _yearController.text = _preferences!.healthData!.birthYear?.toString() ?? '';
          _heightController.text = _preferences!.healthData!.height?.toString() ?? '';
          _weightController.text = _preferences!.healthData!.weight?.toString() ?? '';
          _selectedActivity = _preferences!.healthData!.activityLevel;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load health data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveHealthData() async {
    print('Saving health data...'); // Debug print
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final healthData = HealthData(
          sex: _selectedSex!,
          birthYear: int.parse(_yearController.text),
          height: int.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          activityLevel: _selectedActivity!,
        );
        
        print('Health data to be sent: $healthData'); // Debug print
        
        final preferences = UserPreferences(
          healthData: healthData,
          goals: [], // Ubah dari null ke empty list
          allergies: [], // Ubah dari null ke empty list
        );
        
        await _preferencesService.savePreferences(preferences);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Health data saved successfully'), backgroundColor: Colors.green,),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error saving health data: $e'); // Debug print
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save health data: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  final List<HealthDataItem> _sexOptions = [
    HealthDataItem(
      title: 'Male',
      icon: Icons.male,
      description: 'Select if you identify as male',
    ),
    HealthDataItem(
      title: 'Female',
      icon: Icons.female,
      description: 'Select if you identify as female',
    ),
  ];

  final List<HealthDataItem> _activityLevels = [
    HealthDataItem(
      title: 'Sedentary',
      icon: Icons.weekend,
      description: 'Little or no exercise',
    ),
    HealthDataItem(
      title: 'Lightly Active',
      icon: Icons.directions_walk,
      description: 'Light exercise 1-3 days/week',
    ),
    HealthDataItem(
      title: 'Moderately Active',
      icon: Icons.directions_run,
      description: 'Moderate exercise 3-5 days/week',
    ),
    HealthDataItem(
      title: 'Very Active',
      icon: Icons.fitness_center,
      description: 'Hard exercise 6-7 days/week',
    ),
    HealthDataItem(
      title: 'Extra Active',
      icon: Icons.sports_gymnastics,
      description: 'Very hard exercise & physical job',
    ),
  ];

  @override
  void dispose() {
    _yearController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Health Data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sex',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sexOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildSelectionItem(
                      _sexOptions[index],
                      isSelected: _selectedSex == _sexOptions[index].title,
                      onTap: () {
                        setState(() {
                          _selectedSex = _sexOptions[index].title;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  title: 'Year of Birth',
                  controller: _yearController,
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your birth year';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > DateTime.now().year) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  title: 'Height',
                  controller: _heightController,
                  icon: Icons.height,
                  suffix: 'cm',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    final height = int.tryParse(value);
                    if (height == null || height < 50 || height > 300) {
                      return 'Please enter a valid height';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  title: 'Weight',
                  controller: _weightController,
                  icon: Icons.monitor_weight,
                  suffix: 'kg',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 20 || weight > 500) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Activity Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activityLevels.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildSelectionItem(
                      _activityLevels[index],
                      isSelected: _selectedActivity == _activityLevels[index].title,
                      onTap: () {
                        setState(() {
                          _selectedActivity = _activityLevels[index].title;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveHealthData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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
        ),
      ),
    );
  }

  Widget _buildSelectionItem(
    HealthDataItem item, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: isSelected ? Colors.deepPurple : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
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

  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    String? suffix,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ],
    );
  }
}

class HealthDataItem {
  final String title;
  final IconData icon;
  final String description;

  HealthDataItem({
    required this.title,
    required this.icon,
    required this.description,
  });
}