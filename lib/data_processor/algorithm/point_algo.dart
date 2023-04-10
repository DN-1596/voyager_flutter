


import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/data_processor/algorithm/distance_algo.dart';
import 'package:voyager_flutter/utils/geo_utils.dart';
import 'package:voyager_flutter/utils/math_util.dart';

class PointAlgo {


  static bool isPointOnPolyline(LatLng point, Polyline poly,LatLngBounds bounds) {

    return locationIndexOnEdgeOrPath(point,poly.points,bounds) >= 0;

  }

  static int locationIndexOnEdgeOrPath(
      LatLng point, List<LatLng> poly,LatLngBounds bounds) {
    bool closed = false;
    try {
      if (poly[0] == poly[poly.length-1]) closed = true;
    } catch (e) {}
    int size = poly.length;
    if (size == 0) {
      return -1;
    }

    double tolerance = DistanceAlgo.getDistanceBetween2Points(bounds.northeast, bounds.southwest)*(0.01) / GeoUtil.EARTH_RADIUS;
    num havTolerance = MathUtil.hav(tolerance);
    num lat3 = MathUtil.toRadians(point.latitude);
    num lng3 = MathUtil.toRadians(point.longitude);
    LatLng prev = poly[closed ? size - 1 : 0];
    num lat1 = MathUtil.toRadians(prev.latitude);
    num lng1 = MathUtil.toRadians(prev.longitude);
    int idx = 0;
    for (LatLng point2 in poly) {
      num lat2 = MathUtil.toRadians(point2.latitude);
      num lng2 = MathUtil.toRadians(point2.longitude);
      if (GeoUtil.isOnSegmentGC(lat1, lng1, lat2, lng2, lat3, lng3, havTolerance)) {
        return max(0, idx - 1);
      }
      lat1 = lat2;
      lng1 = lng2;
      idx++;
    }
    return -1;
  }

  static bool isPointInPolygons(LatLng point , Set<Polygon> polygons) {
    bool _isPointInPolygon = true;

    for (Polygon polygon in polygons) {
      _isPointInPolygon = _isPointInPolygon &&
          containsLocationAtLatLng(
              point.latitude, point.longitude, polygon.points, true);
    }

    return _isPointInPolygon;

  }

  /// Computes whether the given point lies inside the specified polygon.
  /// The polygon is always considered closed, regardless of whether the last
  /// point equals the first or not.
  /// Inside is defined as not containing the South Pole -- the South Pole is
  /// always outside. The polygon is formed of great circle segments if geodesic
  /// is true, and of rhumb (loxodromic) segments otherwise.
  static bool containsLocationAtLatLng(num latitude, num longitude, List<LatLng> polygon, bool geodesic) {
    if (polygon.isEmpty) {
      return false;
    }

    final lat3 = MathUtil.toRadians(latitude);
    final lng3 = MathUtil.toRadians(longitude);
    final prev = polygon.last;
    var lat1 = MathUtil.toRadians(prev.latitude);
    var lng1 = MathUtil.toRadians(prev.longitude);
    var nIntersect = 0;

    for (final point2 in polygon) {
      final dLng3 = MathUtil.wrap(lng3 - lng1, -pi, pi);
      // Special case: point equal to vertex is inside.
      if (lat3 == lat1 && dLng3 == 0) {
        return true;
      }
      final lat2 = MathUtil.toRadians(point2.latitude);
      final lng2 = MathUtil.toRadians(point2.longitude);
      // Offset longitudes by -lng1.
      if (GeoUtil.intersects(lat1, lat2, MathUtil.wrap(lng2 - lng1, -pi, pi), lat3, dLng3, geodesic)) {
        ++nIntersect;
      }
      lat1 = lat2;
      lng1 = lng2;
    }
    return (nIntersect & 1) != 0;
  }


  // Read : https://gis.stackexchange.com/questions/5821/calculating-latitude-longitude-x-miles-from-point
  // assuming bearing is in degrees
  static LatLng getLatLngFromAPoint(LatLng pt, int distance,double bearing) {
    bearing = bearing/180 * pi;
    num lat1Rad = MathUtil.toRadians(pt.latitude);
    num long1Rad = MathUtil.toRadians(pt.longitude);
    num d = distance/GeoUtil.EARTH_RADIUS;
    num lat2Rad = asin(sin(lat1Rad)*cos(d) + cos(lat1Rad)*sin(d)*cos(bearing));

    num long2Rad = long1Rad + atan2(sin(bearing) * sin(d)*cos(lat1Rad),
    cos(d)-sin(lat1Rad)*sin(lat2Rad));
    // normalise to -180..+180°
    long2Rad = (long2Rad + 3 * pi) % (2 * pi) - pi;

    return LatLng(
      MathUtil.toDegrees(lat2Rad).toDouble(),
      MathUtil.toDegrees(long2Rad).toDouble(),
    );
  }


}