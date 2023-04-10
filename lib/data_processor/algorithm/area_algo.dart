


import 'dart:math';

import 'package:voyager_flutter/voyager_flutter.dart';

class AreaAlgo {
  static num WGS84_RADIUS = 6378137;

  /// in Acres
  static num polygonArea(List<LatLng> points, {List<List<LatLng>> holes = const []}) {

    num _area = 0;

    if (points.isNotEmpty) {
      _area += ringArea(points).abs();
      for (var hole in holes) {
        _area -= ringArea(hole).abs();
      }
    }

    return _area * 0.000247105;
  }

  /// convert degrees to radians
  static num rad(num value) => value * pi / 180;

  /// Calculate the approximate _area of the polygon were it projected onto
  ///     the earth.  Note that this _area will be positive if ring is oriented
  ///     clockwise, otherwise it will be negative.
  ///
  /// Reference:
  ///     Robert. G. Chamberlain and William H. Duquette, "Some Algorithms for
  ///     Polygons on a Sphere", JPL Publication 07-03, Jet Propulsion
  ///     Laboratory, Pasadena, CA, June 2007 http://trs-new.jpl.nasa.gov/dspace/handle/2014/40409
  ///
  /// Returns:
  ///
  /// {num} The approximate signed geodesic _area of the polygon in square meters.
  static num ringArea(List<LatLng> coordinates) {

    num _area = 0;

    if (coordinates.length > 2) {
      for (int i = 0; i < coordinates.length; i++) {
        var lowerIndex = i;
        var middleIndex = i + 1;
        var upperIndex = i + 2;

        if (i == coordinates.length - 2) {
          lowerIndex = coordinates.length - 2;
          middleIndex = coordinates.length - 1;
          upperIndex = 0;
        } else if (i == coordinates.length - 1) {
          lowerIndex = coordinates.length - 1;
          middleIndex = 0;
          upperIndex = 1;
        }

        var p1 = coordinates[lowerIndex];
        var p2 = coordinates[middleIndex];
        var p3 = coordinates[upperIndex];

        _area += (rad(p3.longitude) - rad(p1.longitude)) * sin(rad(p2.latitude));
      }

      _area = _area * WGS84_RADIUS * WGS84_RADIUS / 2;
    }

    return _area;
  }

}