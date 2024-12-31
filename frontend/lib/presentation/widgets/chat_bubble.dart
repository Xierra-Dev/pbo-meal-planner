import 'package:flutter/material.dart';
import '../../core/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.isUser ? message.message : message.response,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}