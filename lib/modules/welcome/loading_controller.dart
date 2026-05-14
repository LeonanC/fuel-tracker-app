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
      final session = _supabase.auth.currentSession;

      if (session == null || session.user == null) {
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
        return;
      }

      final user = session.user!;
      progresso.value = 0.1;

      statusMensagem.value = "Carregando dados do veículo...";
      final veiculoData = await _supabase.from('veiculos').select();
      progresso.value = 0.4;

      statusMensagem.value = "Sincronizando abastecimentos...";
      final List<dynamic> historicoData = await _supabase
          .from('abastecimentos')
          .select()
          .eq('fk_usuario', user.id)
          .order('data', ascending: false);
      progresso.value = 0.8;

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();

        homeController.vehicles.assignAll(
          veiculoData.map((v) => VehicleModel.fromMap(v)).toList(),
        );

        homeController.fuelEntries.assignAll(
          historicoData.map((e) => FuelEntryModel.fromMap(e)).toList(),
        );
      }

      statusMensagem.value = "Tudo pronto!";
      progresso.value = 1.0;

      await Future.delayed(const Duration(milliseconds: 800));
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
