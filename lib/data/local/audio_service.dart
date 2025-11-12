import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final AudioRecorder _recorder = AudioRecorder();
  static bool _isRecording = false;

  static bool get isRecording => _isRecording;

  // Request microphone permission
  static Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Start recording
  static Future<void> startRecording() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _isRecording = true;
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }

  // Stop recording and return file path
  static Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  // Cancel recording
  static Future<void> cancelRecording() async {
    try {
      await _recorder.stop();
      _isRecording = false;
    } catch (e) {
      print('Error cancelling recording: $e');
    }
  }

  // Delete audio file
  static Future<void> deleteAudio(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting audio: $e');
    }
  }

  // Check if file exists
  static Future<bool> audioExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}