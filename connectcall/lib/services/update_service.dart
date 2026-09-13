import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/update_info.dart';

class UpdateService {
  static const String versionUrl =
      'https://raw.githubusercontent.com/Birangcoder/ConnectCall/main/connectcall/version.json';

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

  Future<void> downloadAndInstall(
    String apkUrl, {
    required Function(double progress) onProgress,
  }) async {
    final directory = await getExternalStorageDirectory();

    if (directory == null) {
      throw Exception('Could not access storage');
    }

    final apkPath = '${directory.path}/connectcall-update.apk';

    print('APK URL: $apkUrl');
    print('APK path: $apkPath');

    final dio = Dio();

    await dio.download(
      apkUrl,
      apkPath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          final progress = received / total;

          print(
            'Download: '
            '${(progress * 100).toStringAsFixed(0)}%',
          );

          onProgress(progress);
        }
      },
    );

    final file = File(apkPath);

    if (!await file.exists()) {
      throw Exception('APK download failed');
    }

    final size = await file.length();

    print('APK downloaded successfully');

    print('APK size: $size bytes');

    if (size <= 0) {
      throw Exception('Downloaded APK is empty');
    }

    print('Opening Android installer...');

    await _installer.installApk(filePath: apkPath);

    print('Android installer opened');
  }
}
