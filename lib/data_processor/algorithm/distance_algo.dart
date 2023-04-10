


import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_jts/dart_jts.dart' as jts;

class DistanceAlgo {
  /// distance between points
  static double getDistanceBetween2Points(LatLng p1 ,LatLng p2) {
    double distance;

    jts.Point _p1 = jts.Point(jts.Coordinate(p1.longitude, p1.latitude),jts.PrecisionModel(),0);
    jts.Point _p2 = jts.Point(jts.Coordinate(p2.longitude, p2.latitude),jts.PrecisionModel(),0);

    distance = jts.DistanceOp.distanceStatic(_p1, _p2);
    double _distance =((distance/180)*pi*6371000);
    return _distance;
  }
  /// distance between polygons

  /// area of polygon
}