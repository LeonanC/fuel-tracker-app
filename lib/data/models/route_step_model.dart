import 'package:latlong2/latlong.dart';

class RouteStep {
  final String instruction;
  final LatLng location;
  final double distanceToNext;

  RouteStep(this.instruction, this.location, this.distanceToNext);
}