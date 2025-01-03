import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import 'home_screen.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isInitializing = true;
        _error = null;
      });

      // Tunggu minimal 2 detik untuk splash screen
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final authService = context.read<AuthService>();
      
      // Initialize auth first
      await authService.initializeAuth();
      final isLoggedIn = await authService.isLoggedIn();
      print('Auth check - isLoggedIn: $isLoggedIn');

      if (!mounted) return;

      if (isLoggedIn) {
        final userId = await authService.getCurrentUserId();
        print('Current userId: $userId');
      }

      // Navigate to appropriate screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const HomeScreen() : const LandingScreen(),
        ),
      );
    } catch (e) {
      print('Error initializing app: $e');
      if (!mounted) return;
      
      setState(() {
        _isInitializing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.restaurant,
                  size: 150,
                  color: Colors.green,
                );
              },
            ),
            const SizedBox(height: 20),
            if (_isInitializing) 
              const CircularProgressIndicator()
            else if (_error != null)
              Column(
                children: [
                  Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeApp,
                    child: const Text('Retry'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}