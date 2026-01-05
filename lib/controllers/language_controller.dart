import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_language.dart';
import 'package:fuel_tracker_app/services/language_service.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  final LanguageService _languageService = LanguageService();

  var _currentLanguage = AppLanguage.getByCode('pt').obs;
  var _translations = <String, dynamic>{}.obs;
  var _isInitialized = false.obs;
  var _isLoading = false.obs;

  AppLanguage get currentLanguage => _currentLanguage.value;
  Map<String, dynamic> get translations => _translations;
  bool get isInitialized => _isInitialized.value;
  bool get isLoading => _isLoading.value;

  List<AppLanguage> get supportedLanguages => AppLanguage.supportedLanguages;
  TextDirection get textDirection =>
      _currentLanguage.value.isRtl ? TextDirection.rtl : TextDirection.ltr;
  Locale get locale => Locale(_currentLanguage.value.code);
  bool get isRtl => _currentLanguage.value.isRtl;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized.value) return;
    _isLoading.value = true;

    try {
      final lang = await _languageService.initializeLanguage();
      _currentLanguage.value = lang;
      await _loadTranslations(lang.code);
      _isInitialized.value = true;
    } catch (e) {
      _currentLanguage.value = AppLanguage.getByCode('en');
      await _loadTranslations('en');
      _isInitialized.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> changeLanguage(AppLanguage language) async {
    if (_currentLanguage.value == language) return true;
    _isLoading.value = true;

    try {
      final saved = await _languageService.saveLanguage(language);
      if (!saved) return false;

      await _loadTranslations(language.code);
      _currentLanguage.value = language;

      Get.updateLocale(Locale(language.code));
      return true;
    } catch (e) {
      _isLoading.value = false;
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadTranslations(String languageCode) async {
    try {
      final maps = await _languageService.loadTranslations(languageCode);
      _translations.assignAll(maps);
    } catch (e) {
      if (languageCode != 'en') {
        final enMaps = await _languageService.loadTranslations('en');
        _translations.assignAll(enMaps);
      } else {
        _translations.clear();
      }
    }
  }

  String translate(String key, {Map<String, String>? parameters}) {
    return _getNestedTranslation(key, parameters);
  }

  String _getNestedTranslation(String key, Map<String, String>? parameters) {
    final keys = key.split('.');
    dynamic current = _translations;

    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return key;
      }
    }

    String result = current?.toString() ?? key;

    if (parameters != null) {
      parameters.forEach((paramKey, paramValue) {
        result = result.replaceAll('\$$paramKey', paramValue);
      });
    }
    return result;
  }

  Future<void> reloadTranslations() async {
    _isLoading.value = true;
    try {
      await _loadTranslations(_currentLanguage.value.code);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> resetToDeviceLanguage() async {
    final deviceLanguage = await _languageService.getDeviceLanguage();
    return await changeLanguage(deviceLanguage);
  }
}
