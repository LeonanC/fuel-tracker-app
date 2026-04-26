import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:fuel_tracker_app/data/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  final lookupController = Get.find<LookupController>();

  var isLoading = false.obs;
  var isLogin = true.obs;
  var isForgotPassword = false.obs;
  var obscureText = true.obs;
  var selectedVeiculos = RxnString();
  var fotoUrl = RxnString();

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
  final maskTelefone = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void alternarEsqueciSenha(){
    isForgotPassword.value = !isForgotPassword.value;
    isLogin.value = true;
  }

  void toggleObscure() => obscureText.value = !obscureText.value;
  void toggleAuthMode() => isLogin.value = !isLogin.value;

  void realizarAuth() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      if (isLogin.value) {
        await _authService.login(
          emailController.text.trim(),
          senhaController.text.trim(),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        
        Get.offAllNamed('/main');
      } else {
        String? vehicleId = selectedVeiculos.value;
        if(vehicleId != null && vehicleId.isEmpty) vehicleId = null;

        final novoUsuario = UserModel2(
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          telefone: telefoneController.text.trim(),
          vehicle: selectedVeiculos.value,
          fotoUrl: fotoUrl.value,
          xp: 0.0,
        );
        await _authService.signUp(novoUsuario, senhaController.text.trim());

        _showCustomSnackbar("Sucesso", "Cadastro realizado! Verfique seu e-mail se necessário.");

        isLogin.value = true;
        nomeController.clear();
        telefoneController.clear();
      }
    } catch (e) {
      _showCustomSnackbar(
        "Erro",
        "Ocorreu um erro inesperado: $e",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selecionarEFazerUploadFoto() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if(image != null){
      isLoading.value = true;
      try{
        File file = File(image.path);
        final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String path = 'perfis/$fileName';

        await _supabase.storage.from('fotos_perfil').upload(path, file, fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

        final String publicUrl = _supabase.storage.from('fotos_perfil').getPublicUrl(path);
        fotoUrl.value = publicUrl;
        _showCustomSnackbar("Sucesso", "Foto carregada com sucesso!");
      }catch(e){
        _showCustomSnackbar("Erro no Upload", e.toString(), isError: true);
        print(e.toString());
      }finally{
        isLoading.value = false;
      }
    }
  }

  Future<void> forgotPassword() async {
    isLoading.value = true;
    if (isForgotPassword.value) {
      await _authService.recuperarSenha(emailController.text.trim());
    }

    isLoading.value = false;
  }

  void _showCustomSnackbar(
    String titulo,
    String mensagem, {
    bool isError = false,
  }) {
    Get.snackbar(
      titulo,
      mensagem,
      snackPosition: SnackPosition.BOTTOM,
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

  @override
  void onClose() {
    emailController.dispose();
    senhaController.dispose();
    nomeController.dispose();
    telefoneController.dispose();
    xpController.dispose();
    super.onClose();
  }
}
