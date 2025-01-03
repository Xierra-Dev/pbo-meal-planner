import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminGuard {
  static Future<bool> canActivate(BuildContext context) async {
    final adminService = AdminService();
    
    try {
      // Implementasi pengecekan session admin
      // Contoh sederhana, sesuaikan dengan kebutuhan
      final isAdmin = await adminService.checkAdminSession();
      
      if (!isAdmin) {
        // Redirect ke halaman login admin jika bukan admin
        Navigator.of(context).pushReplacementNamed('/admin/login');
        return false;
      }
      
      return true;
    } catch (e) {
      Navigator.of(context).pushReplacementNamed('/admin/login');
      return false;
    }
  }
}