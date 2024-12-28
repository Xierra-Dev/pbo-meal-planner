import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';
import 'account_settings_dialog.dart';
import 'edit_profile_dialog.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
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
                _buildSettingsItem(
                  'Account',
                  userData['email'] ?? 'No email',
                  onTap: () {
                    Navigator.pop(context); // Close settings dialog
                    showDialog(
                      context: context,
                      builder: (context) => const AccountSettingsDialog(),
                    );
                  },
                ),
                _buildSettingsItem(
                  'Profile',
                  userData['username'] ?? '',
                  onTap: () {
                    Navigator.pop(context); // Close settings dialog
                    showDialog(
                      context: context,
                      builder: (context) => EditProfileDialog(
                        onProfileUpdated: () {
                          // Refresh settings dialog after profile update
                          showDialog(
                            context: context,
                            builder: (context) => const SettingsDialog(),
                          );
                        },
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  'Preferences',
                  '',
                  onTap: () {
                    // Handle preferences
                  },
                ),
                _buildSettingsItem(
                  'Notifications',
                  '',
                  onTap: () {
                    // Handle notifications
                  },
                ),
                _buildSettingsItem(
                  'About Nutriguide',
                  '',
                  onTap: () {
                    // Handle about
                  },
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
    String subtitle, {
    IconData? icon,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          trailing: icon != null 
              ? Icon(icon, color: Colors.grey)
              : const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(height: 1),
      ],
    );
  }
}