import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/vehicle_model.dart';
import 'package:uuid/uuid.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [
    Vehicle(
      id: const Uuid().v4(),
      nickname: 'Carro Principal',
      make: 'Fiat',
      model: 'Uno',
      fuelType: 'Flex',
      year: 2020,
      initialOdometer: 15000,
      imageUrl: null,
    ),
  ];

  List<Vehicle> get vehicles => _vehicles;

  void saveVehicle(Vehicle vehicle) {
    int index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if(index != -1){
      _vehicles[index] = vehicle;
    }else{
      _vehicles.add(vehicle);
    }
    notifyListeners();
  }

  void deleteVehicle(String id){
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }
}