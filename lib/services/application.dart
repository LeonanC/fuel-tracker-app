import 'package:intl/intl.dart';

String dbName = 'fuel_tracker.db';
int dbVersion = 1;

final List<String> dbCreate = <String>[
  """
  CREATE TABLE fuel_entries(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo_combustivel TEXT NOT NULL,
    data_abastecimento TEXT NOT NULL,
    posto TEXT,    
    quilometragem DECIMAL(10,2),
    litros DECIMAL(10,2),
    valor_litro DECIMAL(10,2),   
    valor_total DECIMAL(10,2),
    tanque_cheio INTEGER DEFAULT 0,
    comprovante_path TEXT
  )""",
  """CREATE TABLE manutencao(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo TEXT NOT NULL,
    data_servico TEXT NOT NULL,
    quilometragem DECIMAL(10,2),
    custo DECIMAL(10,2),
    observacoes TEXT,
    lembrete_km DECIMAL(10,2),
    lembrete_data TEXT,
    lembrete_ativo INTEGER,
    veiculo_id INTEGER
  )""",
  """CREATE TABLE gas_stations(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    latitude DECIMAL(7,2) NOT NULL,
    longitude DECIMAL(7,2) NOT NULL,
    address TEXT,
    brand TEXT NOT NULL,
    priceGasoline REAL NOT NULL,
    priceEthanol REAL NOT NULL,
    hasConvenientStore INTEGER NOT NULL,
    is24Hours INTEGER NOT NULL
  )"""
];

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

enum DistanceUnit { kilometers, miles }
enum VolumeUnit { liters, gallons }
enum ConsumptionUnit { kmPerLiter, litersPer100km, milesPerGallon }

enum ReminderFrequency {
  disabled,
  daily,
  weekly,
  monthly,
  onFirstEntry
}