import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuel_tracker_app/controllers/gas_station_controller.dart';
import 'package:fuel_tracker_app/controllers/maintenance_controller.dart';
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
  final GasStationController gasStationController = Get.find<GasStationController>();
  final MaintenanceController maintenanceController = Get.find<MaintenanceController>();
  final VoiceNavigationService voiceService = VoiceNavigationService();

  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isRouting = false.obs;
  final RxBool isNavigationMode = false.obs;

  final MapController mapController = MapController();

  final Rx<LatLng?> destinationPoint = Rx<LatLng?>(null);
  final Rx<GasStationModel?> currentDestinationStation = Rx<GasStationModel?>(null);

  final RxDouble routeDistanceMeters = 0.0.obs;
  final RxDouble routeDurationSeconds = 0.0.obs;
  final RxDouble currentHeading = 0.0.obs;

  final RxList<Marker> stationMarkers = <Marker>[].obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxList<RouteStep> routeSteps = <RouteStep>[].obs;
  final RxInt nextManeuverIndex = 0.obs;

  final double offRouteToleranceMeters = 75.0;
  final double maneuverToleranceMeters = 30.0;

  StreamSubscription<Position>? _positionStreamSubscription;
  Worker? _stationsListener;

  @override
  void onInit() {
    super.onInit();
    _initializeVoiceService();
    determinePositionAndLoadMap();
    _setupControllerListeners();
  }

  void _setupControllerListeners() {
    _stationsListener = ever(gasStationController.stations, (List<GasStationModel> stations) {
      _updateStationMarkers(stations);
    });
  }

  void _updateStationMarkers(List<GasStationModel> stations) {
    final List<Marker> newMarkers = stations
        .map(
          (station) =>
              _createGasStationMarker(LatLng(station.latitude, station.longitude), station),
        )
        .toList();

    stationMarkers.value = newMarkers;
  }

  Marker _createGasStationMarker(LatLng point, GasStationModel station) {
    final isDestination =
        destinationPoint.value == point && currentDestinationStation.value?.nome == station.nome;

    final iconColor = isDestination
        ? Colors.red.shade700
        : AppTheme.primaryFuelColor.withOpacity(0.8);

    final iconSize = isDestination ? 45.0 : 35.0;

    return Marker(
      point: point,
      width: 100,
      height: 100,
      child: GestureDetector(
        onTap: () {
          if (currentLocation.value != null) {
            if (isDestination) {
              clearNavigation();
            } else {
              calculateRoute(currentLocation.value!, point, station);
              Get.snackbar('Rota', 'Calculando rota para ${station.nome}...');
            }
          } else {
            Get.snackbar('Erro', 'Localização indisponível. Recalcule sua posição.');
          }
        },
        child: Column(
          children: [
            Icon(RemixIcons.gas_station_fill, color: iconColor, size: iconSize),
            Flexible(
              child: Text(
                station.nome.split(' ').first,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDestination ? Colors.red.shade700 : AppTheme.primaryFuelColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeVoiceService() async {
    try {
      await voiceService.init();
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao iniciar serviço de voz: $e');
    }
  }

  Future<void> determinePositionAndLoadMap() async {
    isLoading.value = true;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentLocation.value = defaultCenter;
      isLoading.value = false;
      Get.snackbar('Atenção', Get.context!.tr(TranslationKeys.mapLocationServiceDisabled));
      await loadStationsFromDB();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        currentLocation.value = defaultCenter;
        isLoading.value = false;
        Get.snackbar('Atenção', Get.context!.tr(TranslationKeys.mapPermissionDenied));
        await loadStationsFromDB();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      currentLocation.value = defaultCenter;
      isLoading.value = false;
      Get.snackbar('Atenção', Get.context!.tr(TranslationKeys.mapPermissionDeniedForever));
      await loadStationsFromDB();
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final newLocation = LatLng(position.latitude, position.longitude);
    currentLocation.value = newLocation;
    isLoading.value = false;
    routePoints.clear();

    _moveMapToCurrentLocation(newLocation);
    await loadStationsFromDB();
    _startLocationTracking();
  }

  void _moveMapToCurrentLocation(LatLng newLocation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // mapController.move(newLocation, 15.0);
      // mapController.rotate(0);
    });
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
          final newLocation = LatLng(position.latitude, position.longitude);
          currentLocation.value = newLocation;
          currentHeading.value = position.heading;

          if (destinationPoint.value != null) {
            _checkManeuverProgress(newLocation);
            _checkIfOffRoute(newLocation);

            if (isNavigationMode.value) {
              _moveMapToNavigationMode(newLocation, currentHeading.value);
            }
          }
        });
  }

  void _moveMapToNavigationMode(LatLng newLocation, double heading) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const double navigationZoom = 17.0;

      mapController.moveAndRotate(newLocation, navigationZoom, -heading);
    });
  }

  void toggleNavigationMode() {
    isNavigationMode.toggle();

    if (isNavigationMode.value && currentLocation.value != null) {
      _moveMapToNavigationMode(currentLocation.value!, currentHeading.value);
      Get.snackbar('Sucesso', 'Modo Navegação ATIVADO');
    } else {
      _moveMapToCurrentLocation(currentLocation.value ?? defaultCenter);
      Get.snackbar('Erro', 'Modo Navegação DESATIVADO');
    }
  }

  void clearNavigation() {
    routePoints.clear();
    destinationPoint.value = null;
    currentDestinationStation.value = null;
    isNavigationMode.value = false;
    routeSteps.clear();
    nextManeuverIndex.value = 0;

    if (currentLocation.value != null) {
      _moveMapToCurrentLocation(currentLocation.value!);
    }
    Get.snackbar('Erro', 'Navegação cancelada.');
  }

  String formatDistance(double meters) {
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  String formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  String calculateETA(double durationSeconds) {
    if (durationSeconds <= 0) return 'Calculando...';
    final etaTime = DateTime.now().add(Duration(seconds: durationSeconds.round()));
    final hour = etaTime.hour.toString().padLeft(2, '0');
    final minute = etaTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> loadStationsFromDB({String? query}) async {
    if (query != null && query.isNotEmpty) {
      await gasStationController.searchStations(query);
    } else {
      await gasStationController.loadStations();
    }
  }

  static Map<String, dynamic> _parseRouteData(String responseBody) {
    return json.decode(responseBody);
  }

  Future<void> calculateRoute(LatLng start, LatLng end, GasStationModel station) async {
    if (isRouting.isTrue) return;

    isRouting.value = true;
    routePoints.clear();
    routeSteps.clear();
    nextManeuverIndex.value = 0;

    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson&steps=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = await compute(_parseRouteData, response.body);

        if (data['code'] == 'Ok' && data['routes'] != null) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final List<dynamic> coordinates = geometry['coordinates'];

          final double distanceMeters = route['distance']?.toDouble() ?? 0.0;
          final double durationSeconds = route['duration']?.toDouble() ?? 0.0;

          final List<LatLng> points = coordinates.map<LatLng>((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          final List<RouteStep> steps = [];
          final List<dynamic> legs = route['legs'] ?? [];
          if (legs.isNotEmpty) {
            for (final stepData in legs.first['steps'] ?? []) {
              final String instruction =
                  stepData['maneuver']['instruction'] ?? 'Continue em frente';
              final double distance = stepData['distance']?.toDouble() ?? 0.0;
              final List<dynamic> locationCoords = stepData['maneuver']['location'] ?? [0.0, 0.0];
              final LatLng location = LatLng(
                locationCoords[1].toDouble(),
                locationCoords[0].toDouble(),
              );

              steps.add(RouteStep(instruction, location, distance));
            }
          }

          routePoints.assignAll(points);
          destinationPoint.value = end;
          currentDestinationStation.value = station;
          routeDistanceMeters.value = distanceMeters;
          routeDurationSeconds.value = durationSeconds;
          routeSteps.assignAll(steps);
          nextManeuverIndex.value = 0;
          isNavigationMode.value = true;

          _updateStationMarkers(gasStationController.stations.toList());

          WidgetsBinding.instance.addPostFrameCallback((_) {
            mapController.fitCamera(
              CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(points),
                padding: const EdgeInsets.all(50),
              ),
            );
          });

          final destinationName = currentDestinationStation.value?.nome ?? 'seu destino';
          voiceService.speak('Início da rota. Navegação para $destinationName');
          await Future.delayed(const Duration(milliseconds: 1500));

          if (routeSteps.isNotEmpty) {
            nextManeuverIndex.value = 0;
            if (routeSteps.length > 1 && routeSteps.first.distanceToNext < 50.0) {
              nextManeuverIndex.value = 1;
            }
            _speakNextInstruction();
          }
        } else {
          Get.snackbar('Erro', 'Erro ao calcular a rota: ${data['message']}');
        }
      } else {
        Get.snackbar('Erro', 'Erro de comunicação com o serviço de roteamento.');
      }
    } catch (e) {
      if (kDebugMode) {
        Get.snackbar('Erro', 'Falha na requisição de rota: $e');
      }
    } finally {
      isRouting.value = false;
    }
  }

  void _checkManeuverProgress(LatLng userLocation) {
    if (routeSteps.isEmpty || nextManeuverIndex.value >= routeSteps.length) {
      if (destinationPoint.value != null) {
        final Distance distance = const Distance();
        final distToDest = distance.distance(userLocation, destinationPoint.value!);
        if (distToDest <= maneuverToleranceMeters * 2) {
          voiceService.speak('Você chegou ao seu destino.');
          clearNavigation();
        }
      }
      return;
    }

    final nextStep = routeSteps[nextManeuverIndex.value];
    final Distance distance = const Distance();

    final distToManeuver = distance.distance(userLocation, nextStep.location);

    if (distToManeuver <= maneuverToleranceMeters) {
      nextManeuverIndex.value++;
      _speakNextInstruction();
    }
  }

  void _speakNextInstruction() {
    if (nextManeuverIndex.value < routeSteps.length) {
      final nextStep = routeSteps[nextManeuverIndex.value];
      final distanceStr = formatDistance(
        nextStep.distanceToNext,
      ).replaceAll(' km', 'metros').replaceAll('.0', '');
      final instruction = 'Em $distanceStr, ${nextStep.instruction}';
      voiceService.speak(instruction);
    } else if (nextManeuverIndex.value == routeSteps.length) {
      voiceService.speak('Você chegou ao seu destino.');
    }
  }

  void _checkIfOffRoute(LatLng userLocation) {
    if (destinationPoint.value == null || routePoints.isEmpty || isRouting.isTrue) {
      return;
    }

    double closestDistance = double.infinity;
    final Distance distance = const Distance();

    for (final point in routePoints) {
      final distInMeters = distance.distance(userLocation, point);
      closestDistance = math.min(closestDistance, distInMeters);
    }

    if (closestDistance < offRouteToleranceMeters) {
      Get.snackbar('Atenção', 'Desvio de rota detectado. Recalculando...');
      voiceService.speak('Recalculando rota.');
      calculateRoute(userLocation, destinationPoint.value!, currentDestinationStation.value!);
    }
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    _stationsListener?.dispose();
    voiceService.dispose();
    super.onClose();
  }
}
