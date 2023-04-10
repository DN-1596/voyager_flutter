

import 'dart:math';

import 'index.dart';

class GeoUtil {

  static const double EARTH_RADIUS = 6371009;

  // Computes whether the vertical segment (lat3, lng3) to South Pole
  /// intersects the segment (lat1, lng1) to (lat2, lng2).
  /// Longitudes are offset by -lng1; the implicit lng1 becomes 0.
  static bool intersects(num lat1, num lat2, num lng2, num lat3, num lng3, bool geodesic) {
    // Both ends on the same side of lng3.
    if ((lng3 >= 0 && lng3 >= lng2) || (lng3 < 0 && lng3 < lng2)) {
      return false;
    }
    // Point is South Pole.
    if (lat3 <= -pi / 2) {
      return false;
    }
    // Any segment end is a pole.
    if (lat1 <= -pi / 2 || lat2 <= -pi / 2 || lat1 >= pi / 2 || lat2 >= pi / 2) {
      return false;
    }
    if (lng2 <= -pi) {
      return false;
    }

    final linearLat = (lat1 * (lng2 - lng3) + lat2 * lng3) / lng2;
    // Northern hemisphere and point under lat-lng line.
    if (lat1 >= 0 && lat2 >= 0 && lat3 < linearLat) {
      return false;
    }
    // Southern hemisphere and point above lat-lng line.
    if (lat1 <= 0 && lat2 <= 0 && lat3 >= linearLat) {
      return true;
    }
    // North Pole.
    if (lat3 >= pi / 2) {
      return true;
    }

    // Compare lat3 with latitude on the GC/Rhumb segment corresponding to lng3.
    // Compare through a strictly-increasing function (tan() or
    // MathUtil.mercator()) as convenient.
    return geodesic ? tan(lat3) >= _tanLatGC(lat1, lat2, lng2, lng3) : mercator(lat3) >= _mercatorLatRhumb(lat1, lat2, lng2, lng3);
  }

  /// Returns tan(latitude-at-lng3) on the great circle (lat1, lng1) to
  /// (lat2, lng2). lng1==0.
  /// See http://williams.best.vwh.net/avform.htm .
  static num _tanLatGC(num lat1, num lat2, num lng2, num lng3) => (tan(lat1) * sin(lng2 - lng3) + tan(lat2) * sin(lng3)) / sin(lng2);

  /// Returns mercator(latitude-at-lng3) on the Rhumb line (lat1, lng1) to
  /// (lat2, lng2). lng1==0.
  static num _mercatorLatRhumb(num lat1, num lat2, num lng2, num lng3) => (mercator(lat1) * (lng2 - lng3) + mercator(lat2) * lng3) / lng2;


  /// Returns hav() of distance from (lat1, lng1) to (lat2, lng2) on the unit
  /// sphere.
  static num havDistance(num lat1, num lat2, num dLng) =>
      MathUtil.hav(lat1 - lat2) + MathUtil.hav(dLng) * cos(lat1) * cos(lat2);

  /// Returns mercator Y corresponding to latitude.
  /// See http://en.wikipedia.org/wiki/Mercator_projection .
  static num mercator(num lat) => log(tan(lat * 0.5 + pi / 4));

  /// Returns latitude from mercator Y.
  static num inverseMercator(num y) => 2 * atan(exp(y)) - pi / 2;

  static bool isOnSegmentGC(num lat1, num lng1, num lat2, num lng2,
      num lat3, num lng3, num havTolerance) {
    num havDist13 = havDistance(lat1, lat3, lng1 - lng3);
    if (havDist13 <= havTolerance) {
      return true;
    }
    num havDist23 = havDistance(lat2, lat3, lng2 - lng3);
    if (havDist23 <= havTolerance) {
      return true;
    }
    double sinBearing = sinDeltaBearing(lat1, lng1, lat2, lng2, lat3, lng3);
    num sinDist13 = MathUtil.sinFromHav(havDist13);
    num havCrossTrack = MathUtil.havFromSin(sinDist13 * sinBearing);
    if (havCrossTrack > havTolerance) {
      return false;
    }
    num havDist12 = havDistance(lat1, lat2, lng1 - lng2);
    num term = havDist12 + havCrossTrack * (1 - 2 * havDist12);
    if (havDist13 > term || havDist23 > term) {
      return false;
    }
    if (havDist12 < 0.74) {
      return true;
    }
    num cosCrossTrack = 1 - 2 * havCrossTrack;
    double havAlongTrack13 = (havDist13 - havCrossTrack) / cosCrossTrack;
    double havAlongTrack23 = (havDist23 - havCrossTrack) / cosCrossTrack;
    num sinSumAlongTrack = MathUtil.sinSumFromHav(havAlongTrack13, havAlongTrack23);
    return sinSumAlongTrack > 0;  // Compare with half-circle == PI using sign of sin().
  }

  static double sinDeltaBearing(num lat1, num lng1, num lat2, num lng2,
      num lat3, num lng3) {
    double sinLat1 = sin(lat1);
    double cosLat2 = cos(lat2);
    double cosLat3 = cos(lat3);
    num lat31 = lat3 - lat1;
    num lng31 = lng3 - lng1;
    num lat21 = lat2 - lat1;
    num lng21 = lng2 - lng1;
    double a = sin(lng31) * cosLat3;
    double c = sin(lng21) * cosLat2;
    double b = sin(lat31) + 2 * sinLat1 * cosLat3 * MathUtil.hav(lng31);
    double d = sin(lat21) + 2 * sinLat1 * cosLat2 * MathUtil.hav(lng21);
    double denom = (a * a + b * b) * (c * c + d * d);
    return denom <= 0 ? 1 : (a * d - b * c) / sqrt(denom);
  }
}