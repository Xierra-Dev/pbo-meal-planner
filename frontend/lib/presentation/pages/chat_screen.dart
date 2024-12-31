import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/chat_service.dart';
import '../../core/models/chat_message.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final int userId;

  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);
      
      final history = await _chatService.getChatHistory(widget.userId);
      
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load chat history');
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isLoading = true);
    _messageController.clear();

    try {
      // Add user message immediately
      final userMessage = ChatMessage(
        id: DateTime.now().toIso8601String(),
        userId: widget.userId,
        message: message,
        response: '',
        timestamp: DateTime.now(),
        isUser: true,
      );

      setState(() {
        _messages.add(userMessage);
      });
      _scrollToBottom();

      // Get assistant response
      final assistantMessage = await _chatService.sendMessage(widget.userId, message);
      
      if (mounted) {
        setState(() {
          _messages.add(assistantMessage);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to send message');
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showError(String message) {
    // Implement your error handling logic here
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
    Widget build(BuildContext context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nutriguide Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              
              // Chat messages
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
                ),
              ),

              // Loading indicator
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

              // Input field
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Colors.blue,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
}

