import 'package:intl/intl.dart';

String dbName = 'fuel_tracker.db';
int dbVersion = 1;

final List<String> dbCreate = <String>[
  """
  CREATE TABLE fuel_entries(
    pk_fuel INTEGER PRIMARY KEY AUTOINCREMENT,
    fk_vehicle INTEGER NOT NULL,  
    fk_type_fuel INTEGER NOT NULL,
    fk_station INTEGER NOT NULL,
    entry_date TEXT,
    odometer_km DECIMAL(10,2),
    volume_liters TEXT,
    price_per_liter DECIMAL(10,2),   
    total_cost DECIMAL(10,2),
    tank_full INTEGER DEFAULT 0,
    receipt_path TEXT,
    FOREIGN KEY (fk_vehicle) REFERENCES vehicles (pk_vehicle) ON DELETE CASCADE,
    FOREIGN KEY (fk_type_fuel) REFERENCES fuel_types (pk_type_fuel) ON DELETE CASCADE,
    FOREIGN KEY (fk_station) REFERENCES gas_stations (pk_station) ON DELETE CASCADE
  )""",
  """CREATE TABLE manutencao(
    pk_manutencao INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo TEXT NOT NULL,
    data_servico TEXT NOT NULL,
    quilometragem DECIMAL(10,2),
    custo DECIMAL(10,2),
    observacoes TEXT,
    lembrete_km DECIMAL(10,2),
    lembrete_data TEXT,
    lembrete_ativo INTEGER,
    fk_vehicle INTEGER,
    FOREIGN KEY (fk_vehicle) REFERENCES vehicles (pk_vehicle) ON DELETE CASCADE
  )""",
  """CREATE TABLE vehicles(
    pk_vehicle INTEGER PRIMARY KEY AUTOINCREMENT,
    nickname TEXT NOT NULL,
    plate TEXT,
    is_mercosul INTEGER DEFAULT 1,
    city TEXT,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    fk_type_fuel INTEGER,
    year INTEGER,
    initial_odometer REAL,
    tank_capacity REAL,
    imagem_url TEXT NOT NULL,
    created_at TEXT,
    FOREIGN KEY (fk_type_fuel) REFERENCES fuel_types (pk_type_fuel) ON DELETE CASCADE
  )""",
  """CREATE TABLE gas_stations(
    pk_station INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_posto TEXT NOT NULL,
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
    pk_type_fuel INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    abbr TEXT,
    octane_rating INTEGER DEFAULT 0
  )""",
  """CREATE TABLE service_types(
    pk_service INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    abbr TEXT,
    default_frequency_km INTEGER DEFAULT 0
  )""",
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
  final NumberFormat nf = NumberFormat.currency(locale: 'pt_BR', symbol: symbol, decimalDigits: 2);
  return nf.format(value);
}
