import 'dart:async';

import 'package:fuel_tracker_app/data/models/fuelentry_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
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
      temErro.value = false;

      statusMensagem.value = "Autenticando motorista...";
      await Future.delayed(const Duration(milliseconds: 500));
      final session = _supabase.auth.currentSession;

      if (session == null) {
        print("Nenhuma sessão encontrada. Redirecionando para Login...");
        statusMensagem.value = "Usuário não identificado. Indo para login...";
        progresso.value = 1.0;

        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
        return;
      }

      final user = session.user;
      progresso.value = 0.2;

      statusMensagem.value = "Sincronizando garagem...";
      final responses = await Future.wait([
        _supabase.from('veiculos').select(),
        _supabase.from('abastecimentos').select().eq('fk_usuario', user.id).order('data'),
      ]);
      progresso.value = 0.8;

      final homeController = Get.put(HomeController(), permanent: true);

      homeController.vehicles.assignAll(
        (responses[0] as List).map((v) => VehicleModel.fromMap(v)).toList(),
        );
      homeController.fuelEntries.assignAll(
        (responses[1] as List).map((e) => FuelEntryModel.fromMap(e)).toList(),
        );
      
      statusMensagem.value = "Tudo pronto!";
      progresso.value = 1.0;

      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed('/main');
    } catch (e) {
      temErro.value = true;
      statusMensagem.value = "Erro ao sincronizar: $e";
      print("Erro LoadingComtroller: $e");
    }
  }

  void tentarNovamente(){
    progresso.value = 0.0;
    inicializarApp();
  }
}
