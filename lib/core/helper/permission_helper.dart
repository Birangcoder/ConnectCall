import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  PermissionHelper._();

  // ---------------------------------------------------------------------------
  // MICROPHONE
  // ---------------------------------------------------------------------------

  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    final result = await Permission.microphone.request();

    return result.isGranted;
  }

  // ---------------------------------------------------------------------------
  // CAMERA
  // ---------------------------------------------------------------------------

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    final result = await Permission.camera.request();

    return result.isGranted;
  }

  // ---------------------------------------------------------------------------
  // AUDIO CALL
  // ---------------------------------------------------------------------------

  static Future<bool> requestForAudioCall() async {
    return requestMicrophone();
  }

  // ---------------------------------------------------------------------------
  // VIDEO CALL
  // ---------------------------------------------------------------------------

  static Future<bool> requestForVideoCall() async {
    final microphoneGranted = await requestMicrophone();

    if (!microphoneGranted) {
      return false;
    }

    final cameraGranted = await requestCamera();

    if (!cameraGranted) {
      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // OPEN APP SETTINGS
  // ---------------------------------------------------------------------------

  static Future<bool> openSettings() async {
    return openAppSettings();
  }

  // ---------------------------------------------------------------------------
  // CHECK MICROPHONE
  // ---------------------------------------------------------------------------

  static Future<bool> hasMicrophonePermission() async {
    return Permission.microphone.isGranted;
  }

  // ---------------------------------------------------------------------------
  // CHECK CAMERA
  // ---------------------------------------------------------------------------

  static Future<bool> hasCameraPermission() async {
    return Permission.camera.isGranted;
  }
}