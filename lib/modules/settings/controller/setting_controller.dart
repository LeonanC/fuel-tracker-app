import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingController extends GetxController {
  final _box = GetStorage();

  var isDarkMode = true.obs;
  var language = 'pt_BR'.obs;
  var appVersion = ''.obs;
  var useLitersPer100 = false.obs;
  var useMiles = false.obs;
  var useVolume = false.obs;
  var useConsumption = false.obs;
  var useCurrency = 'R\$'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
    isDarkMode.value = _box.read('dark_mode') ?? true;
    useLitersPer100.value = _box.read('use_liters_per100') ?? false;
    useMiles.value = _box.read('use_miles') ?? false;
    useVolume.value = _box.read('use_volume') ?? false;
    useConsumption.value = _box.read('use_consumption') ?? false;
    useCurrency.value = _box.read('currency_symbol') ?? 'R\$';
  }

  void _loadAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = "${packageInfo.version}+${packageInfo.buildNumber}";
  }

  void changeLanguage(String langCode, String countryCode) {
    var locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);

    _box.write('lang', langCode);
    _box.write('country', countryCode);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _box.write('dark_mode', isDarkMode.value);
  }

  void toggleLitersPer100(bool value) {
    useLitersPer100.value = value;
    _box.write('use_liters_per100', value);
  }

  void toggleUnit(bool value) {
    useMiles.value = value;
    _box.write('use_miles', value);
  }

  void toggleVolume(bool value) {
    useVolume.value = value;
    _box.write('use_volume', value);
  }

  void toggleConsumption(bool value) {
    useConsumption.value = value;
    _box.write('use_consumption', value);
  }

  void setCurrency(String symbol) {
    useCurrency.value = symbol;
    _box.write('currency_symbol', symbol);
  }

  String formatarDistancia(double km) {
    // if (useMiles.value) {
    //   double milhas = km * 0.621371;
    //   return "${milhas.toStringAsFixed(1)} mi";
    // }
    return "${km.toStringAsFixed(1)} km";
  }

  String formatarVolume(double vol) {
    // if (useVolume.value) {
    //   double volume = vol * 0.264172;
    //   return "${volume.toStringAsFixed(1)} gal";
    // }
    return "${vol.toStringAsFixed(1)} L";
  }

  String formatarConsumo(double kmL) {
    // if (useLitersPer100.value) {
    //   double l100 = 100 / kmL;
    //   return "${l100.toStringAsFixed(1)} L/100km";
    // }
    return "${kmL.toStringAsFixed(1)} km/L";
  }

  String formatarCurrency(double valor) {
    return "${useCurrency.value} ${valor.toStringAsFixed(2)}";
  }
}
