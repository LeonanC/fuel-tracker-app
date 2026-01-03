import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/data/fuel_db.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/route_step_model.dart';
import 'package:fuel_tracker_app/services/voice_navigation_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

const LatLng defaultCenter = LatLng(-23.55052, -46.63330);

class MapNavigationController extends GetxController {
  final FuelDb _db = FuelDb();
  final MapController mapController = MapController();

  var currentLocation = Rxn<LatLng>();
  var currentHeading = 0.0.obs;
  var isLoading = true.obs;

  var destinationPoint = Rxn<LatLng>();
  var routePoints = <LatLng>[].obs;
  var isRouting = false.obs;
  var isNavigationMode = false.obs;

  var currentDestinationStation = Rxn<GasStationModel>();
  var routeDistanceMeters = 0.0.obs;
  var routeDurationSeconds = 0.0.obs;

  var stationMarkers = <Marker>[].obs;

  StreamSubscription<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    determinePositionAndLoadMap();
    _startLocationTracking();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    super.onClose();
  }

  Future<void> determinePositionAndLoadMap() async {
    try {
      isLoading.value = true;
      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);

      mapController.move(currentLocation.value!, 15.0);

      await loadStationsFromDB();
    } catch (e) {
      Get.snackbar("Erro", "Não foi possível obter sua localização.");
    } finally {
      isLoading.value = false;
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((
      Position position,
    ) {
      currentLocation.value = LatLng(position.latitude, position.longitude);
      currentHeading.value = position.heading;

      if (isNavigationMode.value) {
        mapController.move(currentLocation.value!, mapController.camera.zoom);
        mapController.rotate(360 - position.heading);
      }
    });
  }

  Future<void> loadStationsFromDB({String? query}) async {
    List<GasStationModel> stations = await _db.getStations(query: query);
    stationMarkers.value = stations.map((station) {
      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _setupNavigation(station),
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    }).toList();
  }

  Future<void> _setupNavigation(GasStationModel station) async {
    currentDestinationStation.value = station;
    destinationPoint.value = LatLng(station.latitude, station.longitude);
    await fetchRoute();
    _fitBounds();
  }

  Future<void> fetchRoute() async {
    if (currentLocation.value == null || destinationPoint.value == null) return;

    try {
      isRouting.value = true;
      final start = currentLocation.value!;
      final end = destinationPoint.value!;

      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
          '?overview=full&geometries=polyline&steps=true';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = await json.decode(response.body);
        final route = data['routes'][0];

        routeDistanceMeters.value = route['distance'].toDouble();
        routeDurationSeconds.value = route['duration'].toDouble();

        

        routePoints.value = _decodePolyline(route['geomatry']);

        print(routePoints.value);
      }
    } catch (e) {
      Get.snackbar('Erro de Rota', 'Não foi possível calcular o caminho.');
    } finally {
      isRouting.value = false;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void toggleNavigationMode() {
    isNavigationMode.value = !isNavigationMode.value;

    if (isNavigationMode.value) {
      mapController.move(currentLocation.value!, 18.0);
      ;
    } else {
      mapController.rotate(0);
    }
  }

  void clearNavigation() {
    destinationPoint.value = null;
    routePoints.clear();
    currentDestinationStation.value = null;
    isNavigationMode.value = false;
  }

  void _fitBounds() {
    if (routePoints.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(routePoints);
    mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  String formatDistance(double meters) {
    if (meters < 1000) return "${meters.toStringAsFixed(0)} m";
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String calculateETA(double seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return '${hours}h ${remainingMinutes}m';
  }
}
