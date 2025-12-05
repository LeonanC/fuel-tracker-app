import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/app_language.dart';
import 'package:fuel_tracker_app/services/language_service.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  final LanguageService _languageService = LanguageService();

  var currentLanguage = AppLanguage.getByCode('pt').obs;
  var translations = <String, dynamic>{}.obs;
  var isInitialized = false.obs;
  var isLoading = false.obs;

  Locale get locale => Locale(currentLanguage.value.code);
  bool get isRtl => currentLanguage.value.isRtl;
  TextDirection get textDirection =>
      currentLanguage.value.isRtl ? TextDirection.rtl : TextDirection.ltr;
  List<AppLanguage> get supportedLanguages => AppLanguage.supportedLanguages;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> initialize() async {
    if (isInitialized.value) return;
    isLoading.value = true;

    try {
      final initialLang = await _languageService.initializeLanguage();
      currentLanguage.value = initialLang;
      await _loadTranslations(initialLang.code);
      isInitialized.value = true;
    } catch (e) {
      currentLanguage.value = AppLanguage.getByCode('en');
      await _loadTranslations('en');
      isInitialized.value = true;
    }
    isLoading.value = false;
  }

  Future<bool> changeLanguage(AppLanguage language) async {
    if (currentLanguage.value == language) return true;
    isLoading.value = true;

    try {
      final saved = await _languageService.saveLanguage(language);
      if (!saved) {
        isLoading.value = false;

        return false;
      }

      await _loadTranslations(language.code);

      currentLanguage.value = language;
      isLoading.value = false;

      return true;
    } catch (e) {
      isLoading.value = false;
      return false;
    }
  }

  Future<void> _loadTranslations(String languageCode) async {
    try {
      translations.value = await _languageService.loadTranslations(languageCode);
    } catch (e) {
      if (languageCode != 'en') {
        translations.value = await _languageService.loadTranslations('en');
      } else {
        translations.value = {};
      }
    }
  }

  String translate(String key, {Map<String, String>? parameters}) {
    return _getNestedTranslation(key, parameters);
  }

  String _getNestedTranslation(String key, Map<String, String>? parameters) {
    final keys = key.split('.');
    dynamic current = translations.value;
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

  bool hasTranslation(String key) {
    final keys = key.split('.');
    dynamic current = translations.value;

    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return false;
      }
    }

    return current != null;
  }

  Future<void> reloadTranslations() async {
    isLoading.value = true;
    await _loadTranslations(currentLanguage.value.code);
    isLoading.value = false;
  }

  Future<bool> resetToDeviceLanguage() async {
    final deviceLanguage = await _languageService.getDeviceLanguage();
    return await changeLanguage(deviceLanguage);
  }

  Future<List<AppLanguage>> getAvailableLanguages() async {
    return await _languageService.getAvailableLanguages();
  }
}
