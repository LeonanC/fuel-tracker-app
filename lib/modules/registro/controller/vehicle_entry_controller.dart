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

  Future<void> processarUpload() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      isLoading.value = true;
      try {
        File file = File(pickedFile.path);
        final String fileName =
            'veiculo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String path = 'veiculos/$fileName';
        await _supabase.storage
            .from('fotos_perfil')
            .upload(
              path,
              file,
              fileOptions: FileOptions(
                cacheControl: '3600',
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );

        final String publicUrl = _supabase.storage
            .from('fotos_perfil')
            .getPublicUrl(path);

        selectedImageUrl.value = publicUrl;

        _showCustomSnackbar("Sucesso", "Foto carregado com sucesso!");
      } catch (e) {
        _showCustomSnackbar("Erro no Upload", e.toString(), isError: true);
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final vehicleData = {
        'id': editingEntry?.id,
        'nickname': nicknameController.text,
        'plate': plateController.text.toUpperCase(),
        'make': makeController.text,
        'model': modelController.text,
        'year': int.tryParse(yearController.text) ?? DateTime.now().year,
        'initial_odometer': odometerController.numberValue,
        'tank_capacity': tankCapacityController.numberValue,
        'fk_type_fuel': selectedTipo.value,
        'city': cityController.text,
        'imagem': selectedImageUrl.value,
      };

      if (editingEntry != null) {
        await controller.updateVeiculo(
          VehicleModel.fromMap(vehicleData, editingEntry!.id!),
        );
      } else {
        await controller.saveVeiculo(vehicleData);
      }

      Get.back(result: true);
    } catch (e) {
      Get.back();
      _showCustomSnackbar(
        'Erro',
        'Falha ao salvar o veículo: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
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
      backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
      colorText: Colors.white,
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
