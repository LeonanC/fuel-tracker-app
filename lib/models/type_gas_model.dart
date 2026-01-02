class TypeGasModel {
  final int id;
  final String nome;
  final String? abbr;
  final int octane;

  TypeGasModel({
    required this.id,
    required this.nome,
    this.abbr,
    required this.octane,
  });

  TypeGasModel copyWith({
    int? id,
    String? nome,
    String? abbr,
    int? octane,
  }) {
    return TypeGasModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      abbr: abbr ?? this.abbr,
      octane: octane ?? this.octane,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_type_fuel': id,
      'nome': nome,
      'abbr': abbr,
      'octane_rating': octane,
    };
  }

  factory TypeGasModel.fromMap(Map<String, dynamic> map) {
    return TypeGasModel(
      id: map['pk_type_fuel'] as int,
      nome: map['nome'] as String,
      abbr: map['abbr'] as String,
      octane: map['octane_rating'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TypeGasModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
