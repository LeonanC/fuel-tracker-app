import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel2 {
  final String? id;
  final String nome;
  final String email;
  final String telefone;
  final int? vehicle;
  final DateTime? criadoEm;
  final double xp;

  UserModel2({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.vehicle,
    this.criadoEm,
    required this.xp,
  });

  factory UserModel2.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return UserModel2(
      id: doc.id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      vehicle: map['fk_vehicle'] ?? '',
      criadoEm: (map['criado_em'] as Timestamp?)?.toDate(),
      xp: map['xp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'fk_vehicle': vehicle,
      'criado_em': FieldValue.serverTimestamp(),
      'xp': xp,
    };
  }

  Color get corDoRank => xp > 1000 ? Colors.amber : Colors.blueAccent;
  String get nomeDoRank => xp > 1000 ? "Motorista Ouro" : "Motorista Prata";
}
