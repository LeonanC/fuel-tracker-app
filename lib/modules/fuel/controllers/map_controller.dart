import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fuel_tracker_app/data/models/gas_station_model.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

const LatLng defaultCenter = LatLng(-23.55052, -46.63330);

class MapNavigationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MapController mapController = MapController();
  final FlutterTts _tts = FlutterTts();

  var currentLocation = Rxn<LatLng>();
  var currentHeading = 0.0.obs;
  var isLoading = true.obs;
  var isRouting = false.obs;
  var routePoints = <LatLng>[].obs;
  var routeSteps = <dynamic>[].obs;
  var destinationPoint = Rxn<LatLng>();
  var currentDestinationStation = Rxn<GasStationModel>();
  var stationMarkers = <Marker>[].obs;
  var isNavigationMode = false.obs;
  var isCompassMode = false.obs;

  var routeDistanceMeters = 0.0.obs;
  var routeDurationSeconds = 0.0.obs;
  int _lastStepIndex = -1;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<QuerySnapshot>? _stationsSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupVoice();
    initMap();
    _listenToPostos();
  }

  void _listenToPostos() {
    _stationsSubscription = _firestore.collection('postos').snapshots().listen((
      snapshot,
    ) {
      final markers = snapshot.docs.map((doc) {
        final data = doc.data();
        final station = GasStationModel.fromFirestore(data, doc.id);
        return Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => setupNavigation(station),
            child: Icon(
              RemixIcons.gas_station_line,
              color: Colors.orange[700],
              size: 35,
            ),
          ),
        );
      }).toList();
      stationMarkers.assignAll(markers);
    });
  }

  Future<void> _setupVoice() async {
    await _tts.setLanguage("pt-BR");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.stop();
      await _tts.speak(text);
    }
  }

  Future<void> initMap() async {
    await determinePosition();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _stationsSubscription?.cancel();
    super.onClose();
  }

  void toggleCompassMode() {
    isCompassMode.value = !isCompassMode.value;
    if (!isCompassMode.value) mapController.rotate(0);
  }

  Future<void> determinePosition() async {
    try {
      isLoading.value = true;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);
      mapController.move(currentLocation.value!, 15.0);
      _startLocationTracking();
    } catch (e) {
      Get.snackbar("Erro", "Falha ao obter sua localização.");
    } finally {
      isLoading.value = false;
    }
  }

  void _startLocationTracking() {
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      intervalDuration: const Duration(milliseconds: 500),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "Fuel Tracker está rastreando sua rota",
        notificationTitle: "Navegação Ativa",
      ),
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            LatLng pos = LatLng(position.latitude, position.longitude);
            currentLocation.value = pos;
            currentHeading.value = position.heading;

            if (routePoints.isNotEmpty) {
              _checkNavigationSteps(pos);
            }

            if (isNavigationMode.value || isCompassMode.value) {
              mapController.move(pos, mapController.camera.zoom);
              mapController.rotate(360 - position.heading);
            }
          },
        );
  }

  Future<void> setupNavigation(GasStationModel station) async {
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
        final data = json.decode(response.body);
        final route = data['routes'][0];

        routeDistanceMeters.value = route['distance'].toDouble();
        routeDurationSeconds.value = route['duration'].toDouble();

        routeSteps.assignAll(route['legs'][0]['steps']);
        _lastStepIndex = -1;

        routePoints.assignAll(_decodePolyline(route['geometry']));

        speak("Rota iniciada.");
      }
    } catch (e) {
      speak('Erro ao calcular rota');
    } finally {
      isRouting.value = false;
    }
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
    speak("Navegação cancelada.");
    routePoints.clear();
    destinationPoint.value = null;
    currentDestinationStation.value = null;
    isNavigationMode.value = false;
    mapController.rotate(0);
  }

  void _fitBounds() {
    if (routePoints.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(routePoints);
    mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(70)),
    );
  }

  void _checkNavigationSteps(LatLng currentPos) {
    if (routeSteps.isEmpty) return;

    for (int i = 0; i < routeSteps.length; i++) {
      final step = routeSteps[i];
      final stepLocation = step['maneuver']['location'];
      final stepLatLng = LatLng(stepLocation[1], stepLocation[0]);

      double distanteToStep = Geolocator.distanceBetween(
        currentPos.latitude,
        currentPos.longitude,
        stepLatLng.latitude,
        stepLatLng.longitude,
      );

      String instruction = _translateInstruction(step);

      if (distanteToStep < 300 && distanteToStep > 250 && _lastStepIndex != i) {
        _lastStepIndex = i;
        speak("Em trezentos metros, $instruction");
      } else if (distanteToStep < 60 &&
          distanteToStep > 20 &&
          _lastStepIndex == i) {
        _lastStepIndex = -2;
        speak("Agora, $instruction");
      }
    }
  }

  String _translateInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'];
    String type = maneuver['type'];
    String modifier = maneuver['modifier'] ?? "";
    String streetName = step['name'] ?? "";

    String streetInfo =
        (streetName.isNotEmpty &&
            streetName != "null" &&
            streetName != "unnamed road")
        ? " na rua $streetName"
        : "";

    switch (type) {
      case 'turn':
        String direction = "vire ";
        if (modifier.contains('left'))
          direction += "à esquerda";
        else if (modifier.contains('left'))
          direction += "à direita";
        else if (modifier.contains('sharp left'))
          direction += "vire acentuadamente à esquerda";
        else if (modifier.contains('sharp right'))
          direction += "vire acentuadamente à direita";
        else
          direction += "na direção indicada";
        return "$direction$streetInfo";
      case 'new name':
        return "continue em frente para entrar $streetInfo";
      case 'on ramp':
        return "pegue a rampa de acesso $streetInfo";
      case 'roundabout':
        int? exit = maneuver['exit'];
        String exitText = exit != null ? " e pegue a saída número $exit" : "";
        return "entre na rotatória$exitText$streetInfo";
      case 'arrive':
        return "você chegou ao seu destino$streetInfo";
      case 'depart':
        return "siga em direção a$streetName";

      default:
        return "siga em frente na $streetName";
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
