import 'package:intl/intl.dart';




double? currencyToDouble(String value) {
  String cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');
  cleanValue = cleanValue.replaceAll(',', '.');

  if (cleanValue.contains(',')) {
    cleanValue = cleanValue.replaceFirst('.', ',');
    cleanValue = cleanValue.replaceFirst(',', '.');
  }
  return double.tryParse(cleanValue);
}

double? currencyToFloat(String value) {
  return currencyToDouble(value);
}

String doubleToCurrency(double value, {String symbol = 'R\$'}) {
  final NumberFormat nf = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: symbol,
    decimalDigits: 2,
  );
  return nf.format(value);
}

