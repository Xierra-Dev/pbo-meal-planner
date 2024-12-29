import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'package:nutriguide/utils/page_transitions.dart';
import 'package:nutriguide/utils/navigation_helper.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  String _activeSection = 'home';

  final Map<String, double> _sectionOffsets = {
    'home': 0,
    'features': 600,
    'contact': 1200,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset >= 300;
        if (_scrollController.offset < _sectionOffsets['features']!) {
          _activeSection = 'home';
        } else if (_scrollController.offset < _sectionOffsets['contact']!) {
          _activeSection = 'features';
        } else {
          _activeSection = 'contact';
        }
      });
    });

    // Add scroll end detector
    _scrollController.addListener(() {
      if (!_scrollController.position.isScrollingNotifier.value) {
        _handleScrollEnd();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    final double offset = _sectionOffsets[section]!;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _handleScrollEnd() {
    final double offset = _scrollController.offset;
    String targetSection = 'home';
    
    for (var entry in _sectionOffsets.entries) {
      if ((offset - entry.value).abs() < (offset - _sectionOffsets[targetSection]!).abs()) {
        targetSection = entry.key;
      }
    }
    
    _scrollToSection(targetSection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          scrollbars: true,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          controller: _scrollController,
          child: Column(
            children: [
              // Hero Section dengan background image dan gradient overlay
              Container(
                height: 800,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/hero-bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Navigation Bar with transparent background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo dan Nama
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 32,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'NutriGuide',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          // Login/Register Buttons
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => NavigationHelper.navigateToPage(
                                  context,
                                  const LoginScreen(),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Login'),
                              ),

                              ElevatedButton(
                                onPressed: () => NavigationHelper.navigateToPage(
                                  context,
                                  const RegisterScreen(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue[900],
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Get Started'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Hero Content
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Your Personal\nNutrition Guide',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Discover healthy recipes, plan your meals,\nand track your nutrition journey',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () => NavigationHelper.navigateToPage(
                                context,
                                const RegisterScreen(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Start Your Journey'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Features Section dengan cards yang lebih menarik
              Container(
                padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      'Why Choose NutriGuide?',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 64),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.restaurant_menu,
                          title: 'Recipe Discovery',
                          description:
                              'Explore thousands of healthy recipes tailored to your preferences',
                          color: Colors.blue[700]!,
                        ),
                        _buildFeatureCard(
                          icon: Icons.calendar_today,
                          title: 'Meal Planning',
                          description:
                              'Plan your meals for the week ahead with smart suggestions',
                          color: Colors.green[700]!,
                        ),
                        _buildFeatureCard(
                          icon: Icons.track_changes,
                          title: 'Nutrition Tracking',
                          description:
                              'Monitor your daily nutrition intake with detailed insights',
                          color: Colors.orange[700]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                color: Colors.blue[900],
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'Made with Struggle 🥵',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[900],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          '@NutriGuide Team',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              onPressed: () => _scrollToSection('home'),
              mini: true,
              backgroundColor: Colors.blue[900],
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}