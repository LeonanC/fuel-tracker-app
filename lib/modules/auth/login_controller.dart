import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/user_model.dart';
import 'package:fuel_tracker_app/data/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final lookupController = Get.find<LookupController>();

  var isLogin = true.obs;
  var forgotPassword = false.obs;
  var isLoading = false.obs;
  var obscureText = true.obs;
  var selectedVeiculos = RxnString();

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
  void toggleForgotPassword() => forgotPassword.value = !forgotPassword.value;
  void toggleObscure() => obscureText.value = !obscureText.value;

  final maskTelefone = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

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
          fotoUrl: '',
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

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
            await _googleSignIn.initialize(
        serverClientId:
            '391534008822-tg5rhcoir6a3k8nag3pf6kgtf6q0uopo.apps.googleusercontent.com',
      );

      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      
      final String? idToken = account.authentication.idToken;
      
      final authz = await account.authorizationClient.authorizeScopes(['email', 'profile']);
      final String accessToken = authz.accessToken;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if(user != null){
        DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).get();
        if(doc.exists){
          debugPrint("Usuário recorrente: ${user.displayName}");
          Get.offAllNamed('/main');
        }else{
          UserModel2 novoUsuario = UserModel2(
            id: user.uid,
            fotoUrl: user.photoURL ?? '',
            nome: user.displayName ?? "Motorista",
            email: user.email ?? '',
            telefone: user.phoneNumber ?? '',
            vehicle: null,
            criadoEm: DateTime.now(),
            xp: 0.0,
          );
          await _firestore.collection('usuarios').doc(user.uid).set(novoUsuario.toMap());
          Get.offAllNamed('/completar-perfil', arguments: novoUsuario);
        }
      }
    }catch(e){   
      if(e is GoogleSignInException && e.code == 'canceled'){
        debugPrint("Login cancelado pelo usuário.");
        return;
      }

      debugPrint("Erro detalhado: $e");
      _showCustomSnackbar(
        titulo: "Erro",
        mensagem: "Falha ao autenticação. Verique sua conexão ou chaves SHA-1.",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> esqueceuSenha() async {
    if (emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text)) {
      _showCustomSnackbar(
        titulo: "Atenção",
        mensagem: "Por favor, insira um e-mail válido para recuperar a senha.",
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      final email = emailController.text.trim();

      final userQuery = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        _showCustomSnackbar(
          titulo: "Erro",
          mensagem: "Este e-mail não está cadastrado em nossa base.",
          isError: true,
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      _showCustomSnackbar(
        titulo: "Sucesso",
        mensagem:
            "E-mail de recuperação enviado! Verifique sua caixa de entrada.",
      );
    } catch (e) {
      _showCustomSnackbar(
        titulo: "Erro",
        mensagem: "Não foi possível processar a recuperação agora.",
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
    if (e.code == 'email-already-in-use') {
      mensagem = "Este e-mail já está sendo usado.";
    }
    if (e.code == 'weak-password') {
      mensagem = "A senha escolhida é muito fraca.";
    }
    _showCustomSnackbar(titulo: "Falha", mensagem: mensagem, isError: true);
  }



  void _showCustomSnackbar({
    required String titulo,
    required String mensagem,
    bool isError = false,
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

    @override
  void onClose() {
    emailController.dispose();
    senhaController.dispose();
    nomeController.dispose();
    telefoneController.dispose();
    selectedVeiculos.value;
    super.onClose();
  }
}
