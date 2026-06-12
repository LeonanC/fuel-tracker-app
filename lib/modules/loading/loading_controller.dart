import 'dart:async';

import 'package:fuel_tracker_app/modules/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoadingController extends GetxController {
  final _supabase = Supabase.instance.client;

  var progresso = 0.obs;
  var statusMensagem = "Ligando ignição...".obs;
  var temErro = false.obs;

  Timer? _timer;
  bool _dadosCarregados = false;

  @override
  void onInit() {
    super.onInit();
    _iniciarContador();
    inicializarApp();
  }

  void _iniciarContador(){
    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer){
      if(progresso.value < 99){
        progresso.value++;
      }else if (progresso.value == 99 && _dadosCarregados){
        progresso.value = 100;
        _timer?.cancel();
        _finalizarLoading();
      }
    });
  }

  Future<void> inicializarApp() async {
    try {     
      statusMensagem.value = "Autenticando motorista...";
      await Future.delayed(const Duration(milliseconds: 500));
      final session = _supabase.auth.currentSession;

      if (session == null) {
        statusMensagem.value = "Usuário não identificado. Indo para login...";
        _timer?.cancel();
        progresso.value = 100;
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/login');
        return;
      }

      statusMensagem.value = "Carregando dados registrados...";
      await Get.find<HomeController>().fetchData();
      
      statusMensagem.value = "Sincronizando postos e veículos...";
      await Future.delayed(const Duration(milliseconds: 500));

      _dadosCarregados = true;
      if(progresso.value >= 90){
        progresso.value = 100;
        _timer?.cancel();
        _finalizarLoading();
      }
    } catch (e) {
      _timer?.cancel();
      temErro.value = true;
      statusMensagem.value = "Erro ao sincronizar: $e";
    }
  }

  void _finalizarLoading() async {
    statusMensagem.value = "Boa viagem, motorista!";
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed('/main');
  }

  void tentarNovamente(){
    temErro.value = false;
    progresso.value = 0;
    _dadosCarregados = false;
    statusMensagem.value = "Reinciando sistema...";
    _iniciarContador();
    inicializarApp();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
