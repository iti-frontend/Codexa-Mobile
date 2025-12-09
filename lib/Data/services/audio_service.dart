import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(List<int> audioBytes) async {
    try {
      await _audioPlayer.stop();

      // Convert List<int> to Uint8List
      final uint8List = Uint8List.fromList(audioBytes);

      // Correct way to create the source
      final source = BytesSource(uint8List);
      await _audioPlayer.play(source);
    } catch (e) {
      print('Audio play error: $e');
      rethrow;
    }
  }

  Future<void> playAudioFromUrl(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Audio play from URL error: $e');
      rethrow;
    }
  }

  Future<void> stopPlaying() async {
    await _audioPlayer.stop();
  }

  Future<void> pausePlaying() async {
    await _audioPlayer.pause();
  }

  Future<void> resumePlaying() async {
    await _audioPlayer.resume();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  // Optional: Get player state streams
  Stream<PlayerState> get playerStateStream => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  Stream<Duration?> get durationStream => _audioPlayer.onDurationChanged;
}