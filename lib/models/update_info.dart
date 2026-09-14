class UpdateInfo {
  final String latestVersion;
  final String minimumVersion;
  final String apkUrl;
  final List<String> releaseNotes;

  const UpdateInfo({
    required this.latestVersion,
    required this.minimumVersion,
    required this.apkUrl,
    required this.releaseNotes,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latestVersion'] as String,
      minimumVersion: json['minimumVersion'] as String,
      apkUrl: json['apkUrl'] as String,
      releaseNotes:
      List<String>.from(json['releaseNotes'] ?? []),
    );
  }
}