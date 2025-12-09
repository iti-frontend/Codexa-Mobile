// lib/services/chat_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class ChatService {
  late ApiManager _apiManager;
  List<Map<String, dynamic>> _chatHistory = [];
  String? _initialGreeting;
  bool _isInitialized = false;

  // Make constructor private
  ChatService._();

  // Factory constructor that handles async initialization
  static Future<ChatService> create() async {
    final instance = ChatService._();
    await instance._initApiManager();
    instance._isInitialized = true;
    return instance;
  }

  Future<void> _initApiManager() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiManager = ApiManager(prefs: prefs);
      print('ApiManager initialized successfully');
    } catch (e) {
      print('Failed to initialize ApiManager: $e');
      rethrow;
    }
  }

  // Check if initialized
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('ChatService not initialized. Call ChatService.create() first.');
    }
  }

  // Get initial greeting from API
  Future<String> getInitialGreeting() async {
    try {
      // If we already have the greeting, return it
      if (_initialGreeting != null) return _initialGreeting!;

      // Ensure ApiManager is initialized
       _checkInitialized();

      // Call API with empty message to get greeting
      print('=== GETTING INITIAL GREETING ===');
      final response = await _apiManager.chatAI(
        '', // Empty message for initial greeting
        history: [], // Use empty history, don't pass _chatHistory
      );

      print('Initial greeting response status: ${response.statusCode}');

      String greeting = '';

      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        greeting = data['response']?.toString()?.trim() ?? '';
      } else if (response.data is String) {
        greeting = response.data.toString().trim();
      }

      if (greeting.isEmpty) {
        greeting = "Hello! I'm your learning assistant. How can I help you today?";
      }

      _initialGreeting = greeting;
      return greeting;

    } catch (e) {
      print('Error getting initial greeting: $e');
      // Fallback to default greeting
      return "Hello! I'm your learning assistant. How can I help you today?";
    }
  }

  // Send voice message and get AI response
  Future<Map<String, dynamic>> sendVoiceMessage(File audioFile) async {
    try {
      print('=== SENDING VOICE MESSAGE ===');
      print('Audio file path: ${audioFile.path}');
      print('Audio file exists: ${await audioFile.exists()}');

      if (await audioFile.exists()) {
        final fileSize = await audioFile.length();
        print('Audio file size: ${fileSize / 1024} KB');

        if (fileSize < 1024) {
          print('WARNING: File is too small to contain meaningful audio');
          throw Exception('Recording is too short. Please record for at least 2 seconds.');
        }
      } else {
        throw Exception('Audio file does not exist');
      }

      // 1. Convert voice to text
      print('Calling voiceToText API...');
      final sttResponse = await _apiManager.voiceToText(audioFile);

      print('STT Response status: ${sttResponse.statusCode}');
      print('STT Response data type: ${sttResponse.data.runtimeType}');
      print('STT Response data: ${sttResponse.data}');

      if (sttResponse.statusCode != 200) {
        // Check the error type
        String errorMessage = 'Voice recognition failed';

        if (sttResponse.statusCode == 400) {
          errorMessage = 'Invalid audio format. Please try recording again.';
        } else if (sttResponse.statusCode == 401) {
          errorMessage = 'Authentication error. Please check your API configuration.';
        } else if (sttResponse.statusCode == 413) {
          errorMessage = 'Audio file is too large. Please record a shorter message.';
        } else if (sttResponse.statusCode == 415) {
          errorMessage = 'Unsupported audio format. The system expects WebM format.';
        } else if (sttResponse.statusCode == 500) {
          errorMessage = 'Speech recognition service is temporarily unavailable. Please try text input.';
        } else if (sttResponse.statusCode == 503) {
          errorMessage = 'Service overloaded. Please try again in a moment.';
        }

        // Handle response data carefully
        if (sttResponse.data != null) {
          if (sttResponse.data is Map<String, dynamic>) {
            final Map<String, dynamic> data = sttResponse.data as Map<String, dynamic>;
            if (data['error'] != null) {
              errorMessage += '\nError: ${data['error']}';
            }
          } else if (sttResponse.data is String) {
            errorMessage += '\nResponse: ${sttResponse.data}';
          }
        }

        throw Exception(errorMessage);
      }

      // FIX: Handle the response data safely
      String transcribedText = '';

      if (sttResponse.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = sttResponse.data as Map<String, dynamic>;
        transcribedText = data['text']?.toString()?.trim() ?? '';
      } else if (sttResponse.data is String) {
        // If the backend returns just the text string directly
        transcribedText = sttResponse.data.toString().trim();
      } else {
        // Try to parse as JSON string if it's a String
        try {
          final parsed = json.decode(sttResponse.data.toString());
          if (parsed is Map<String, dynamic>) {
            transcribedText = parsed['text']?.toString()?.trim() ?? '';
          }
        } catch (e) {
          print('Failed to parse response: $e');
        }
      }

      print('Transcribed text: "$transcribedText"');

      if (transcribedText.isEmpty) {
        throw Exception('No speech was detected. Please speak clearly and try again.');
      }

      // Validate the transcription isn't just noise
      if (_isLikelyNoise(transcribedText)) {
        throw Exception('Could not detect clear speech. Please speak louder and more clearly.');
      }

      // 2. Send to AI chat
      print('Calling chat AI API...');
      final chatResponse = await _apiManager.chatAI(
        transcribedText,
        history: _chatHistory,
      );

      print('Chat AI Response status: ${chatResponse.statusCode}');
      print('Chat AI Response data type: ${chatResponse.data.runtimeType}');
      print('Chat AI Response data: ${chatResponse.data}');

      if (chatResponse.statusCode != 200) {
        String errorMessage = 'AI chat failed';

        if (chatResponse.data != null) {
          if (chatResponse.data is Map<String, dynamic>) {
            final Map<String, dynamic> data = chatResponse.data as Map<String, dynamic>;
            if (data['error'] != null) {
              errorMessage += ': ${data['error']}';
            }
          } else if (chatResponse.data is String) {
            errorMessage += ': ${chatResponse.data}';
          }
        }

        throw Exception(errorMessage);
      }

      String aiResponse = '';

      if (chatResponse.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = chatResponse.data as Map<String, dynamic>;
        aiResponse = data['response']?.toString()?.trim() ?? '';
      } else if (chatResponse.data is String) {
        aiResponse = chatResponse.data.toString().trim();
      }

      // 3. Get audio response (optional - handle gracefully)
      List<int>? audioBytes;
      try {
        print('Calling text to voice API...');
        final ttsResponse = await _apiManager.textToVoice(aiResponse);

        print('TTS Response status: ${ttsResponse.statusCode}');
        print('TTS Response data type: ${ttsResponse.data.runtimeType}');

        // Check if we got audio data (even with error status)
        if (ttsResponse.data != null) {
          if (ttsResponse.data is List<int>) {
            audioBytes = ttsResponse.data as List<int>;
            print('Audio bytes received: ${audioBytes.length} bytes');

            if (audioBytes.isEmpty) {
              print('WARNING: Audio bytes are empty');
              audioBytes = null;
            }
          } else if (ttsResponse.data is Uint8List) {
            audioBytes = (ttsResponse.data as Uint8List).toList();
            print('Audio bytes received (Uint8List): ${audioBytes.length} bytes');
          }
        }

        // If we got a server error but have audio data, log it but continue
        if (ttsResponse.statusCode != 200 && audioBytes != null) {
          print('WARNING: TTS returned status ${ttsResponse.statusCode} but provided audio data');
        }

      } catch (e) {
        print('TTS failed, continuing without audio: $e');
        // Continue without audio - text chat still works
      }

      // 4. Update chat history
      _updateHistory(transcribedText, aiResponse);

      print('=== VOICE MESSAGE SENT SUCCESSFULLY ===');
      return {
        'success': true,
        'userText': transcribedText,
        'aiText': aiResponse,
        'audioBytes': audioBytes,
        'hasAudio': audioBytes != null && audioBytes.isNotEmpty,
      };

    } catch (e) {
      print('=== SEND VOICE MESSAGE ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');

      // Log the stack trace for debugging
      if (e is Error) {
        print('Stack trace: ${e.stackTrace}');
      }

      print('===============================');

      // Re-throw with better context
      if (e is! Exception) {
        throw Exception('Failed to process voice message: ${e.toString()}');
      }
      rethrow;
    }
  }
