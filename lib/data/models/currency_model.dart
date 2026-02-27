class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

final List<Currency> availableCurrencies = [
  const Currency(code: 'BRL', symbol: 'R\$', name: 'Real Brasileiro'),
  const Currency(code: 'USD', symbol: '\$', name: 'Dólar Americano'),
  const Currency(code: 'EUR', symbol: '€', name: 'Euro'),
  const Currency(code: 'ARS', symbol: '\$', name: 'Peso Argentino'),
];