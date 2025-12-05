import 'package:intl/intl.dart';

class AppLanguage {
  final String name;
  final String code;
  final String flag;
  final bool isRtl;
  final TextDirection direction;

  const AppLanguage({
    required this.name,
    required this.code,
    required this.flag,
    this.isRtl = false,
    this.direction = TextDirection.LTR,
  });

  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguage && runtimeType == other.runtimeType && other.code == code;

  @override
  int get hashCode => code.hashCode;

  String get text_direction => isRtl ? 'RTL' : 'LTR';

  static List<AppLanguage> get supportedLanguages => [
    const AppLanguage(
      code: 'en',
      name: 'English', 
      flag: '🇬🇧', 
      direction: TextDirection.LTR,
    ),
    const AppLanguage(
      code: 'pt',
      name: 'Português (BR)', 
      flag: '🇧🇷', 
      direction: TextDirection.LTR,
    ),
    const AppLanguage(name: 'Español', code: 'es', flag: '🇪🇸', direction: TextDirection.LTR),
    AppLanguage(name: 'Francês', code: 'fr', flag: '🇫🇷', direction: TextDirection.LTR),
    AppLanguage(name: 'Alemão', code: 'de', flag: '🇩🇪', direction: TextDirection.LTR),
    AppLanguage(name: 'Italiano', code: 'it', flag: '🇮🇹', direction: TextDirection.LTR),
    AppLanguage(name: 'Russo', code: 'ru', flag: '🇷🇺', direction: TextDirection.LTR),
    AppLanguage(name: 'العربية (Arabic)', code: 'ar', flag: '🇦🇪', isRtl: true, direction: TextDirection.RTL),
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