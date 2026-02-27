import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuel_tracker_app/data/models/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguageCode = 'en';

  Future<AppLanguage> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_languageKey) ?? _defaultLanguageCode;
      return AppLanguage.getByCode(savedCode);
    } catch (e) {
      return AppLanguage.getByCode(_defaultLanguageCode);
    }
  }

  Future<bool> saveLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_languageKey, language.code);
    } catch (e) {
      return false;
    }
  }

  Future<List<AppLanguage>> getAvailableLanguages() async {
    try {
      return AppLanguage.supportedLanguages;
    } catch (e) {
      return [AppLanguage.getByCode(_defaultLanguageCode)];
    }
  }

  Future<Map<String, dynamic>> loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/languages/$languageCode.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap;
    } catch (e) {
      if (languageCode != _defaultLanguageCode) {
        return await loadTranslations(_defaultLanguageCode);
      }
      return {};
    }
  }

  String getDeviceLocale() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      return locale.languageCode;
    } catch (e) {
      return _defaultLanguageCode;
    }
  }

  bool isLanguageSupported(String languageCode) {
    return AppLanguage.supportedLanguages.contains(languageCode);
  }

  Future<AppLanguage> getDeviceLanguage() async {
    final deviceLocale = getDeviceLocale();
    if (isLanguageSupported(deviceLocale)) {
      return AppLanguage.getByCode(deviceLocale);
    }
    for (final supportedCode in AppLanguage.supportedLocales) {
      if (deviceLocale.startsWith(supportedCode)) {
        return AppLanguage.getByCode(supportedCode);
      }
    }
    return AppLanguage.getByCode(_defaultLanguageCode);
  }

  Future<AppLanguage> initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_languageKey);
      if (savedCode != null) {
        return AppLanguage.getByCode(savedCode);
      } else {
        final deviceLanguage = await getDeviceLanguage();
        await saveLanguage(deviceLanguage);
        return deviceLanguage;
      }
    } catch (e) {
      return AppLanguage.getByCode(_defaultLanguageCode);
    }
  }

  Future<bool> clearSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_languageKey);
    } catch (e) {
      return false;
    }
  }
}
