import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompletarPerfilController extends GetxController {
  UserModel2? usuarioInicial;
  final lookupController = Get.find<LookupController>();

  final _supabase = Supabase.instance.client;

  final telefoneController = TextEditingController();
  final selectedVeiculo = RxnString();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserModel2) {
      usuarioInicial = Get.arguments;
      if (usuarioInicial?.telefone != null) {
        telefoneController.text = usuarioInicial!.telefone;
      }
    } else {
      debugPrint("Erro: Nenhum usuário foi passado nos argumentos!");
    }
  }

  final maskTelefone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  Future<void> finalizarCadastro() async {
    if (selectedVeiculo.value == null || telefoneController.text.isEmpty) {
      _showSnackbar(
        'Atenção',
        'Preencha todos os campos para continuar.',
        isError: true,
      );
      return;
    }

    if (usuarioInicial!.id == null) {
      _showSnackbar("Erro", "ID do usuário não encontrado.", isError: true);
      return;
    }

    try {
      isLoading.value = true;

      final dadosAtualizados = {
        'foto_url': usuarioInicial!.fotoUrl,
        'nome': usuarioInicial!.nome,
        'email': usuarioInicial!.email,
        'telefone': telefoneController.text,
        'fk_vehicle': selectedVeiculo.value,
        'criado_em': usuarioInicial!.criadoEm,
        'xp': 0.0,
      };

      await _supabase
          .from('profiles')
          .update(dadosAtualizados)
          .eq('id', usuarioInicial!.id!);

      Get.offAllNamed('/main');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao salvar perfil.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String mensagem, {bool isError = false}) {
    Get.snackbar(
      'Atenção',
      'Preencha todos os campos para continuar.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? const Color(0xFF991010)
          : const Color(0xFF065F46),
      colorText: Colors.white,
      icon: Icon(
        isError
            ? RemixIcons.error_warning_fill
            : RemixIcons.checkbox_circle_fill,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(15),
      borderRadius: 20,
      overlayBlur: 1,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );
  }
}
