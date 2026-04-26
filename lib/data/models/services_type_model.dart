class ServicesTypeModel {
  final String id;
  final String nome;
  final String? abbr;
  final int frequency;

  ServicesTypeModel({
    required this.id,
    required this.nome,
    this.abbr,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'pk_service': id,
      'nome': nome,
      'abbr': abbr,
      'default_frequency_km': frequency,
    };
  }

  factory ServicesTypeModel.fromMap(Map<String, dynamic> map) {
    return ServicesTypeModel(
      id: map['id'],
      nome: map['nome'] as String,
      abbr: map['abbr'] as String,
      frequency: map['default_frequency_km'] as int,
    );
  }
}
