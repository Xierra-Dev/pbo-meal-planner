import 'package:flutter/material.dart';
import '../../presentation/pages/home_screen.dart';
import '../../presentation/pages/auth/login_screen.dart';
import '../../presentation/pages/auth/register_screen.dart';
import '../../presentation/pages/admin/admin_login.dart';
import '../../presentation/pages/admin/admin_dashboard.dart';

class Routes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      adminLogin: (context) => const AdminLoginScreen(),
      adminDashboard: (context) => const AdminDashboard(),
    };
  }
}