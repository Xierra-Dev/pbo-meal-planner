import 'package:flutter/material.dart';
import '../pages/chat_screen.dart';

class ChatFloatingButton extends StatelessWidget {
  final String userId;

  const ChatFloatingButton({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ChatScreen(userId: userId),
        );
      },
      child: Icon(Icons.chat),
      backgroundColor: Colors.blue,
    );
  }
}