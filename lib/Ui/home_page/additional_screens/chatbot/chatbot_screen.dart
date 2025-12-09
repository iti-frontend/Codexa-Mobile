import 'package:codexa_mobile/Data/models/chat_message.dart';
import 'package:codexa_mobile/Data/services/audio_service.dart';
import 'package:codexa_mobile/Data/services/audio_recorder_service.dart';
import 'package:codexa_mobile/Data/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

class ChatbotScreen extends StatefulWidget {
  static const String routeName = "/chatbot";

  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late ChatService _chatService;
  final AudioService _audioService = AudioService();
  final AudioRecorderService _audioRecorder = AudioRecorderService();

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isTyping = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;
  bool _hasMicrophonePermission = false;
  bool _checkingPermission = false;
  bool _permissionRequested = false;
  bool _isLoadingGreeting = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();

    // Add welcome message
    _messages.add(ChatMessage(
      text: "Loading...",
      isUser: false,
      timestamp: DateTime.now(),
    ));

    // Fetch initial greeting from API
    _fetchInitialGreeting();
    // Check permission status (but don't request yet)
    _checkPermissionStatus();
  }


  Future<void> _initializeServices() async {
    try {
      // Initialize ChatService
      print('Initializing ChatService...');
      _chatService = await ChatService.create();
      print('ChatService initialized successfully');

      // Check permission status
      await _checkPermissionStatus();

      // Fetch initial greeting from API
      await _fetchInitialGreeting();
    } catch (e) {
      print('Failed to initialize services: $e');
      if (mounted) {
        setState(() {
          _isLoadingGreeting = false;
          _messages.add(ChatMessage(
            text: "...",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  Future<void> _fetchInitialGreeting() async {
    try {
      print('Fetching initial greeting...');
      final greeting = await _chatService.getInitialGreeting();

      if (mounted) {
        setState(() {
          // Replace the loading message with the actual greeting
          if (_messages.isNotEmpty) {
            _messages.removeLast();
          }
          _messages.add(ChatMessage(
            text: greeting,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      print('Failed to fetch initial greeting: $e');
      if (mounted) {
        setState(() {
          // Fallback to default greeting
          if (_messages.isNotEmpty) {
            _messages.removeLast();
          }
          _messages.add(ChatMessage(
            text: "...",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }


  Future<void> _checkPermissionStatus() async {
    try {
      setState(() => _checkingPermission = true);

      final permissionStatus = await Permission.microphone.status;

      print('Current permission status: $permissionStatus');

      if (permissionStatus.isGranted) {
        _hasMicrophonePermission = true;
        // Initialize recorder if permission is granted
        await _audioRecorder.initialize();
        print('Audio recorder initialized successfully');
      } else if (permissionStatus.isPermanentlyDenied) {
        _hasMicrophonePermission = false;
        print('Permission permanently denied');
      } else {
        _hasMicrophonePermission = false;
        print('Permission not granted');
      }
    } catch (e) {
      print('Permission check failed: $e');
      _hasMicrophonePermission = false;
    } finally {
      if (mounted) {
        setState(() => _checkingPermission = false);
      }
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    try {
      setState(() => _permissionRequested = true);

      final status = await Permission.microphone.request();

      print('Permission request result: $status');

      if (status.isGranted) {
        setState(() => _hasMicrophonePermission = true);
        // Initialize recorder after getting permission
        await _audioRecorder.initialize();
        _showSnackBar('Microphone permission granted! You can now record voice messages.');
        return true;
      } else if (status.isPermanentlyDenied) {
        _showPermissionWarning();
        return false;
      } else {
        _showSnackBar('Microphone permission is required to record voice messages.');
        return false;
      }
    } catch (e) {
      print('Permission request error: $e');
      _showSnackBar('Failed to request microphone permission.');
      return false;
    } finally {
      if (mounted) {
        setState(() => _permissionRequested = false);
      }
    }
  }

  void _showPermissionWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Codexa needs access to your microphone to record voice messages.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'To enable microphone access:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Tap "Open Settings"'),
            Text('2. Go to Permissions'),
            Text('3. Enable Microphone'),
            Text('4. Return to the app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    _audioService.dispose();
    super.dispose();
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

  // Toggle recording with permission check
  void _toggleRecording() async {
    if (_isProcessing) {
      _showSnackBar('Please wait while processing completes');
      return;
    }

    // Check permission first
    if (!_hasMicrophonePermission) {
      // Don't proceed - user needs to grant permission first
      return;
    }

    if (!_isRecording) {
      // Start recording
      try {
        print('Attempting to start recording...');
        final filePath = await _audioRecorder.startRecording();

        if (filePath != null) {
          setState(() {
            _isRecording = true;
            _recordingDuration = Duration.zero;
          });

          // Start updating duration
          _startDurationTimer();

          print('Recording started successfully');
        } else {
          _showError('Failed to start recording');
        }
      } catch (e) {
        print('Recording error: $e');
        _showError('Failed to start recording: ${e.toString()}');
      }
    } else {
      // Stop recording
      _stopDurationTimer();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      try {
        print('Attempting to stop recording...');
        final filePath = await _audioRecorder.stopRecording();

        if (filePath != null) {
          final audioFile = File(filePath);
          if (await audioFile.exists()) {
            await _processAudioRecording(filePath);
          } else {
            _showError('Audio file not found');
            setState(() => _isProcessing = false);
          }
        } else {
          _showError('No audio was recorded');
          setState(() => _isProcessing = false);
        }
      } catch (e) {
        print('Stop recording error: $e');
        _showError('Failed to stop recording: ${e.toString()}');
        setState(() => _isProcessing = false);
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration += const Duration(milliseconds: 100);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  Future<void> _processAudioRecording(String audioPath) async {
    try {
      final audioFile = File(audioPath);

      // Add a temporary "Recording..." message
      setState(() {
        _messages.add(ChatMessage(
          text: "🎤 Recording... (${_formatDuration(_recordingDuration)})",
          isUser: true,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();

      // Send to your backend API
      final result = await _chatService.sendVoiceMessage(audioFile);

      // Replace the temporary message with transcribed text
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: result['userText'] ?? "Voice message",
          isUser: true,
          timestamp: DateTime.now(),
        ));

        // Add AI response
        if (result['aiText'] != null) {
          _messages.add(ChatMessage(
            text: result['aiText']!,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }

        _isProcessing = false;
        _recordingDuration = Duration.zero;
      });

      _scrollToBottom();

      // Play audio response if available
      final audioBytes = result['audioBytes'];
      if (audioBytes != null && audioBytes is List<int>) {
        await _audioService.playAudio(audioBytes);
      }

      // Delete temp file after processing
      try {
        await audioFile.delete();
      } catch (e) {
        print('Failed to delete temp file: $e');
      }

    } catch (e) {
      print('Process audio error: $e');
      setState(() {
        _isProcessing = false;
        _recordingDuration = Duration.zero;
        _messages.add(ChatMessage(
          text: "Failed to process voice message. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Send text message
  void _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isProcessing = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      setState(() => _isTyping = true);

      final result = await _chatService.sendTextMessage(text);

      setState(() {
        _isTyping = false;
        _isProcessing = false;
      });

      if (result['success'] == true) {
        setState(() {
          _messages.add(ChatMessage(
            text: result['aiText'],
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });

        // Play audio response if available
        final audioBytes = result['audioBytes'];
        if (audioBytes != null && audioBytes is List<int>) {
          await _audioService.playAudio(audioBytes);
        }
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _isProcessing = false;
        _messages.add(ChatMessage(
          text: "Sorry, something went wrong. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }

    _scrollToBottom();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _chatService.clearHistory();
      _messages.add(ChatMessage(
        text: "...",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  // Build record button with permission handling
  Widget _buildRecordButton(ThemeData theme) {
    final isPermissionGranted = _hasMicrophonePermission;
    final isDisabled = _isProcessing || _checkingPermission || _permissionRequested || !isPermissionGranted;

    // Color based on state
    Color buttonColor;
    if (!isPermissionGranted) {
      buttonColor = Colors.grey[400]!;
    } else if (_isRecording) {
      buttonColor = Colors.red;
    } else {
      buttonColor = theme.progressIndicatorTheme.color ?? Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: buttonColor,
      ),
      child: IconButton(
        icon: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 24,
        ),
        onPressed: isDisabled ? null : _toggleRecording,
        tooltip: isPermissionGranted
            ? (_isRecording ? 'Stop recording' : 'Start recording')
            : 'Tap to enable microphone permission',
      ),
    );
  }

  // Build permission request button
  Widget _buildPermissionButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[400]!,
      ),
      child: IconButton(
        icon: Stack(
          children: [
            Icon(
              Icons.mic_off,
              color: Colors.white,
              size: 24,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_open,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        onPressed: _permissionRequested || _checkingPermission ? null : () async {
          await _requestMicrophonePermission();
        },
        tooltip: 'Enable microphone permission',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        foregroundColor: theme.appBarTheme.foregroundColor ?? theme.iconTheme.color,
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
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.delete_outline,
        //       color: theme.iconTheme.color,
        //     ),
        //     onPressed: _isProcessing ? null : () {
        //       showDialog(
        //         context: context,
        //         builder: (context) => AlertDialog(
        //           backgroundColor: theme.cardTheme.color,
        //           title: Text(
        //             'Clear Chat',
        //             style: theme.textTheme.titleMedium?.copyWith(
        //               color: theme.iconTheme.color,
        //             ),
        //           ),
        //           content: Text(
        //             'Are you sure you want to clear all messages?',
        //             style: theme.textTheme.bodyMedium?.copyWith(
        //               color: theme.iconTheme.color,
        //             ),
        //           ),
        //           actions: [
        //             TextButton(
        //               onPressed: () => Navigator.pop(context),
        //               child: Text(
        //                 'Cancel',
        //                 style: theme.textTheme.bodyMedium?.copyWith(
        //                   color: theme.iconTheme.color,
        //                 ),
        //               ),
        //             ),
        //             TextButton(
        //               onPressed: () {
        //                 _clearChat();
        //                 Navigator.pop(context);
        //               },
        //               child: Text(
        //                 'Clear',
        //                 style: theme.textTheme.bodyMedium?.copyWith(
        //                   color: Colors.red,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator(theme);
                }
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          // Show recording duration if recording
          if (_isRecording)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Recording: ${_formatDuration(_recordingDuration)}',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
            ),
          _buildInputField(theme),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: theme.progressIndicatorTheme.color ?? Colors.blue,
              child: Icon(
                Icons.smart_toy,
                color: theme.iconTheme.color ?? Colors.white,
                size: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: theme.iconTheme.color ?? Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: theme.iconTheme.color ?? Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: theme.iconTheme.color ?? Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor ?? Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Show permission button or record button based on permission status
          _hasMicrophonePermission
              ? _buildRecordButton(theme)
              : _buildPermissionButton(theme),

          const SizedBox(width: 8),

          // Text input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant ?? Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _messageController,
                  enabled: !_isProcessing && !_checkingPermission && !_permissionRequested,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.iconTheme.color ?? Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: _checkingPermission
                        ? 'Checking permissions...'
                        : _permissionRequested
                        ? 'Requesting permission...'
                        : _isProcessing
                        ? 'Processing...'
                        : _isRecording
                        ? 'Recording...'
                        : !_hasMicrophonePermission
                        ? 'Tap mic icon to enable voice messages'
                        : 'Type your message...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor ?? Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendTextMessage(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.progressIndicatorTheme.color ?? Colors.blue,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: theme.iconTheme.color ?? Colors.white,
              ),
              onPressed: (_isProcessing || _checkingPermission || _permissionRequested) ? null : _sendTextMessage,
            ),
          ),
        ],
      ),
    );
  }
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
                backgroundColor: theme.progressIndicatorTheme.color ?? Colors.blue,
                child: Icon(
                  Icons.smart_toy,
                  color: theme.iconTheme.color ?? Colors.white,
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
                        ? (theme.progressIndicatorTheme.color ?? Colors.blue)
                        : (theme.cardTheme.color ?? Colors.grey[200]),
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
                          ? (theme.iconTheme.color ?? Colors.white)
                          : (theme.iconTheme.color ?? Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor ?? Colors.grey,
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
                  color: theme.iconTheme.color ?? Colors.black,
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