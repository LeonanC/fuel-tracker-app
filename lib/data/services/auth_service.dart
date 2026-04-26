import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  var isLoading = false.obs;

  Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String telefone,
    String? vehicleId,
    required double xp,
    required String password,
  }) async {
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final String? userId = res.user?.id;

    if (userId == null) return;

    await _supabase.from('usuarios').insert({
      'id': userId,
      'foto_url': '',
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'fk_vehicle': vehicleId,
      'xp': xp,
      'criado_em': DateTime.now(),
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        _showCustomSnackbar("Sucesso", "Login realizado com sucesso!");
      }
    } on AuthException catch (error) {
      _showCustomSnackbar("Erro de Autenticação", error.message, isError: true);
    } catch (error) {
      _showCustomSnackbar("Erro", "Ocorreu um erro inesperado.", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(UserModel2 user, String password) async {
    try {
      isLoading.value = true;
      await _supabase.auth.signUp(
        email: user.email,
        password: password,
        data: {
          'nome': user.nome,
          'telefone': user.telefone,
          'fk_vehicle': user.vehicle,
          'foto_url': user.fotoUrl,
          'criado_em': DateTime.now().toIso8601String(),
        },
      );
      await Future.delayed(const Duration(milliseconds: 100));
      Get.offAllNamed('/login');
    } on AuthException catch (error) {
      _showCustomSnackbar("Erro de Autenticação", error.message, isError: true);
    } catch (error) {
      _showCustomSnackbar("Erro", "Ocorreu um erro inesperado 2.", isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recuperarSenha(String email) async {
    try{
      isLoading.value = true;

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'br.com.fuel.tracker.app://reset-password/',
      );

      _showCustomSnackbar(
        "E-mail enviado",
        "Verifique sua caixa de entrada para redefinir a senha.",
      );
    } on AuthException catch (e) {
      _showCustomSnackbar("Erro", e.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel2?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel2.fromMap(response);
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
}
