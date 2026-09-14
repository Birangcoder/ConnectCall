import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/update_info.dart';

class UpdateService {
  static const String versionUrl =
      'https://raw.githubusercontent.com/Birangcoder/ConnectCall/main/version.json';

  final FlutterAppInstaller _installer = FlutterAppInstaller();

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      print('Checking update...');

      final response = await http.get(Uri.parse(versionUrl));

      print('Version response: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('Version check failed');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final updateInfo = UpdateInfo.fromJson(json);

      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;

      print('Current version: $currentVersion');

      print(
        'Latest version: '
            '${updateInfo.latestVersion}',
      );

      if (_compareVersions(updateInfo.latestVersion, currentVersion) > 0) {
        print('Update available');

        return updateInfo;
      }

      print('App is up to date');

      return null;
    } catch (e) {
      print('Update check error: $e');

      return null;
    }
  }

  Future<bool> isMandatoryUpdate(UpdateInfo updateInfo) async {
    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = packageInfo.version;

    return _compareVersions(currentVersion, updateInfo.minimumVersion) < 0;
  }

  int _compareVersions(String version1, String version2) {
    final v1 = version1.split('.').map(int.parse).toList();

    final v2 = version2.split('.').map(int.parse).toList();

    final length = v1.length > v2.length ? v1.length : v2.length;

    for (int i = 0; i < length; i++) {
      final number1 = i < v1.length ? v1[i] : 0;

      final number2 = i < v2.length ? v2[i] : 0;

      if (number1 > number2) {
        return 1;
      }

      if (number1 < number2) {
        return -1;
      }
    }

    return 0;
  }

  Future<void> downloadAndInstall(String apkUrl, {
    required Function(double progress) onProgress,
  }) async {
    // -------------------------------------------------------------------
    // CHECK / REQUEST "INSTALL UNKNOWN APPS" PERMISSION FIRST
    // -------------------------------------------------------------------
    final hasPermission = await _ensureInstallPermission();

    if (!hasPermission) {
      throw Exception(
        'Please allow "Install unknown apps" for ConnectCall in Settings, then try again.',
      );
    }

    final directory = await getExternalStorageDirectory();

    if (directory == null) {
      throw Exception('Could not access storage');
    }

    final apkPath = '${directory.path}/connectcall-update.apk';

    final dio = Dio();

    await dio.download(
      apkUrl,
      apkPath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    final file = File(apkPath);

    if (!await file.exists()) {
      throw Exception('APK download failed');
    }

    final size = await file.length();

    if (size <= 0) {
      throw Exception('Downloaded APK is empty');
    }

    final result = await OpenFile.open(
      apkPath,
      type: 'application/vnd.android.package-archive',
    );

    print('APK open result:');
    print('type: ${result.type}');
    print('message: ${result.message}');

    // -------------------------------------------------------------------
    // TURN A FAILED OPEN INTO A VISIBLE ERROR INSTEAD OF SILENT HANG
    // -------------------------------------------------------------------
    if (result.type != ResultType.done) {
      throw Exception('Could not open APK: ${result.type} - ${result.message}');
    }
  }

// -------------------------------------------------------------------
// PERMISSION HELPER
// -------------------------------------------------------------------
  Future<bool> _ensureInstallPermission() async {
    final status = await Permission.requestInstallPackages.status;
    if (status.isGranted) return true;

    final result = await Permission.requestInstallPackages.request();
    return result.isGranted;
  }
}
