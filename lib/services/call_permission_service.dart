import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CallPermissionService {
  CallPermissionService._();

  static final CallPermissionService instance =
  CallPermissionService._();

  // ---------------------------------------------------------------------------
  // REQUEST AUDIO CALL PERMISSION
  // ---------------------------------------------------------------------------

  Future<bool> requestAudioPermission(
      BuildContext context,
      ) async {
    final microphoneStatus =
    await Permission.microphone.request();

    if (microphoneStatus.isGranted) {
      return true;
    }

    if (microphoneStatus.isPermanentlyDenied) {
      await _showSettingsDialog(
        context,
        title: 'Microphone Permission Required',
        message:
        'Microphone permission has been denied permanently. '
            'Please enable it from App Settings to make an audio call.',
      );

      return false;
    }

    if (microphoneStatus.isDenied) {
      await _showPermissionDeniedDialog(
        context,
        message:
        'Microphone permission is required to make an audio call.',
      );

      return false;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // REQUEST VIDEO CALL PERMISSION
  // ---------------------------------------------------------------------------

  Future<bool> requestVideoPermission(
      BuildContext context,
      ) async {
    final statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    final microphoneStatus =
    statuses[Permission.microphone];

    final cameraStatus =
    statuses[Permission.camera];

    if (microphoneStatus?.isGranted == true &&
        cameraStatus?.isGranted == true) {
      return true;
    }

    // Microphone permanently denied.
    if (microphoneStatus?.isPermanentlyDenied == true) {
      await _showSettingsDialog(
        context,
        title: 'Microphone Permission Required',
        message:
        'Microphone permission has been denied permanently. '
            'Please enable it from App Settings.',
      );

      return false;
    }

    // Camera permanently denied.
    if (cameraStatus?.isPermanentlyDenied == true) {
      await _showSettingsDialog(
        context,
        title: 'Camera Permission Required',
        message:
        'Camera permission has been denied permanently. '
            'Please enable it from App Settings.',
      );

      return false;
    }

    await _showPermissionDeniedDialog(
      context,
      message:
      'Camera and microphone permissions are required '
          'to make a video call.',
    );

    return false;
  }

  // ---------------------------------------------------------------------------
  // SETTINGS DIALOG
  // ---------------------------------------------------------------------------

  Future<void> _showSettingsDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // NORMAL DENIAL
  // ---------------------------------------------------------------------------

  Future<void> _showPermissionDeniedDialog(
      BuildContext context, {
        required String message,
      }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}