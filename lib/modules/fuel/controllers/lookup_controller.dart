import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:fuel_tracker_app/data/models/services_type_model.dart';
import 'package:fuel_tracker_app/data/models/type_gas_model.dart';
import 'package:fuel_tracker_app/data/models/vehicle_model.dart';
import 'package:get/get.dart';

class LookupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final tipoDrop = <TypeGasModel>[].obs;
  final veiculosDrop = <VehicleModel>[].obs;
  final postosDrop = <GasStationModel>[].obs;
  final servicosDrop = <ServicesTypeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLookups();
  }

  void fetchLookups() {
    _firestore.collection('tipo_combustivel').snapshots().listen((snapshot) {
      tipoDrop.value = snapshot.docs
          .map((doc) => TypeGasModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
    _firestore.collection('veiculos').snapshots().listen((snapshot) {
      veiculosDrop.value = snapshot.docs
          .map((doc) => VehicleModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
    _firestore.collection('postos').snapshots().listen((snapshot) {
      postosDrop.value = snapshot.docs
          .map((doc) => GasStationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
    _firestore.collection('service_type').snapshots().listen((snapshot) {
      servicosDrop.value = snapshot.docs
          .map((doc) => ServicesTypeModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
}
