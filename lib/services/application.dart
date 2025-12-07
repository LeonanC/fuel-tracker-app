import 'package:intl/intl.dart';

String dbName = 'fuel_tracker.db';
int dbVersion = 1;

final List<String> dbCreate = <String>[
  """
  CREATE TABLE fuel_entries(
    id TEXT PRIMARY KEY,
    data_abastecimento TEXT NOT NULL,
    fuel_type TEXT,
    posto TEXT, 
    veiculo TEXT,   
    quilometragem DECIMAL(10,2),
    litros DECIMAL(10,2),
    valor_litro DECIMAL(10,2),   
    valor_total DECIMAL(10,2),
    tanque_cheio INTEGER DEFAULT 0,
    comprovante_path TEXT
  )""",
  """CREATE TABLE manutencao(
    id TEXT PRIMARY KEY,
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
  """CREATE TABLE vehicles(
    id TEXT PRIMARY KEY,
    nickname TEXT NOT NULL,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    fuel_type TEXT,
    year INTEGER,
    initial_odometer REAL,
    imagem_url TEXT NOT NULL,
    created_at TEXT
  )""",
  """CREATE TABLE gas_stations(
    id TEXT PRIMARY KEY,
    nome TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    address TEXT,
    brand TEXT NOT NULL,
    priceGasolineComum REAL NOT NULL,
    priceGasolineAditivada REAL NOT NULL,
    priceGasolinePremium REAL NOT NULL,
    priceEthanol REAL NOT NULL,
    hasConvenientStore INTEGER NOT NULL,
    is24Hours INTEGER NOT NULL
  )""",
  """CREATE TABLE fuel_types(
    id TEXT PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE,
    abbr TEXT,
    octane_rating INTEGER DEFAULT 0
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

