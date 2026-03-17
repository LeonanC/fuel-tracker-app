import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:fuel_tracker_app/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final lookupController = Get.find<LookupController>();

  var isLogin = true.obs;
  var isLoading = false.obs;
  var obscureText = true.obs;
  var selectedVeiculos = RxnInt();

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final xpController = MoneyMaskedTextController(
    thousandSeparator: '.',
    decimalSeparator: ',',
    precision: 0,
  );

  void toggleAuthMode() => isLogin.value = !isLogin.value;
  void toggleObscure() => obscureText.value = !obscureText.value;

  void realizarAuth() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      if (isLogin.value) {
        await _authService.login(
          emailController.text.trim(),
          senhaController.text.trim(),
        );
        Get.offAllNamed('/main');
      } else {
        final novoUsuario = UserModel2(
          id: '',
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          telefone: telefoneController.text.trim(),
          vehicle: selectedVeiculos.value,
          xp: xpController.numberValue,
        );

        await _authService.cadastrarUsuario(
          userModel: novoUsuario,
          password: senhaController.text.trim(),
        );

        _showCustomSnackbar(
          titulo: "Conta criada!",
          mensagem: "Bem-vindo ao Fuel Tracker, Usuario: ${novoUsuario.nome}",
          isError: false,
        );
        isLogin.value = true;
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showCustomSnackbar(
        titulo: "Erro",
        mensagem: "Ocorreu um erro inesperado: $e",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String mensagem = "Erro ao processar autenticação.";
    if (e.code == 'user-not_found') mensagem = "E-mail não encontrado.";
    if (e.code == 'wrong-password') mensagem = "Senha incorreta.";
    if (e.code == 'email-already-in-use')
      mensagem = "Este e-mail já está sendo usado.";
    if (e.code == 'weak-password')
      mensagem = "A senha escolhida é muito fraca.";
    _showCustomSnackbar(titulo: "Falha", mensagem: mensagem, isError: true);
  }

  @override
  void onClose() {
    emailController.dispose();
    senhaController.dispose();
    nomeController.dispose();
    telefoneController.dispose();
    selectedVeiculos.value;
    super.onClose();
  }

  void _showCustomSnackbar({
    required String titulo,
    required String mensagem,
    required bool isError,
  }) {
    Get.snackbar(
      titulo,
      mensagem,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError
          ? const Color(0xFF991B1B)
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
