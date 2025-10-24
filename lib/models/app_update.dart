import 'dart:convert';

class AppUpdate {
  final String version;
  final String url;
  final String messText;

  static const String currentAppVersion = '3.0.0';
  AppUpdate({required this.version, required this.url, required this.messText});

  factory AppUpdate.fromJson(Map<String, dynamic> json){
    return AppUpdate(version: json['version'] ?? '', url: json['url'] ?? '', messText: json['messText'] ?? '');
  }

  static AppUpdate? fromJsonString(String jsonString){
    try{
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return AppUpdate.fromJson(json);
    }catch(e){
      return null;
    }
  }

  bool hasUpdate(){
    return _isNewerVersion(currentAppVersion, version);
  }

  bool _isNewerVersion(String currentVersion, String newVersion){
    try{
      List<int> current = currentVersion.split('.').map(int.parse).toList();
      List<int> newer = newVersion.split('.').map(int.parse).toList();
      while(current.length < 3){
        current.add(0);
      }
      while(newer.length < 3){
        newer.add(0);
      }
      for(int i = 0; i < 3; i++){
        if(newer[i] > current[i]){
          return true;
        }else if (newer[i] < current[i]){
          return false;
        }
      }
      return false;
    }catch(e){
      return false;
    }
  }
}