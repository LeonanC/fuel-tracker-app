import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingController extends GetxController {
  final _box = GetStorage();

  var isDarkMode = true.obs;
  var language = 'pt_BR'.obs;
  var appVersion = ''.obs;
  var useConsumption = false.obs;
  var useCurrency = 'R\$'.obs;
  var precoGasolina = 0.0.obs;
  var precoEtanol = 0.0.obs;
  var placaFinal = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
    isDarkMode.value = _box.read('dark_mode') ?? true;
    useConsumption.value = _box.read('use_consumption') ?? false;
    useCurrency.value = _box.read('currency_symbol') ?? 'R\$';
    placaFinal.value = _box.read('placa_final') ?? 0;
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

  void toggleConsumption(bool value) {
    useConsumption.value = value;
    _box.write('use_consumption', value);
  }

  void setPlacaFinal(int valor) {
    placaFinal.value = valor;
    _box.write('placa_final', valor);
  }

  void setCurrency(String symbol) {
    useCurrency.value = symbol;
    _box.write('currency_symbol', symbol);
  }

  String formatarDistancia(double km) {
    return "${km.toStringAsFixed(0)} km";
  }

  String formatarVolume(double vol) {
    return "${vol.toStringAsFixed(1)} L";
  }

  String formatarConsumo(double kmL) {
    return "${kmL.toStringAsFixed(0)} km/L";
  }

  String get calcularFlex {
    if (precoEtanol.value <= 0 || precoGasolina.value <= 0){
      return "Insire os preços para comparar";
    }

    double razao = precoEtanol.value / precoGasolina.value;

    if(razao < 0.7){
      double poupanca = (0.7 - razao) * 100;
    return "Abasteça com Etanol\n(Economia de aprox. ${poupanca.toStringAsFixed(0)}%)";
    }else if(razao == 0.7){
      return "Tanto faz! A eficiência é equivalente.";
    }else{
     return "Abasteça com Gasolina";
    }
  }

  double calcularCustoPor100Km(double precoLitro, double consumoKmK) {
    if (consumoKmK <= 0) return 0.0;
    return (100 / consumoKmK) * precoLitro;
  }

  String formatarCurrency(double valor) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valor);
  }

  final Map<int, List<DateTime>> calendarioIPVA = {
    0: [DateTime(2026, 01, 21), DateTime(2026, 02, 20), DateTime(2026, 03, 23)],
    1: [DateTime(2026, 01, 22), DateTime(2026, 02, 23), DateTime(2026, 03, 26)],
    2: [DateTime(2026, 01, 23), DateTime(2026, 02, 24), DateTime(2026, 03, 27)],
    3: [DateTime(2026, 01, 26), DateTime(2026, 02, 25), DateTime(2026, 03, 30)],
    4: [DateTime(2026, 01, 27), DateTime(2026, 02, 26), DateTime(2026, 03, 31)],
    5: [DateTime(2026, 01, 28), DateTime(2026, 02, 27), DateTime(2026, 04, 01)],
    6: [DateTime(2026, 01, 29), DateTime(2026, 03, 02), DateTime(2026, 04, 06)],
    7: [DateTime(2026, 01, 30), DateTime(2026, 03, 03), DateTime(2026, 04, 07)],
    8: [DateTime(2026, 02, 02), DateTime(2026, 03, 04), DateTime(2026, 04, 08)],
    9: [DateTime(2026, 02, 03), DateTime(2026, 03, 05), DateTime(2026, 04, 09)],
  };

  List<String> obterDatasVencimento(){
    List<DateTime> datas = calendarioIPVA[placaFinal.value]!;
    DateFormat df = DateFormat('dd/MM/yyyy');
    return datas.map((d) => df.format(d)).toList();
  }

  String? alertaVencimento(){
    DateTime hoje = DateTime.now();
    List<DateTime> datas = calendarioIPVA[placaFinal.value]!;

    for(int i = 0; i < datas.length; i++){
      int diferenca = datas[i].difference(hoje).inDays;
      if(diferenca >= 0 && diferenca <= 7){
        return "Atenção: A ${i + 1}ª parcela vence em $diferenca dias!";
      }
    }
    return null;
  }
}
