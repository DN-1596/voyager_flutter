


import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/data_processor/algorithm/index.dart';
import 'package:voyager_flutter/models/index.dart';
import 'package:voyager_flutter/protocols/protocol.dart';

typedef OnFeatureGesture<T> = void Function(T mapsObject);

class VoyagerFeaturesInteractionProtocol extends VoyagerProtocol {

  final OnFeatureGesture<Polygon>? onPolygonSingleTap;
  final OnFeatureGesture<Marker>? onMarkerSingleTap;
  final OnFeatureGesture<Polyline>? onPolylineSingleTap;

  final OnFeatureGesture<Polygon>? onPolygonLongPress;
  final OnFeatureGesture<Marker>? onMarkerLongPress;
  final OnFeatureGesture<Polyline>? onPolylineLongPress;

  VoyagerFeaturesInteractionProtocol({
    required super.mapController,
    this.onPolygonSingleTap,
    this.onMarkerSingleTap,
    this.onPolylineSingleTap,
    this.onPolygonLongPress,
    this.onMarkerLongPress,
    this.onPolylineLongPress,
  });

  @override
  void onCameraMove(CameraPosition cameraPosition) {}

  @override
  void onLongPress(LatLng latLng) => _takeActionOnFeature(
    latLng: latLng,
    onPolygonGesture: onPolygonLongPress,
    onMarkerGesture: onMarkerLongPress,
    onPolylineGesture: onPolylineLongPress,
  );

  @override
  void onSingleTap(LatLng latLng) => _takeActionOnFeature(
        latLng: latLng,
        onPolygonGesture: onPolygonSingleTap,
        onMarkerGesture: onMarkerSingleTap,
        onPolylineGesture: onPolylineSingleTap,
      );

  void _takeActionOnFeature({
    required LatLng latLng,
    OnFeatureGesture<Polygon>? onPolygonGesture,
    OnFeatureGesture<Marker>? onMarkerGesture,
    OnFeatureGesture<Polyline>? onPolylineGesture,
  }) async {

    VoyagerFeatureSet voyagerFeatureSet = mapController.getVoyagerFeatureSet();

    if (onPolygonGesture != null) {
      Polygon? _tappedPolygon;
      for (Polygon polygon in voyagerFeatureSet.polygons.toList()) {
        if (PointAlgo.isPointInPolygons(latLng, {polygon})) {
          _tappedPolygon = polygon;
          break;
        }
      }
      if (_tappedPolygon != null) {
        onPolygonGesture(_tappedPolygon);
      }
    }

    if (onMarkerGesture != null) {
      Marker? _tappedMarker;
      for (Marker marker in voyagerFeatureSet.markers.toList()) {
        if (latLng == marker.position) {
          _tappedMarker = marker;
          break;
        }
      }
      if (_tappedMarker != null) {
        onMarkerGesture(_tappedMarker);
      }
    }

    if (onPolylineGesture != null) {
      Polyline? _tappedPolyline;
      for (Polyline polyline in voyagerFeatureSet.polylines.toList()) {
        LatLngBounds bounds = await mapController.getVisibleRegion();
        if (PointAlgo.isPointOnPolyline(latLng, polyline,bounds)) {
          _tappedPolyline = polyline;
          break;
        }
      }
      if (_tappedPolyline != null) {
        onPolylineGesture(_tappedPolyline);
      }
    }

  }
}