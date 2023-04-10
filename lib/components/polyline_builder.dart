import 'dart:developer';

import 'package:dart_jts/dart_jts.dart' as jts;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'index.dart';

class PolylineBuilder {

  static Polyline getPolylineFromPoints({
    required List<jts.Point> points,
    required PolylineConfig polylineConfig,
    required String id,
  }) {
    List<jts.Coordinate> coordinates = [];

    for (jts.Point point in points) {
      jts.Coordinate? coordinate = point.getCoordinate();
      if (coordinate != null) {
        coordinates.add(coordinate);
      }
    }

    return _getPolylineFromCoordinates(
      coordinates: coordinates,
      polylineConfig: polylineConfig,
      id: id,
    );
  }

  static Polyline getPolylineFromLineString({
    required jts.LineString lineString,
    required PolylineConfig polylineConfig,
    required String id,
  }) {
    List<jts.Coordinate> coordinates = [];

    for (jts.Coordinate coordinate in lineString.getCoordinates()) {
      coordinates.add(coordinate);
    }

    return _getPolylineFromCoordinates(
      coordinates: coordinates,
      polylineConfig: polylineConfig,
      id: id,
    );
  }


    static Polyline _getPolylineFromCoordinates({
    required List<jts.Coordinate> coordinates,
    jts.LineString? lineString,
    required PolylineConfig polylineConfig,
    required String id,
  }) {
    List<LatLng> _points = [];
    for (jts.Coordinate point in coordinates) {
      try {
        LatLng latLng = LatLng(
          point.y,
          point.x,
        );

        _points.add(latLng);
      } catch (e) {
        log("ERROR!! UNABLE TO PARSE POINT : $e");
      }
    }

    return Polyline(
      polylineId: PolylineId(id),
      points: _points,
      color: polylineConfig.color,
      width: polylineConfig.width,
      patterns: polylineConfig.patterns,
    );
  }
}
