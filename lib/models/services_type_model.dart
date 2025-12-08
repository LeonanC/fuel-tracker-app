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

  ServicesTypeModel copyWith({
    String? id,
    String? nome,
    String? abbr,
    int? frequency,
  }) {
    return ServicesTypeModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      abbr: abbr ?? this.abbr,
      frequency: frequency ?? this.frequency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'abbr': abbr,
      'default_frequency_km': frequency,
    };
  }

  factory ServicesTypeModel.fromMap(Map<String, dynamic> map) {
    return ServicesTypeModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      abbr: map['abbr'] as String,
      frequency: map['default_frequency_km'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServicesTypeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
