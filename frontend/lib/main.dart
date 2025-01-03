import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/saved_recipe_service.dart';
import 'core/services/planner_service.dart';
import 'core/services/recipe_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/admin_service.dart';
import 'core/routes/routes.dart';
import 'core/guards/admin_guards.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/admin/admin_dashboard.dart';
import 'presentation/pages/admin/admin_login.dart';
import 'core/services/api_service.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<RecipeService>(
          create: (_) => RecipeService(),
        ),
        ChangeNotifierProvider<SavedRecipeService>(
          create: (context) => SavedRecipeService(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<PlannerService>(
          create: (context) => PlannerService(
            context.read<ApiService>(),
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<ProfileService>(
          create: (_) => ProfileService(),
        ),
        Provider<AdminService>(
          create: (_) => AdminService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutriguide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
          titleLarge: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.grey[800],
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle admin routes with guard
        if (settings.name == Routes.adminDashboard) {
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<bool>(
              future: AdminGuard.canActivate(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.data == true) {
                  return const AdminDashboard();
                }
                
                return const AdminLoginScreen();
              },
            ),
          );
        }

        // Handle other routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case Routes.adminLogin:
            return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
          default:
            // Handle unknown routes
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('Route ${settings.name} not found'),
                ),
              ),
            );
        }
      },
    );
  }
}