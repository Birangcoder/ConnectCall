import 'package:permission_handler/permission_handler.dart';

/// Result of a permission request, kept simple so the UI can branch
/// cleanly on granted / denied / permanently denied.
enum PermissionState { granted, denied, permanentlyDenied }

class PermissionHelper {
  PermissionHelper._();

  static Future<PermissionState> requestMicrophone() =>
      _request(Permission.microphone);

  static Future<PermissionState> requestCamera() =>
      _request(Permission.camera);

  /// Requests both mic + camera together (used before starting a video call).
  static Future<Map<Permission, PermissionState>> requestForVideoCall() async {
    final statuses = await [Permission.microphone, Permission.camera].request();
    return statuses.map((permission, status) => MapEntry(
          permission,
          _mapStatus(status),
        ));
  }

  static Future<PermissionState> _request(Permission permission) async {
    final status = await permission.request();
    return _mapStatus(status);
  }

  static PermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted) return PermissionState.granted;
    if (status.isPermanentlyDenied) return PermissionState.permanentlyDenied;
    return PermissionState.denied;
  }

  /// Opens the OS app settings screen — used when a permission is
  /// permanently denied and the user must enable it manually.
  static Future<void> openSettings() => openAppSettings();
}
