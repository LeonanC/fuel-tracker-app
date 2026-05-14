import 'dart:async';

import 'package:get/get.dart';

class LoadingController extends GetxController {
  var progresso = 0.0.obs;
  var statusMensagem = "Carregando deus dados...".obs;

  @override
  void onInit() {
    super.onInit();
    simularCarregamento();
  }

  void simularCarregamento(){
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if(progresso.value < 1.0){
        progresso.value += 0.01;
        if(progresso.value > 0.3) statusMensagem.value = "Sincronizando com Supabase...";
        if(progresso.value > 0.6) statusMensagem.value = "Carregando seu abestecimentos...";
        if(progresso.value > 0.9) statusMensagem.value = "Finalizando...";
      }else{
        timer.cancel();
        Get.offAllNamed('/main');
      }
    });
  }

}