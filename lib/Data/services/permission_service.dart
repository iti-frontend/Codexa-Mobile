import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check and request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      // Check current status
      PermissionStatus status = await Permission.microphone.status;

      print('Microphone permission status: $status');

      if (status.isDenied || status.isRestricted) {
        // Request permission
        status = await Permission.microphone.request();

        print('After request, microphone permission status: $status');
      }

      return status.isGranted;
    } catch (e) {
      print('Error checking microphone permission: $e');
      return false;
    }
  }

  // Check if permission is granted
  static Future<bool> hasMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking permission status: $e');
      return false;
    }
  }

  // Open app settings (for when user permanently denies)
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Check and request storage permission (for older Android)
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isRestricted) {
      return true; // Permission is not required on this device
    }

    PermissionStatus status = await Permission.storage.status;

    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }
}