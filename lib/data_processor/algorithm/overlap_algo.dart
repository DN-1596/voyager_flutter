


import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_jts/dart_jts.dart' as jts;

import 'poly_bool/index.dart';

class OverlapAlgo {


 /// This method accepts 1 [mainPolygon] which will be taken
  /// as reference to calculate overlaps with the [sampleSet]
  static Set<List<LatLng>> detectOverlaps(Polygon mainPolygon, List<Polygon> sampleSet) {
    Set<List<LatLng>> overlaps = {};

    try {

      var mainCoords = <jts.Coordinate>[];
      for(LatLng latLng in mainPolygon.points){
        mainCoords.add(jts.Coordinate(latLng.latitude,latLng.longitude));
      }



      for(Polygon neighbour in sampleSet){

        var neighbourCoords = <jts.Coordinate>[];
        for(LatLng latLng in neighbour.points){
          neighbourCoords.add(jts.Coordinate(latLng.latitude,latLng.longitude));
        }

        RegionPolygon mainPolyRegion = RegionPolygon(regions: [
          mainCoords,
        ]);

        RegionPolygon neighbourPolyRegion = RegionPolygon(regions: [
          neighbourCoords
        ]);

        var mainSeg = PolyBool().segments(mainPolyRegion);
        var neighbourSeg = PolyBool().segments(neighbourPolyRegion);
        var comb = PolyBool().combine(mainSeg, neighbourSeg);
        Map<String,RegionPolygon> result = {
          'difference': PolyBool().polygon(PolyBool().selectDifference(comb)),
          'intersect': PolyBool().polygon(PolyBool().selectIntersect(comb))
        };

        if(result['intersect'] != null && result['intersect']!.regions != null) {
          var latlngs = <LatLng>[];

          if((result['intersect']?.regions?.length ?? -1)>0) {
            for (jts.Coordinate coords in (result['intersect']?.regions?[0] ?? [])) {
              LatLng latLng = LatLng(coords.x, coords.y);
              latlngs.add(latLng);
            }

            overlaps.add(latlngs);

          }
        }
      }
    } catch(e) {
      log("ERROR!!! in detectOverlaps - $e");
    }
    return overlaps;
  }

  /// This method accepts 2 lists of polygons and detect all possible overlaps within
  /// them [targetSet] and [neighbouringSet]
  static Set<List<LatLng>> detectAllOverlaps(List<Polygon> targetSet, [List<Polygon>? neighbouringSet]) {
    Set<List<LatLng>> overlaps = {};

    for (int i=0;i<targetSet.length-1;i++) {
      overlaps.addAll(detectOverlaps(targetSet[i], targetSet.sublist(i+1)));
    }

    if (neighbouringSet != null) {
      for (int i = 0; i < targetSet.length; i++) {
        for (int j = 0; j < neighbouringSet.length; j++) {}
        overlaps.addAll(detectOverlaps(targetSet[i], neighbouringSet));
      }
    }

    return overlaps;
  }


}