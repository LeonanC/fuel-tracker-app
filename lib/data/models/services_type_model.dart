class ServicesTypeModel {
  final int id;
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
    int? id,
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
      'pk_service': id,
      'nome': nome,
      'abbr': abbr,
      'default_frequency_km': frequency,
    };
  }

  factory ServicesTypeModel.fromFirestore(Map<String, dynamic> map, String id) {
    return ServicesTypeModel(
      id: int.tryParse(id) ?? 0,
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
