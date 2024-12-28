import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import 'settings_dialog.dart';

class AccountSettingsDialog extends StatefulWidget {
  const AccountSettingsDialog({super.key});

  @override
  State<AccountSettingsDialog> createState() => _AccountSettingsDialogState();
}

class _AccountSettingsDialogState extends State<AccountSettingsDialog> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _userDataFuture = authService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final userData = snapshot.data ?? {};

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context); // Tutup account settings dialog
                        showDialog(
                          context: context,
                          builder: (context) => const SettingsDialog(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsItem(
                  'Email',
                  userData['email'] ?? 'No email',
                  onTap: () {
                    // Handle email settings
                  },
                ),
                _buildSettingsItem(
                  'Password',
                  'Set a password',
                  onTap: () {
                    // Handle password settings
                  },
                ),
                _buildSettingsItem(
                  'Region',
                  userData['region'] ?? 'United States',
                  onTap: () {
                    // Handle region settings
                  },
                ),
                _buildSettingsItem(
                  'Zip code',
                  userData['zipCode'] ?? 'Zip code is not set',
                  onTap: () {
                    // Handle zip code settings
                  },
                ),
                _buildSettingsItem(
                  'Gender',
                  userData['gender'] ?? 'Male',
                  onTap: () {
                    // Handle gender settings
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Handle delete account
                  },
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String value, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}