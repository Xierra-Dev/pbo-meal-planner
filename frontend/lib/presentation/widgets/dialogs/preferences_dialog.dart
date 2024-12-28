import 'package:flutter/material.dart';
import 'settings_dialog.dart';
import 'health_data_dialog.dart';
import 'personalized_goals_dialog.dart';
import 'allergies_dialog.dart';

class PreferencesDialog extends StatelessWidget {
  const PreferencesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          showDialog(
                            context: context,
                            builder: (context) => const SettingsDialog(),
                            barrierDismissible: true,
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildPreferenceItem(
              context,
              'Health Data',
              'Set your physical characteristics',
              Icons.favorite,
              () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const HealthDataDialog(),
                  barrierDismissible: true,
                );
              },
            ),
            const SizedBox(height: 12),
            _buildPreferenceItem(
              context,
              'Personalized Goals',
              'Define your nutrition goals',
              Icons.track_changes,
              () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const PersonalizedGoalsDialog(),
                  barrierDismissible: true,
                );
              },
            ),
            const SizedBox(height: 12),
            _buildPreferenceItem(
              context,
              'Allergies',
              'Manage your food allergies',
              Icons.warning_amber,
              () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const AllergiesDialog(),
                  barrierDismissible: true,
                );
              },
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}