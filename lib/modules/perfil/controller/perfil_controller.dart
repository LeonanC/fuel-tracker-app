import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:get/get.dart';

class PerfilController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var userModel = Rxn<UserModel2>();

  final int xpPorNivel = 1000;

  @override
  void onInit() {
    super.onInit();
    carregarDadosUsuario();
  }

  void carregarDadosUsuario() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      if (user != null) {
        _firestore.collection('usuarios').doc(user.uid).snapshots().listen((
          doc,
        ) {
          if (doc.exists) {
            userModel.value = UserModel2.fromFirestore(doc);
          }
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar perfil: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int get nivelAtual => ((userModel.value?.xp ?? 0) / xpPorNivel).floor() + 1;

  double get progressoDoNivel {
    double xpAtual = userModel.value?.xp ?? 0;
    return (xpAtual % xpPorNivel) / xpPorNivel;
  }

  double get xpRestante =>
      xpPorNivel - ((userModel.value?.xp ?? 0) % xpPorNivel);

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }
}
