



import 'package:dart_jts/dart_jts.dart' as jts;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'index.dart';


class PolygonBuilder {
  
  static Polygon getPolygonFromGeometry({
    required jts.Polygon geom,
    required PolygonConfig polygonConfig,
    required String polygonId,
  }) {
    return Polygon(
      polygonId: PolygonId(polygonId),
      geodesic: false,
      points: List<LatLng>.from(
          geom.getCoordinates().map((point) => LatLng(point.y, point.x))),
      holes: List<List<LatLng>>.from(geom.holes?.map(
              (hole) => List<LatLng>.from(hole
              .getCoordinates()
              .map((point) => LatLng(point.y, point.x)))) ??
          []),
      strokeWidth: polygonConfig.strokeWidth,
      strokeColor: polygonConfig.strokeColor,
      fillColor: polygonConfig.fillColor,
    );
  }

}