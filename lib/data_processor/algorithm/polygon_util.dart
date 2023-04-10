


import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/voyager_flutter.dart';

import 'point_algo.dart';


class PolygonUtil {

  static List<LatLng> getBoxAroundAPoint(LatLng point,LatLngBounds bounds) {
    int distance = (DistanceAlgo.getDistanceBetween2Points(
                bounds.northeast, bounds.southwest) *
            0.10)
        .floor();

    LatLng north = PointAlgo.getLatLngFromAPoint(point, distance, 0);
    LatLng east = PointAlgo.getLatLngFromAPoint(point, distance, 90);
    LatLng south = PointAlgo.getLatLngFromAPoint(point, distance, 180);
    LatLng west = PointAlgo.getLatLngFromAPoint(point, distance, 270);

    return [north,east,south,west,north];

  }


}