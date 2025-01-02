import 'package:flutter/material.dart';
import '../pages/chat_screen.dart';

class ChatFloatingButton extends StatelessWidget {
  final int userId;
  final String currentRole;

  const ChatFloatingButton({
    Key? key,
    required this.userId,
    required this.currentRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (context) => Stack(
                  children: [
                    Positioned(
                      right: 16,
                      bottom: 100, // Position above the FAB
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.6,
                          constraints: BoxConstraints(
                            maxWidth: 400, // Maximum width for larger screens
                          ),
                          child: ChatScreen(userId: userId),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.chat),
            backgroundColor: currentRole == 'premium_user' ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}
