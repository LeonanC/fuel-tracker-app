import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_language.dart';
import 'package:fuel_tracker_app/services/language_service.dart';

class LanguageProvider with ChangeNotifier {
  final LanguageService _languageService = LanguageService();
  AppLanguage _currentLanguage = AppLanguage.getByCode('pt');
  Map<String, dynamic> _translations = {};
  bool _isInitialized = false;
  bool _isLoading = false;

  AppLanguage get currentLanguage => _currentLanguage;
  Map<String, dynamic> get translations => _translations;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  List<AppLanguage> get supportedLanguages => AppLanguage.supportedLanguages;

  Future<void> initialize() async {
    if(_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try{
      _currentLanguage = await _languageService.initializeLanguage();
      await _loadTranslations(_currentLanguage.code);
      _isInitialized = true;
    }catch(e){
      _currentLanguage = AppLanguage.getByCode('en');
      await _loadTranslations('en');
      _isInitialized = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> changeLanguage(AppLanguage language) async {
    if(_currentLanguage == language) return true;
    _isLoading = true;
    notifyListeners();

    try{
      final saved = await _languageService.saveLanguage(language);
      if(!saved){
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _loadTranslations(language.code);

      _currentLanguage = language;
      _isLoading = false;
      notifyListeners();
      return true;
    }catch(e){
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadTranslations(String languageCode) async {
    try{
      _translations = await _languageService.loadTranslations(languageCode);
    }catch(e){
      if(languageCode != 'en'){
        _translations = await _languageService.loadTranslations('en');
      }else{
        _translations = {};
      }
    }
  }

  String translate(String key, {Map<String, String>? parameters}){
    return _getNestedTranslation(key, parameters);
  }

  String _getNestedTranslation(String key, Map<String, String>? parameters){
    final keys = key.split('.');
    dynamic current = _translations;
    for(final k in keys){
      if(current is Map<String, dynamic> && current.containsKey(k)){
        current = current[k];
      }else{
        return key;
      }
    }

    String result = current?.toString() ?? key;

    if(parameters != null){
      parameters.forEach((paramKey, paramValue){
        result = result.replaceAll('${paramKey}', paramValue);
      });
    }
    return result;
  }

  bool hasTranslation(String key){
    final keys = key.split('.');
    dynamic current = _translations;

    for(final k in keys){
      if(current is Map<String, dynamic> && current.containsKey(k)){
        current = current[k];
      }else{
        return false;
      }
    }

    return current != null;
  }

  Future<void> reloadTranslations() async {
    _isLoading = true;
    notifyListeners();
    await _loadTranslations(_currentLanguage.code);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> resetToDeviceLanguage() async {
    final deviceLanguage = await _languageService.getDeviceLanguage();
    return await changeLanguage(deviceLanguage);
  }

  Future<List<AppLanguage>> getAvailableLanguages() async {
    return await _languageService.getAvailableLanguages();
  }

  TextDirection get textDirection {
    return _currentLanguage.isRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  Locale get locale {
    return Locale(_currentLanguage.code);
  }

  bool get isRtl => _currentLanguage.isRtl;
}