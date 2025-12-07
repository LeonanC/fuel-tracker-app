class TypeGasModel {
  final String id;
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
    String? id,
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
      'id': id,
      'nome': nome,
      'abbr': abbr,
      'octane': octane,
    };
  }

  factory TypeGasModel.fromMap(Map<String, dynamic> map) {
    return TypeGasModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      abbr: map['abbr'] as String,
      octane: map['octane'] as int,
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
