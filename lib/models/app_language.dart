class AppLanguage {
  final String name;
  final String code;
  final String flag;
  final String direction;

  const AppLanguage({
    required this.name,
    required this.code,
    required this.flag,
    required this.direction,
  });

  bool get isRtl => direction == 'rtl';

  factory AppLanguage.fromJson(Map<String, dynamic> json){
    final language = json['language'] as Map<String, dynamic>;
    return AppLanguage(name: language['name'] as String, code: language['code'] as String, flag: language['flag'] as String, direction: language['direction'] as String);
  }

  Map<String, dynamic> toJson(){
    return {
      "language": {
        "name": name,
        "code": code,
        "flag": flag,
        "direction": direction,
      }
    };
  }

  @override
  bool operator ==(Object other){
    if(identical(this, other)) return true;
    return other is AppLanguage && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString(){
    return 'AppLanguage(name: $name, code: $code, flag: $flag, direction: $direction)';
  }

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(name: 'English', code: 'en', flag: '🇬🇧', direction: 'ltr'),
    AppLanguage(name: 'Português', code: 'pt', flag: '🇧🇷', direction: 'ltr'),
    AppLanguage(name: 'Español', code: 'es', flag: '🇪🇸', direction: 'ltr'),
    AppLanguage(name: 'Francês', code: 'fr', flag: '🇫🇷', direction: 'ltr'),
    AppLanguage(name: 'Alemão', code: 'de', flag: '🇩🇪', direction: 'ltr'),
    AppLanguage(name: 'Italiano', code: 'it', flag: '🇮🇹', direction: 'ltr'),
    AppLanguage(name: 'Russo', code: 'ru', flag: '🇷🇺', direction: 'ltr'),
  ];

  static AppLanguage getByCode(String code){
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first,
    );
  }

  static List<String> get supportedLocales {
    return supportedLanguages.map((lang) => lang.code).toList();
  }
}