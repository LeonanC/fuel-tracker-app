import 'package:flutter/material.dart';

class UserModel2 {
  final String? id;
  final String? fotoUrl;
  final String nome;
  final String email;
  final String telefone;
  final String? vehicle;
  final DateTime? criadoEm;
  final double xp;

  UserModel2({
    this.id,
    required this.nome,
    this.fotoUrl,
    required this.email,
    required this.telefone,
    required this.vehicle,
    this.criadoEm,
    required this.xp,
  });

  
  UserModel2 copyWith({String? id}) {
    return UserModel2(
      id: id,
      nome: nome,
      fotoUrl: fotoUrl,
      email: email,
      telefone: telefone,
      vehicle: vehicle,
      xp: xp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if(id != null && id!.isNotEmpty) 'id': id,
      'nome': nome,
      'foto_url': fotoUrl,
      'email': email,
      'telefone': telefone,
      'fk_vehicle': vehicle,
      'xp': xp,
      if(criadoEm != null) 'criado_em': criadoEm!.toIso8601String(),
    };
  }

  factory UserModel2.fromMap(Map<String, dynamic> map) {
    return UserModel2(
      id: map['id']?.toString(),
      fotoUrl: map['foto_url'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      vehicle: map['fk_vehicle'] ?? '',
      criadoEm: map['criado_em'] != null
      ? DateTime.parse(map['criado_em'])
      : null,
      xp: (map['xp'] as num?)?.toDouble() ?? 0.0,
    );
  }


  Color get corDoRank => xp > 1000 ? Colors.amber : Colors.blueAccent;
  String get nomeDoRank => xp > 1000 ? "Motorista Ouro" : "Motorista Prata";
}
