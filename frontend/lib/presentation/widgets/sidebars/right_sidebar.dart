import 'package:flutter/material.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTipCard(
                'Store herbs in water to keep them fresh longer',
                Icons.eco,
              ),
              _buildTipCard(
                'Pat meat dry before cooking for better browning',
                Icons.restaurant_menu,
              ),
              _buildTipCard(
                'Room temperature eggs work best for baking',
                Icons.cake,
              ),
              _buildTipCard(
                'Sharpen knives regularly for safer cooking',
                Icons.cut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.amber[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}