// Helper method to detect if transcription is likely noise
  bool _isLikelyNoise(String text) {
    if (text.length < 3) return true;

    final lowerText = text.toLowerCase();

    // Common noise/static transcriptions
    final noisePatterns = [
      'static',
      'noise',
      'background',
      'silence',
      'unintelligible',
      'inaudible',
      'crackling',
      'hissing',
      'humming',
      '...',
      '??',
      '!!!',
    ];

    for (var pattern in noisePatterns) {
      if (lowerText.contains(pattern)) {
        return true;
      }
    }

    // Check for repetitive or nonsensical patterns
    if (RegExp(r'^(.)\1+$').hasMatch(text.replaceAll(' ', ''))) {
      return true; // Repeated single character
    }

    return false;
  }

// Helper method to update chat history
  void _updateHistory(String userMessage, String aiResponse) {
    // Add user message
    _chatHistory.add({
      'role': 'user',
      'content': userMessage,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Add AI response
    _chatHistory.add({
      'role': 'assistant',
      'content': aiResponse,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Keep only last 20 messages to avoid context overflow
    if (_chatHistory.length > 20) {
      _chatHistory = _chatHistory.sublist(_chatHistory.length - 20);
    }

    print('Chat history updated. Current length: ${_chatHistory.length} messages');
  }

   // Send text message and get AI response
  Future<Map<String, dynamic>> sendTextMessage(String message) async {
    try {
      // 1. Send to AI chat
      final chatResponse = await _apiManager.chatAI(
        message,
        history: _chatHistory,
      );

      if (chatResponse.statusCode != 200) {
        throw Exception('AI chat failed: ${chatResponse.data}');
      }

      final aiResponse = chatResponse.data['response']?.toString() ?? '';

      // 2. Update chat history
      _updateHistory(message, aiResponse);

      return {
        'success': true,
        'aiText': aiResponse,
      };
    } catch (e) {
      print('Send text message error: $e');
      rethrow;
    }
  }
  // Clear chat history
  void clearHistory() {
    _chatHistory.clear();
  }

  // Get chat history
  List<Map<String, dynamic>> get history => _chatHistory;


}