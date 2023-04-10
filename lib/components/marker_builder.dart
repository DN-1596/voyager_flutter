import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_jts/dart_jts.dart' as jts;

import 'index.dart';

class MarkerBuilder {
  static Future<Marker>? getMarkerFromGeometry({
    required jts.Point geom,
    required MarkerConfig markerConfig,
    required String markerId,
  }) async {

    if (geom.getCoordinate() == null) {
      throw "Coordinates are Null while getting Marker";
    }

    LatLng position =  LatLng(geom.getCoordinate()!.y, geom.getCoordinate()!.x);

    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: await markerConfig.icon.future,
      infoWindow: markerConfig.infoWindow,
    );
  }
}
