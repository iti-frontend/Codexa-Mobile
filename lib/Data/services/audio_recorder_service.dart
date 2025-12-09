import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';

class AudioRecorderService {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _currentRecordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  bool _isInitialized = false;

  // Initialize the recorder
  Future<void> initialize() async {
    try {
      print('Initializing audio recorder...');

      // Check permission first
      final hasPermission = await _checkAndRequestPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isInitialized = true;
      print('Audio recorder initialized successfully');
    } catch (e) {
      print('Failed to initialize recorder: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // Check and request microphone permission
  Future<bool> _checkAndRequestPermission() async {
    try {
      // Check current status
      PermissionStatus status = await Permission.microphone.status;

      print('Microphone permission status: $status');

      if (status.isDenied || status.isRestricted) {
        // Request permission
        status = await Permission.microphone.request();

        print('After request, microphone permission status: $status');
      }

      if (status.isPermanentlyDenied) {
        print('Microphone permission permanently denied');
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('Error checking microphone permission: $e');
      return false;
    }
  }

  // Start recording with permission check
  Future<String?> startRecording() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Double-check permission before recording
      final hasPermission = await Permission.microphone.isGranted;
      if (!hasPermission) {
        final requested = await _checkAndRequestPermission();
        if (!requested) {
          throw Exception('Microphone permission required to record audio');
        }
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Record in WAV format
      final filePath = '${directory.path}/recording_$timestamp.wav';
      print('Recording to WAV file: $filePath');

      try {
        await _recorder!.startRecorder(
          toFile: filePath,
          codec: Codec.pcm16WAV, // WAV format
          sampleRate: 16000,     // 16kHz for speech
          numChannels: 1,        // Mono
        );
      } catch (e) {
        print('WAV recording failed, falling back to AAC: $e');
        final fallbackPath = '${directory.path}/recording_$timestamp.m4a';
        await _recorder!.startRecorder(
          toFile: fallbackPath,
          codec: Codec.aacMP4,
          bitRate: 64000,
          sampleRate: 16000,
          numChannels: 1,
        );
        _currentRecordingPath = fallbackPath;
        _isRecording = true;
        _recordingDuration = Duration.zero;
        _startRecordingTimer();
        return fallbackPath;
      }

      _isRecording = true;
      _currentRecordingPath = filePath;
      _recordingDuration = Duration.zero;
      _startRecordingTimer();

      return filePath;
    } catch (e) {
      print('Start recording error: $e');
      rethrow;
    }
  }

  // Check if recorder is ready
  bool get isReady => _recorder != null && _isInitialized;

  // Check if has permission
  Future<bool> get hasPermission async {
    return await Permission.microphone.isGranted;
  }

  // ... rest of your existing methods remain the same
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _recordingDuration += const Duration(milliseconds: 100);
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording || !isReady) {
        print('Not recording or recorder not ready');
        return null;
      }

      print('Stopping recording...');
      await _recorder!.stopRecorder();
      _isRecording = false;
      _stopRecordingTimer();

      final path = _currentRecordingPath;
      _currentRecordingPath = null;

      print('Recording stopped. File: $path');
      return path;
    } catch (e) {
      print('Stop recording error: $e');
      rethrow;
    }
  }

  Duration get recordingDuration => _recordingDuration;
  bool get isRecording => _isRecording;

  Future<void> dispose() async {
    print('Disposing audio recorder...');
    _stopRecordingTimer();
    if (_isRecording && isReady) {
      await stopRecording();
    }
    if (isReady) {
      await _recorder!.closeRecorder();
    }
    _recorder = null;
    _isInitialized = false;
    print('Audio recorder disposed');
  }
}