import 'dart:convert';

class AppUpdate {
  final String version;
  final String url;
  final String messText;

  static const String currentAppVersion = '1.0.0';
  AppUpdate({required this.version, required this.url, required this.messText});

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(version: json['version'] ?? '', url: json['url'] ?? '', messText: json['messText'] ?? '');
  }

  static AppUpdate? fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return AppUpdate.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  bool hasUpdate() {
    return _isNewerVersion(currentAppVersion, version);
  }

  bool _isNewerVersion(String currentVersion, String newVersion) {
    try {
      List<int> current = currentVersion.split('.').map(int.parse).toList();
      List<int> available = newVersion.split('.').map(int.parse).toList();
      final maxLength = current.length > available.length ? current.length : available.length;
      
      for (int i = 0; i < maxLength; i++) {
        final currentPart = i < current.length ? current[i] : 0;
        final availablePart = i < available.length ? available[i] : 0;

        if (availablePart > currentPart) {
          return true;
        }
        if (availablePart < currentPart) {
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
