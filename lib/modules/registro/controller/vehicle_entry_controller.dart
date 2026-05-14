import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fuel_tracker_app/data/controllers/lookup_controller.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:fuel_tracker_app/modules/vehicle/controller/vehicle_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleEntryController extends GetxController {
  final controller = Get.find<VehicleController>();
  final lookupController = Get.find<LookupController>();
  final formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  late TextEditingController nicknameController;
  late TextEditingController makeController;
  late TextEditingController modelController;
  late TextEditingController plateController;
  late TextEditingController yearController;
  late MoneyMaskedTextController tankCapacityController;
  late MoneyMaskedTextController odometerController;
  late TextEditingController cityController;

  var selectedImageUrl = ''.obs;
  var isLoading = false.obs;
  var isMercosul = false.obs;
  var selectedTipo = RxnString();

  VehicleModel? editingEntry;

  void inicializer(VehicleModel? entry) {
    editingEntry = entry;

    nicknameController = TextEditingController(
      text: entry?.nickname.toString() ?? '',
    );
    makeController = TextEditingController(text: entry?.make.toString() ?? '');
    modelController = TextEditingController(
      text: entry?.model.toString() ?? '',
    );
    yearController = TextEditingController(text: entry?.year.toString() ?? '');
    plateController = TextEditingController(
      text: entry?.plate.toString() ?? '',
    );

    plateController.addListener(() => update());

    tankCapacityController = MoneyMaskedTextController(
      initialValue: entry?.tankCapacity ?? 0.0,
      decimalSeparator: ',',
      thousandSeparator: '',
      precision: 1,
    );
    odometerController = MoneyMaskedTextController(
      initialValue: entry?.initialOdometer ?? 0.0,
      decimalSeparator: ',',
      thousandSeparator: '',
      precision: 1,
    );
    cityController = TextEditingController(text: entry?.city ?? '');

    if (entry != null) {
      selectedTipo.value = entry.fuelType;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if(pickedFile != null){
      selectedImageUrl.value = pickedFile.path;
    }
  }

  Future<String?> _processarUpload() async {
    if(selectedImageUrl.value.isEmpty || selectedImageUrl.value.startsWith('http')){
      return selectedImageUrl.value;
    }
    try {
      final file = File(selectedImageUrl.value);
      final fileName = 'veiculo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'veiculos/$fileName';

      await _supabase.storage
      .from('fotos_perfil')
      .upload(
        path,
        file,
        fileOptions: FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      return _supabase.storage.from('fotos_perfil').getPublicUrl(path);    
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao selecionar imagem: $e');
      return null;
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    String? remoteUrl = await _processarUpload();

    try {
      final Map<String, dynamic> vehicleData = {
        'pk_vehicle': editingEntry?.id,
        'nickname': nicknameController.text,
        'make': makeController.text,
        'model': modelController.text,
        'year': int.tryParse(yearController.text) ?? DateTime.now().year,
        'plate': plateController.text.toUpperCase(),
        'tank_capacity': tankCapacityController.numberValue,
        'initial_odometer': odometerController.numberValue,
        'is_mercosul': isMercosul.value,
        'city': cityController.text,
        'fk_type_fuel': selectedTipo.value,
        'imagem': remoteUrl,
      };

      if (editingEntry != null) {
        final updatedModel = VehicleModel.fromMap(
          vehicleData,
          editingEntry!.id!.toString(),
        );
        await controller.updateVeiculo(updatedModel);
      } else {
        await controller.saveVeiculo(vehicleData);
      }

      Get.back();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erro',
        'Falha ao salvar o veículo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
