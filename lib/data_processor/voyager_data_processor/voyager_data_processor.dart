import 'dart:developer' as d;

import 'package:dart_jts/dart_jts.dart' as jts;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/components/index.dart';
import 'package:voyager_flutter/models/index.dart';

enum FormatType {
  wkb,
  wkt,
}

typedef DataExtractor<T> = Future<List<String>> Function(T data);
typedef GeometryProcessor = List<jts.Geometry> Function(List<String> geomList);

class VoyagerDataProcessor {


  static jts.Geometry _processGeometryWKB({required String data}) {
    var bytes = jts.WKBReader.hexToBytes(data);
    jts.Geometry geom = jts.WKBReader().read(bytes);
    return geom;
  }

  static jts.Geometry _processGeometryWKT({required String data}) =>
      jts.WKTReader().read(data)!;

  static Future<VoyagerFeatureSet> decodeFeature({
    required String data,
    required FormatType formatType,
    required String featureId,
    required MarkerConfig markerConfig,
    required PolylineConfig polylineConfig,
    required PolygonConfig polygonConfig,
  }) {
    Map<String,jts.Geometry> geometries = {};
    jts.Geometry geom;
    try {
      switch (formatType) {
        case FormatType.wkb:
          geom = _processGeometryWKB(data: data);
          break;
        case FormatType.wkt:
        default:
          geom = _processGeometryWKT(data: data);
      }

      geometries[featureId] = geom;
    }  catch (e) {
      rethrow;
    }
    return _getFeaturesFromGeometries(
      geometries,
      markerConfig: markerConfig,
      polylineConfig: polylineConfig,
      polygonConfig: polygonConfig,
    );
  }

  static Future<VoyagerFeatureSet> _getFeaturesFromGeometries(
    Map<String, jts.Geometry> geometries, {
    required MarkerConfig markerConfig,
    required PolylineConfig polylineConfig,
    required PolygonConfig polygonConfig,
  }) async {
    VoyagerFeatureSet voyagerFeatureSet = VoyagerFeatureSet(
      polygons: {},
      markers: {},
      polylines: {},
    );

    for (String id in geometries.keys) {
      jts.Geometry? geom = geometries[id];
      if (geom == null) continue;
      if (geom.getGeometryType() == "Polygon") {
        Polygon _polygon = PolygonBuilder.getPolygonFromGeometry(
          geom: geom as jts.Polygon,
          polygonConfig: polygonConfig,
          polygonId: id,
        );
        voyagerFeatureSet.updateVoyagerFeatureSet(polygons: {_polygon});
      }

      if (geom.getGeometryType() == "Point") {
        Marker? _mkr = await MarkerBuilder.getMarkerFromGeometry(
          geom: geom as jts.Point,
          markerConfig: markerConfig,
          markerId: id,
        );
        if (_mkr == null) {
          d.log("ERROR !! unable to process marker");
        } else {
          voyagerFeatureSet.updateVoyagerFeatureSet(markers: {_mkr});
        }
      }

      if (geom.getGeometryType() == "LineString") {
        Polyline _polyline = PolylineBuilder.getPolylineFromLineString(
          lineString: geom as jts.LineString,
          polylineConfig: polylineConfig,
          id: id,
        );
        voyagerFeatureSet.updateVoyagerFeatureSet(polylines: {_polyline});
      }

      if (geom.getGeometryType() == "MultiPolygon") {
        List<jts.Geometry> geometries = (geom as jts.MultiPolygon).geometries;

        for (int i = 0; i < geometries.length; i++) {
          String pId = id + "_" + "$i";
          Polygon _polygon = PolygonBuilder.getPolygonFromGeometry(
            geom: geometries[i] as jts.Polygon,
            polygonConfig: polygonConfig,
            polygonId: pId,
          );
          voyagerFeatureSet.updateVoyagerFeatureSet(polygons: {_polygon});
        }
      }

    }

    return voyagerFeatureSet;

  }


  static FormatType getGeometryType(String type) {
    String _type = type.toUpperCase();
    if (_type == "WKB" || _type == "WELL-KNOWN-BINARY") {
      return FormatType.wkb;
    }
    if (_type == "WKT" || _type == "WELL-KNOWN-TEXT") {
      return FormatType.wkt;
    }
    throw "INVALID TYPE";
  }


  static List<LatLng> extractLatLngFromData({
    required String data,
    required FormatType formatType,
  }) {

    jts.Geometry geometry;
    try {
      switch (formatType) {
        case FormatType.wkb:
          geometry = _processGeometryWKB(data: data);
          break;
        case FormatType.wkt:
        default:
        geometry = _processGeometryWKT(data: data);
      }
    }  catch (e) {
      rethrow;
    }
    return _getLatLngFromGeometry(geometry);
  }

  static List<LatLng> _getLatLngFromGeometry(jts.Geometry geometry) {
    List<LatLng> latlngs = [];
    List<jts.Coordinate> _coordinates = geometry.getCoordinates();

    for (jts.Coordinate point in _coordinates) {
      try {
        LatLng latLng = LatLng(
          point.y,
          point.x,
        );

        latlngs.add(latLng);
      } catch (e) {
        d.log("ERROR!! UNABLE TO PARSE POINT : $e");
      }
    }
    return latlngs;
  }
}
