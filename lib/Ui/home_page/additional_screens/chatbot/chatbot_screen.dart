import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  static const String routeName = "/chatbot";

  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your learning assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-scroll to bottom when new messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    // Clear input
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Simulate bot response after delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(
          text: _getBotResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  String _getBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hi there! 👋 How can I assist you with your learning today?";
    } else if (lowerMessage.contains('course') ||
        lowerMessage.contains('enroll')) {
      return "You can browse available courses in the Courses tab. Is there a specific topic you're interested in?";
    } else if (lowerMessage.contains('progress') ||
        lowerMessage.contains('track')) {
      return "Your learning progress is tracked in each course. You can view detailed progress in the course details page.";
    } else if (lowerMessage.contains('help') ||
        lowerMessage.contains('support')) {
      return "I'm here to help! You can ask me about courses, learning progress, or general app features.";
    } else if (lowerMessage.contains('thank')) {
      return "You're welcome! 😊 Let me know if you need anything else.";
    } else {
      return "Thanks for your message! I'm here to help with your learning journey. Feel free to ask about courses, progress, or any other questions.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
        title: Text(
          'Codexa Chatbot',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.iconTheme.color,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.cardTheme.color,
                  title: Text(
                    'Clear Chat',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.iconTheme.color,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to clear all messages?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.iconTheme.color,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _messages.clear();
                          _messages.add(ChatMessage(
                            text:
                                "Hello! I'm your learning assistant. How can I help you today?",
                            isUser: false,
                            timestamp: DateTime.now(),
                          ));
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Clear',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.progressIndicatorTheme.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          _buildInputField(theme),
        ],
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _messageController,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.iconTheme.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.progressIndicatorTheme.color,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: theme.iconTheme.color,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: theme.progressIndicatorTheme.color,
                child: Icon(
                  Icons.smart_toy,
                  color: theme.iconTheme.color,
                  size: 16,
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.progressIndicatorTheme.color
                        : theme.cardTheme.color,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft:
                          isUser ? const Radius.circular(20) : Radius.zero,
                      bottomRight:
                          isUser ? Radius.zero : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? theme.iconTheme.color
                          : theme.iconTheme.color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: theme.primaryColor.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: theme.iconTheme.color,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
