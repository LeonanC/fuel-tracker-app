import 'dart:async';

import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoadingController extends GetxController {
  final _supabase = Supabase.instance.client;

  var progresso = 0.0.obs;
  var statusMensagem = "Ligando ignição...".obs;
  var temErro = false.obs;

  @override
  void onInit() {
    super.onInit();
    inicializarApp();
  }

  Future<void> inicializarApp() async {
    try {     
      statusMensagem.value = "Autenticando motorista...";
      await Future.delayed(const Duration(milliseconds: 500));
      final session = _supabase.auth.currentSession;

      if (session == null) {
        statusMensagem.value = "Usuário não identificado. Indo para login...";
        progresso.value = 1.0;

        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
        return;
      }

      progresso.value = 0.2;

      statusMensagem.value = "Sincronizando garagem...";
      progresso.value = 0.5;

      await Get.find<HomeController>().fetchData();
      
      statusMensagem.value = "Tudo pronto!";
      progresso.value = 1.0;

      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed('/main');
    } catch (e) {
      temErro.value = true;
      statusMensagem.value = "Erro ao sincronizar: $e";
    }
  }

  void tentarNovamente(){
    progresso.value = 0.0;
    inicializarApp();
  }
}
