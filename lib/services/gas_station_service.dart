import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';

class GasStationService {
  
  final List<GasStationModel> _stationsStore = [];
  final FuelDb _db = FuelDb();

  Future<List<GasStationModel>> searchStationsByName(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if(query.isEmpty){
      return _db.getStation();
    }
    final lowerQuery = query.toLowerCase();
    return _stationsStore
    .where((s) => s.nome.toLowerCase().contains(lowerQuery))
    .toList();
  }

}