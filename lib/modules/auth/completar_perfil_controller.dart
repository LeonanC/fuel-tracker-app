import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CompletarPerfilController extends GetxController {
  UserModel2? usuarioInicial;
  final lookupController = Get.find<LookupController>();

  final telefoneController = TextEditingController();
  final selectedVeiculo = RxnInt();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserModel2) {
      usuarioInicial = Get.arguments;
    } else {
      print("Erro: Nenhum usuário foi passado nos argumentos!");
    }
  }

  final maskTelefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  Future<void> finalizarCadastro() async {
    if (selectedVeiculo.value == null || telefoneController.text.isEmpty) {
      Get.snackbar('Atenção', 'Preencha todos os campos para continuar.');
      return;
    }

    try {
      isLoading.value = true;

      UserModel2 perfilCompleto = UserModel2(
        id: usuarioInicial!.id,
        fotoUrl: usuarioInicial!.fotoUrl,
        nome: usuarioInicial!.nome,
        email: usuarioInicial!.email,
        telefone: telefoneController.text,
        vehicle: selectedVeiculo.value,
        criadoEm: usuarioInicial!.criadoEm,
        xp: 0.0,
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(perfilCompleto.id)
          .set(perfilCompleto.toMap());

      Get.offAllNamed('/main');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao salvar perfil.');
    } finally {
      isLoading.value = false;
    }
  }
}
