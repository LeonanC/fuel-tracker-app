import 'dart:ui';

import 'package:fuel_tracker_app/modules/fuel/controllers/currency_controller.dart';
import 'package:fuel_tracker_app/core/unit_nums.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitController extends GetxController {
  static const String _distanceKey = 'distance_unit';
  static const String _volumeKey = 'volume_unit';
  static const String _consumptionKey = 'consumption_unit';
  static const String _currencyKey = 'currency_unit';

  final CurrencyController currencyController = Get.find<CurrencyController>();

  var distanceUnit = DistanceUnit.kilometers.obs;
  var volumeUnit = VolumeUnit.liters.obs;
  var consumptionUnit = ConsumptionUnit.kmPerLiter.obs;
  var currencyUnit = CurrencyUnit.brl.obs;

  @override
  void onInit() {
    _loadUnits();
    super.onInit();
  }

  Future<void> _loadUnits() async {
    final prefs = await SharedPreferences.getInstance();

    final distanceIndex =
        prefs.getInt(_distanceKey) ?? DistanceUnit.kilometers.index;
    if (distanceIndex >= 0 && distanceIndex < DistanceUnit.values.length) {
      distanceUnit.value = DistanceUnit.values[distanceIndex];
    } else {
      distanceUnit.value = DistanceUnit.kilometers;
    }

    final volumeIndex = prefs.getInt(_volumeKey) ?? VolumeUnit.liters.index;
    if (volumeIndex >= 0 && volumeIndex < VolumeUnit.values.length) {
      volumeUnit.value = VolumeUnit.values[volumeIndex];
    } else {
      volumeUnit.value = VolumeUnit.liters;
    }

    final consumptionIndex =
        prefs.getInt(_consumptionKey) ?? ConsumptionUnit.kmPerLiter.index;
    if (consumptionIndex >= 0 &&
        consumptionIndex < ConsumptionUnit.values.length) {
      consumptionUnit.value = ConsumptionUnit.values[consumptionIndex];
    } else {
      consumptionUnit.value = ConsumptionUnit.kmPerLiter;
    }

    final currencyIndex = prefs.getInt(_currencyKey) ?? CurrencyUnit.brl.index;
    if (currencyIndex >= 0 && currencyIndex < CurrencyUnit.values.length) {
      currencyUnit.value = CurrencyUnit.values[currencyIndex];
    } else {
      currencyUnit.value = CurrencyUnit.brl;
    }

    currencyController.setCurrencySymbol(currencyUnit.value);
  }

  void _saveUnit<T extends Enum>(
    Rx<T> reactiveUnit,
    T unit,
    String key,
    String unitDescription,
  ) {
    reactiveUnit.value = unit;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(key, unit.index);
      Get.snackbar(
        'Configuração Salva'.tr,
        'A unidade de $unitDescription foi alterada para ${unit.name}.'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor:
            Get.theme.snackBarTheme.backgroundColor?.withOpacity(0.9) ??
            const Color(0xFF673AB7).withOpacity(0.9),
        colorText:
            Get.theme.snackBarTheme.actionTextColor ??
            Get.theme.colorScheme.onSecondary,
      );
    });
  }

  String get currencyUnitString {
    return currencyController.currencySymbol.value;
  }

  void setDistanceUnit(DistanceUnit? unit) async {
    if (unit != null && distanceUnit.value != unit) {
      _saveUnit(distanceUnit, unit, _distanceKey, 'Distância');
    }
  }

  void setVolumeUnit(VolumeUnit? unit) async {
    if (unit != null && volumeUnit.value != unit) {
      _saveUnit(volumeUnit, unit, _volumeKey, 'Volume');
    }
  }

  void setConsumptionUnit(ConsumptionUnit? unit) async {
    if (unit != null && consumptionUnit.value != unit) {
      _saveUnit(consumptionUnit, unit, _consumptionKey, 'Consumo');
    }
  }

  void setCurrencyUnit(CurrencyUnit? unit) {
    if (unit != null && currencyUnit.value != unit) {
      _saveUnit(currencyUnit, unit, _currencyKey, 'Moeda');
      currencyController.setCurrencySymbol(unit);
    }
  }
}
