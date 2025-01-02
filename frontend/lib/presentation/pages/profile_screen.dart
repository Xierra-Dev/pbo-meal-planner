import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/profile_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;
  String _username = '';
  Map<String, dynamic> _profileData = {};
  bool _isLoading = false;
  String? _currentRole;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadProfileData();
    _loadUserRole();
  }

  Future<void> _loadProfileData() async {
  try {
    setState(() {
      _isLoading = true;
    });
    final userId = await _authService.getCurrentUserId();
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      if (mounted) {
        setState(() {
          _profileData = profile;
          _isLoading = false;
        });
      }
    } else {
      throw Exception('User ID not found');
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _loadUserRole() async {
    try {
      final authService = context.read<AuthService>();
      final currentRole = await authService.getCurrentUserRole();

      print('Received userId from AuthService: $currentRole' );
      
      if (mounted) {
        setState(() {
          _currentRole = currentRole;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getUsername();
    if (mounted) {
      setState(() {
        _username = username ?? 'User';
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      // Navigate to login screen or handle logout
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout')),
        );
      }
    }
  }

  // Tambahkan method untuk menampilkan dialog
  void _showEditProfileDialog(BuildContext context) async {
    // Get current profile data
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return;

    try {
      final profile = await _authService.getUserProfile(userId);
      
      // Initialize controllers with current values
      final TextEditingController firstNameController = TextEditingController(text: profile['firstName'] ?? '');
      final TextEditingController lastNameController = TextEditingController(text: profile['lastName'] ?? '');
      final TextEditingController usernameController = TextEditingController(text: profile['username'] ?? '');
      final TextEditingController bioController = TextEditingController(text: profile['bio'] ?? '');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Fields
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: bioController,
                    maxLength: 255,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Ambil nilai dari controllers
                          final updatedProfile = {
                            'firstName': firstNameController.text,
                            'lastName': lastNameController.text,
                            'username': usernameController.text,
                            'bio': bioController.text,
                          };
                          
                          // Panggil API untuk update profile
                          await _authService.updateProfile(updatedProfile);
                          
                          // Refresh profile data
                          await _loadUsername();
                          
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated successfully')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update profile')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator()) : 
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Profile Info
              // Di dalam build method, bagian Profile Info
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _profileData['username'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            if (_currentRole == 'premium_user')
                              const Padding(
                                padding: EdgeInsets.only(
                                  left: 5,
                                  bottom: 2.75,
                                  ),
                                child: Icon(
                                  Icons.star,
                                  color: Color.fromARGB(255, 227, 175, 1),
                                  size: 26.5,
                                ),
                              ),
                          ],
                        ),
                        if (_profileData['firstName'] != null || _profileData['lastName'] != null)
                          Text(
                            '${_profileData['firstName'] ?? ''} ${_profileData['lastName'] ?? ''}'.trim(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        if (_profileData['bio'] != null && _profileData['bio'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _profileData['bio'],
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showEditProfileDialog(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Daily Nutrition Goals Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your daily nutrition goals',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Balanced macros',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _NutritionItem(
                              label: 'Cal',
                              value: '1766',
                              color: Colors.blue[400]!,
                            ),
                            _NutritionItem(
                              label: 'Carbs',
                              value: '274g',
                              color: Colors.orange[400]!,
                            ),
                            _NutritionItem(
                              label: 'Fiber',
                              value: '30g',
                              color: Colors.green[400]!,
                            ),
                            _NutritionItem(
                              label: 'Protein',
                              value: '79g',
                              color: Colors.pink[400]!,
                            ),
                            _NutritionItem(
                              label: 'Fat',
                              value: '39g',
                              color: Colors.purple[400]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Today's Nutrition Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Nutrition",
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.refresh,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                // Refresh nutrition data
                                context.read<ProfileService>().resetTodayNutrition();
                              },
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nutrition Goals Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<ProfileService>(
                              builder: (context, profileService, _) => _NutritionItem(
                                label: 'Cal',
                                value: '${profileService.todayNutrition.calories.toInt()}',
                                color: Colors.blue[400]!,
                              ),
                            ),
                            Consumer<ProfileService>(
                              builder: (context, profileService, _) => _NutritionItem(
                                label: 'Carbs',
                                value: '${profileService.todayNutrition.carbs.toInt()}g',
                                color: Colors.orange[400]!,
                              ),
                            ),
                            Consumer<ProfileService>(
                              builder: (context, profileService, _) => _NutritionItem(
                                label: 'Fiber',
                                value: '${profileService.todayNutrition.fiber.toInt()}g',
                                color: Colors.green[400]!,
                              ),
                            ),
                            Consumer<ProfileService>(
                              builder: (context, profileService, _) => _NutritionItem(
                                label: 'Protein',
                                value: '${profileService.todayNutrition.protein.toInt()}g',
                                color: Colors.pink[400]!,
                              ),
                            ),
                            Consumer<ProfileService>(
                              builder: (context, profileService, _) => _NutritionItem(
                                label: 'Fat',
                                value: '${profileService.todayNutrition.totalFat.toInt()}g',
                                color: Colors.purple[400]!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Progress Bars
                        Consumer<ProfileService>(
                          builder: (context, profileService, _) => Column(
                            children: [
                              _NutritionProgressBar(
                                label: 'Calories',
                                current: profileService.todayNutrition.calories,
                                target: 1766,
                                unit: 'kcal',
                                color: Colors.blue[400]!,
                              ),
                              const SizedBox(height: 12),
                              _NutritionProgressBar(
                                label: 'Carbs',
                                current: profileService.todayNutrition.carbs,
                                target: 274,
                                unit: 'g',
                                color: Colors.orange[400]!,
                              ),
                              const SizedBox(height: 12),
                              _NutritionProgressBar(
                                label: 'Fiber',
                                current: profileService.todayNutrition.fiber,
                                target: 30,
                                unit: 'g',
                                color: Colors.green[400]!,
                              ),
                              const SizedBox(height: 12),
                              _NutritionProgressBar(
                                label: 'Protein',
                                current: profileService.todayNutrition.protein,
                                target: 79,
                                unit: 'g',
                                color: Colors.pink[400]!,
                              ),
                              const SizedBox(height: 12),
                              _NutritionProgressBar(
                                label: 'Fat',
                                current: profileService.todayNutrition.totalFat,
                                target: 39,
                                unit: 'g',
                                color: Colors.purple[400]!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _NutritionProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;

  const _NutritionProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            Text(
              '$current/$target $unit',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}