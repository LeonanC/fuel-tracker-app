import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fuel_tracker_app/models/gas_station_model.dart';
import 'package:fuel_tracker_app/models/route_step_model.dart';
import 'package:fuel_tracker_app/provider/gas_station_provider.dart';
import 'package:fuel_tracker_app/services/voice_navigation_service.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';

const LatLng defaultCenter = LatLng(-23.55052, -46.63330);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _isRouting = false;
  bool _isNavigationMode = false;
  final MapController _mapController = MapController();

  LatLng? _destinationPoint;

  double _routeDistanceKm = 0.0;
  double _routeDurationMinutes = 0.0;
  double _currentHeading = 0.0;

  List<Marker> _stationMarkers = [];
  List<LatLng> _routePoints = [];

  List<RouteStep> _routeSteps = [];
  int _nextManeuverIndex = 0;
  final VoiceNavigationService _voiceService = VoiceNavigationService();

  GasStationModel? _currentDestinationStation;

  final GasStationProvider _dbProvider = GasStationProvider();

  StreamSubscription<Position>? _positionStreamSubscription;

  double _offRouteToleranceMeters = 50.0;
  double _maneuverToleranceMeters = 30.0;

  @override
  void initState() {
    super.initState();
    _determinePositionAndLoadMap();
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
          if (mounted) {
            final newLocation = LatLng(position.latitude, position.longitude);
            setState(() {
              _currentLocation = newLocation;
              _currentHeading = position.heading;
            });

            if (_destinationPoint != null) {
              _checkManeuverProgress(newLocation);
              _checkIfOffRoute(newLocation);

              if (_isNavigationMode) {
                _moveMapToNavigationMode(newLocation, _currentHeading);
              }
            } else {
              _moveMapToCurrentLocation(newLocation);
              _checkIfOffRoute(newLocation);
            }
          }
        });
  }

  void _moveMapToNavigationMode(LatLng newLocation, double heading) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        const double navigationZoom = 17.0;

        _mapController.moveAndRotate(newLocation, navigationZoom, -heading);
      });
    }
  }

  String _formatDistance(double meters) {
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}min';
    }
  }

  void _clearNavigation() {
    setState(() {
      _routePoints = [];
      _destinationPoint = null;
      _isNavigationMode = false;
    });

    if (_currentLocation != null) {
      _moveMapToCurrentLocation(_currentLocation!);
    }
    _showSnackbar('Navegação cancelada.');
  }

  String _calculateETA(double durationSeconds) {
    if (durationSeconds <= 0) return 'Calculando...';
    final etaTime = DateTime.now().add(Duration(seconds: durationSeconds.round()));
    final hour = etaTime.hour.toString().padLeft(2, '0');
    final minute = etaTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _loadStationsFromDB({String? query}) async {
    List<GasStationModel> stations;
    if (query != null && query.isNotEmpty) {
      stations = await _dbProvider.searchGasStationsByName(query);
    } else {
      stations = await _dbProvider.getAllGasStation();
    }

    final List<Marker> newMarkers = stations
        .map(
          (station) =>
              _createGasStationMarker(LatLng(station.latitude, station.longitude), station),
        )
        .toList();

    if (mounted) {
      setState(() {
        _stationMarkers = newMarkers;
        if (stations.isNotEmpty && query != null) {
          _mapController.move(LatLng(stations.first.latitude, stations.first.longitude), 14.0);
        }
      });
    }
  }

  Future<void> _determinePositionAndLoadMap() async {
    await _initializeVoiceService();

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentLocation = defaultCenter;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr(TranslationKeys.mapLocationServiceDisabled))),
        );
        await _loadStationsFromDB();
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentLocation = defaultCenter;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.tr(TranslationKeys.mapPermissionDenied))));

          await _loadStationsFromDB();
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentLocation = defaultCenter;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr(TranslationKeys.mapPermissionDeniedForever))),
        );

        await _loadStationsFromDB();
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = newLocation;
        _isLoading = false;
        _routePoints = [];
      });
      _moveMapToCurrentLocation(newLocation);
      await _loadStationsFromDB();
      _startLocationTracking();
    }
  }

  void _moveMapToCurrentLocation(LatLng newLocation) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(newLocation, 15.0);
        _mapController.rotate(0);
      });
    }
  }

  void _toggleNavigationMode() {
    setState(() {
      _isNavigationMode = !_isNavigationMode;
    });

    if (_isNavigationMode && _currentLocation != null) {
      _moveMapToNavigationMode(_currentLocation!, _currentHeading);
      _showSnackbar('Modo Navegação ATIVADO');
    } else {
      _moveMapToCurrentLocation(_currentLocation ?? defaultCenter);
      _showSnackbar('Modo Navegação DESATIVADO');
    }
  }

  Future<void> _calculateRoute(LatLng start, LatLng end, GasStationModel station) async {
    if (_isRouting) return;

    setState(() {
      _isRouting = true;
      _routePoints = [];
      _routeSteps = [];
      _nextManeuverIndex = 0;
    });

    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

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

          if (mounted) {
            setState(() {
              _routePoints = points;
              _isRouting = false;
              _destinationPoint = end;
              _currentDestinationStation = station;
              _routeDistanceKm = distanceMeters;
              _routeDurationMinutes = durationSeconds;
              _routeSteps = steps;
              _nextManeuverIndex = 0;
              _isNavigationMode = true;
            });
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(points),
                padding: const EdgeInsets.all(50),
              ),
            );

            final destinationName = _currentDestinationStation?.name ?? 'seu destino';
            _voiceService.speak('Início da rota. Navegação para $destinationName');
            await Future.delayed(const Duration(milliseconds: 1500));

            if(_routeSteps.isNotEmpty){
              if(_routeSteps.first.distanceToNext < 15.0 && _routeSteps.length > 1){
                _nextManeuverIndex = 1;
              }else {
                _nextManeuverIndex = 0;
              }
              _speakNextInstruction();
            }
          }
        } else {
          _showSnackbar('Erro ao calcular a rota: ${data['message']}');
        }
      } else {
        _showSnackbar('Erro de comunicação com o serviço de roteamento.');
      }
    } catch (e) {
      _showSnackbar('Falha na requisição de rota: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRouting = false;
        });
      }
    }
  }

  void _checkManeuverProgress(LatLng userLocation) {
    if (_routeSteps.isEmpty || _nextManeuverIndex >= _routeSteps.length) {
      return;
    }

    final nextStep = _routeSteps[_nextManeuverIndex];
    final Distance distance = const Distance();

    final distToManeuver = distance.distance(userLocation, nextStep.location);

    if (distToManeuver <= _maneuverToleranceMeters) {
      _nextManeuverIndex++;
      _speakNextInstruction();
    }
  }

  void _speakNextInstruction() {
    if (_nextManeuverIndex < _routeSteps.length) {
      final nextStep = _routeSteps[_nextManeuverIndex];
      final instruction = 'Em ${nextStep.distanceToNext.round()} metros, ${nextStep.instruction}';
      _voiceService.speak(instruction);
    } else if (_nextManeuverIndex == _routeSteps.length) {
      _voiceService.speak('Você chegou ao seu destino.');
    }
  }

  void _checkIfOffRoute(LatLng userLocation) {
    if (_destinationPoint == null || _routePoints.isEmpty || _isRouting) {
      return;
    }

    double closestDistance = double.infinity;
    final Distance distance = const Distance();

    for (final point in _routePoints) {
      final distInMeters = distance.distance(userLocation, point);
      closestDistance = math.min(closestDistance, distInMeters);
    }

    if (closestDistance < _offRouteToleranceMeters) {
      _showSnackbar('Desvio de rota detectado. Recalculando...');
      _calculateRoute(userLocation, _destinationPoint!, _currentDestinationStation!);
    }
  }

  Future<void> _initializeVoiceService() async {
    try{
      await _voiceService.init();
    }catch(e){
      print('Erro ao iniciar serviço de voz: $e');
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Marker _createGasStationMarker(LatLng point, GasStationModel station) {
    final isDestination =
        _destinationPoint == point && _currentDestinationStation?.name == station.name;

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
          if (_currentLocation != null) {
            if (isDestination) {
              _clearNavigation();
            } else {
              _calculateRoute(_currentLocation!, point, station);
              _showSnackbar('Calculando rota para ${station.name}...');
            }
          } else {
            _showSnackbar('Localização indisponível. Recalcule sua posição.');
          }
        },
        child: Column(
          children: [
            Icon(RemixIcons.gas_station_fill, color: iconColor, size: iconSize),
            Flexible(
              child: Text(
                station.name.split(' ').first,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final center = _currentLocation ?? defaultCenter;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
        title: Text(
          _destinationPoint != null ? 'Em Navegação' : context.tr(TranslationKeys.navigationMap),
        ),
        elevation: theme.appBarTheme.elevation,
        centerTitle: theme.appBarTheme.centerTitle,
        actions: [
          if (_destinationPoint == null)
            IconButton(
              icon: const Icon(RemixIcons.user_location_line, color: Colors.white),
              onPressed: () {
                setState(() => _isLoading = true);
                _determinePositionAndLoadMap();
              },
            ),
          if (_destinationPoint == null)
            IconButton(
              icon: const Icon(RemixIcons.search_line, color: Colors.white),
              onPressed: () async {
                final String? result = await showSearch<String>(
                  context: context,
                  delegate: _FuelSearchDelegate(context),
                );
                if (result != null && result.isNotEmpty) {
                  _loadStationsFromDB(query: result);
                }
              },
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_destinationPoint != null)
            FloatingActionButton(
              heroTag: 'nav_mode_toggle',
              onPressed: _toggleNavigationMode,
              backgroundColor: _isNavigationMode ? Colors.blueAccent : AppTheme.primaryFuelColor,
              child: Icon(
                _isNavigationMode ? RemixIcons.compass_fill : RemixIcons.compass_line,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 10),
          if (_destinationPoint != null)
            FloatingActionButton.extended(
              heroTag: 'gas_station_cancel_tag',
              onPressed: _clearNavigation,
              label: const Text('Cancelar Navegação'),
              icon: const Icon(RemixIcons.close_line),
              backgroundColor: Colors.red.shade700,
            ),
        ],
      ),

      body: _isLoading || _isRouting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryFuelColor),
                  const SizedBox(height: 10),
                  Text(
                    _isRouting
                        ? 'Calculando Rota...'
                        : context.tr(TranslationKeys.mapLoadingLocation),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15.0,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'br.com.fuel_tracker_app',
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 7.0,
                            color: Colors.blue.shade700,
                            useStrokeWidthInMeter: false,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: Transform.rotate(
                              angle: _currentHeading * (math.pi / 180),
                              child: Icon(
                                RemixIcons.car_fill,
                                color: AppTheme.primaryFuelColor,
                                size: 40,
                              ),
                            ),
                          ),
                        ..._stationMarkers,
                      ],
                    ),
                  ],
                ),

                if (_destinationPoint != null &&
                    _routeDistanceKm > 0 &&
                    _currentDestinationStation != null)
                  Positioned(
                    bottom: 100,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black54, blurRadius: 8, spreadRadius: 1),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentDestinationStation!.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoTile(
                                icon: RemixIcons.road_map_line,
                                label: 'Distância',
                                value: _formatDistance(_routeDistanceKm),
                              ),
                              _buildInfoTile(
                                icon: RemixIcons.timer_line,
                                label: 'Chegada',
                                value: _calculateETA(_routeDurationMinutes),
                              ),
                              _buildInfoTile(
                                icon: RemixIcons.gas_station_fill,
                                label: 'Preço (Gas.)',
                                value:
                                    'R\$ ${_currentDestinationStation!.priceGasoline.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildServiceIcon(
                                RemixIcons.store_2_fill,
                                'Loja',
                                _currentDestinationStation!.hasConvenientStore,
                              ),
                              _buildServiceIcon(
                                RemixIcons.time_fill,
                                '24H',
                                _currentDestinationStation!.is24Hours,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String label, bool available) {
    return Column(
      children: [
        Icon(icon, color: available ? Colors.greenAccent : Colors.grey.shade600, size: 24),
        Text(
          label,
          style: TextStyle(color: available ? Colors.white : Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryFuelColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _FuelSearchDelegate extends SearchDelegate<String> {
  final BuildContext _context;
  _FuelSearchDelegate(this._context)
    : super(searchFieldLabel: _context.tr(TranslationKeys.mapSearchAction));

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> commonQueries = [
      _context.tr(TranslationKeys.mapSearchAction),
      'Posto Shell',
      'Posto Ipiranga',
      'Posto mais barato',
    ];
    final filteredResults = commonQueries
        .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Container(
      color: AppTheme.primaryDark,
      child: ListView.builder(
        itemCount: filteredResults.length,
        itemBuilder: (context, index) {
          final suggestion = filteredResults[index];
          return ListTile(
            title: Text(suggestion, style: TextStyle(color: Colors.white)),
            leading: Icon(RemixIcons.gas_station_line, color: AppTheme.primaryFuelColor),
            onTap: () {
              close(context, suggestion);
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Pesquisando por "$query"...', style: TextStyle(color: Colors.white70)),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(RemixIcons.arrow_left_line),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(RemixIcons.close_line),
        onPressed: () {
          query = '';
        },
      ),
      IconButton(
        icon: const Icon(RemixIcons.search_line),
        onPressed: () {
          close(context, query);
        },
      ),
    ];
  }
}
