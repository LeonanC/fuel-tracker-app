import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/services/application.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitProvider with ChangeNotifier {
  static const String _distanceKey = 'pref_distance_unit';
  static const String _volumeKey = 'pref_volume_unit';
  static const String _consumptionKey = 'pref_consumption_unit';

  DistanceUnit _distanceUnit = DistanceUnit.kilometers;
  VolumeUnit _volumeUnit = VolumeUnit.liters;
  ConsumptionUnit _consumptionUnit = ConsumptionUnit.kmPerLiter;

  DistanceUnit get distanceUnit => _distanceUnit;
  VolumeUnit get volumeUnit => _volumeUnit;
  ConsumptionUnit get consumptionUnit => _consumptionUnit;

  UnitProvider(){
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final prefs = await SharedPreferences.getInstance();
    
    final distanceIndex = prefs.getInt(_distanceKey) ?? DistanceUnit.kilometers.index;
    _distanceUnit = DistanceUnit.values[distanceIndex];

    final volumeIndex = prefs.getInt(_volumeKey) ?? VolumeUnit.liters.index;
    _volumeUnit = VolumeUnit.values[volumeIndex];

    final consumptionIndex = prefs.getInt(_consumptionKey) ?? ConsumptionUnit.kmPerLiter.index;
    _consumptionUnit = ConsumptionUnit.values[consumptionIndex];

    notifyListeners();
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    if(_distanceUnit != unit){
      _distanceUnit = unit;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_distanceKey, unit.index);
      notifyListeners();
    }
  }

  Future<void> setVolumeUnit(VolumeUnit unit) async {
    if(_volumeUnit != unit){
      _volumeUnit = unit;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_volumeKey, unit.index);
      notifyListeners();
    }
  }

  Future<void> setConsumptionUnit(ConsumptionUnit unit) async {
    if(_consumptionUnit != unit){
      _consumptionUnit = unit;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_consumptionKey, unit.index);
      notifyListeners();
    }
  }
}