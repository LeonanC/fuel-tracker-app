import 'package:fuel_tracker_app/utils/unit_nums.dart';
import 'package:get/get.dart';

class CurrencyController  extends GetxController {
  static const Map<CurrencyUnit, String> _currencySymbols = {
    CurrencyUnit.brl: 'R\$',
    CurrencyUnit.usd: '\$',
    CurrencyUnit.eur: '€',
  };

  final currencySymbol = 'R\$'.obs;

  void setCurrencySymbol(CurrencyUnit unit){
    final newSymbol = _currencySymbols[unit] ?? 'R\$';
    if(currencySymbol.value != newSymbol){
      currencySymbol.value = newSymbol;
    }
  }

  String get currentSymbol => currencySymbol.value;
  

}