import 'package:flutter/material.dart';
import 'chat_bot.dart';
import '../pages/upgrade_screen.dart';

class ChatBubbleButton extends StatefulWidget {
  final bool isPremium;
  const ChatBubbleButton({
    super.key, 
    required this.isPremium,
  });

  @override
  State<ChatBubbleButton> createState() => _ChatBubbleButtonState();
}

class _ChatBubbleButtonState extends State<ChatBubbleButton> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned(
            bottom: 80,
            right: 16,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 350,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widget.isPremium
                    ? Stack(
                        children: [
                          const ChatBot(),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _isOpen = false),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Close Button
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _isOpen = false),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Lock Icon
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          
                          // Title
                          const Text(
                            'Access Restricted',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Message
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Chatbot feature is only available for premium users.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Upgrade Button
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _isOpen = false);
                                showDialog(
                                  context: context,
                                  builder: (context) => const Dialog(
                                    child: UpgradeScreen(isDialog: true),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Upgrade to Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                          const Spacer(flex: 2),
                        ],
                      ),
              ),
            ),
          ),

        // Chat Bubble Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => setState(() => _isOpen = !_isOpen),
            backgroundColor: Theme.of(context).primaryColor,
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.chat_bubble_outline),
            ),
          ),
        ),
      ],
    );
  }
}