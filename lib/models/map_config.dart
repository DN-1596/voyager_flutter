import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VoyagerMapConfig {
  VoyagerMapConfig({
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.compassEnabled = true,
    this.mapToolbarEnabled = false,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = false,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = false,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.padding = const EdgeInsets.all(0),
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = false,
    this.markers = const <Marker>{},
    this.polygons = const <Polygon>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.onCameraMoveStarted,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraMove,
    this.onCameraIdle,
  });

  bool compassEnabled;

  bool mapToolbarEnabled;

  CameraTargetBounds cameraTargetBounds;

  MapType mapType;

  MinMaxZoomPreference minMaxZoomPreference;

  bool rotateGesturesEnabled;

  bool scrollGesturesEnabled;

  bool zoomControlsEnabled;

  bool zoomGesturesEnabled;

  bool liteModeEnabled;

  bool tiltGesturesEnabled;

  EdgeInsets padding;

  Set<Marker> markers;

  Set<Polygon> polygons;

  Set<Polyline> polylines;

  Set<Circle> circles;

  Set<TileOverlay> tileOverlays;

  VoidCallback? onCameraMoveStarted;

  CameraPositionCallback? onCameraMove;

  VoidCallback? onCameraIdle;

  bool myLocationEnabled;

  bool myLocationButtonEnabled;

  bool indoorViewEnabled;

  bool trafficEnabled;

  bool buildingsEnabled;

  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  VoyagerMapConfig copyWith({
    bool? compassEnabled,
    bool? mapToolbarEnabled,
    CameraTargetBounds? cameraTargetBounds,
    MapType? mapType,
    MinMaxZoomPreference? minMaxZoomPreference,
    bool? rotateGesturesEnabled,
    bool? scrollGesturesEnabled,
    bool? zoomControlsEnabled,
    bool? zoomGesturesEnabled,
    bool? liteModeEnabled,
    bool? tiltGesturesEnabled,
    EdgeInsets? padding,
    Set<Marker>? markers,
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    Set<Circle>? circles,
    Set<TileOverlay>? tileOverlays,
    VoidCallback? onCameraMoveStarted,
    CameraPositionCallback? onCameraMove,
    VoidCallback? onCameraIdle,
    bool? myLocationEnabled,
    bool? myLocationButtonEnabled,
    bool? indoorViewEnabled,
    bool? trafficEnabled,
    bool? buildingsEnabled,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return VoyagerMapConfig(
      gestureRecognizers: gestureRecognizers ?? this.gestureRecognizers,
      compassEnabled: compassEnabled ?? this.compassEnabled,
      mapToolbarEnabled: mapToolbarEnabled ?? this.mapToolbarEnabled,
      cameraTargetBounds: cameraTargetBounds ?? this.cameraTargetBounds,
      mapType: mapType ?? this.mapType,
      minMaxZoomPreference: minMaxZoomPreference ?? this.minMaxZoomPreference,
      rotateGesturesEnabled:
          rotateGesturesEnabled ?? this.rotateGesturesEnabled,
      scrollGesturesEnabled:
          scrollGesturesEnabled ?? this.scrollGesturesEnabled,
      zoomControlsEnabled: zoomControlsEnabled ?? this.zoomControlsEnabled,
      zoomGesturesEnabled: zoomGesturesEnabled ?? this.zoomGesturesEnabled,
      liteModeEnabled: liteModeEnabled ?? this.liteModeEnabled,
      tiltGesturesEnabled: tiltGesturesEnabled ?? this.tiltGesturesEnabled,
      myLocationEnabled: myLocationEnabled ?? this.myLocationEnabled,
      myLocationButtonEnabled:
          myLocationButtonEnabled ?? this.myLocationButtonEnabled,
      padding: padding ?? this.padding,
      indoorViewEnabled: indoorViewEnabled ?? this.indoorViewEnabled,
      trafficEnabled: trafficEnabled ?? this.trafficEnabled,
      buildingsEnabled: buildingsEnabled ?? this.buildingsEnabled,
      markers: markers ?? this.markers,
      polygons: polygons ?? this.polygons,
      polylines: polylines ?? this.polylines,
      circles: circles ?? this.circles,
      onCameraMoveStarted: onCameraMoveStarted ?? this.onCameraMoveStarted,
      tileOverlays: tileOverlays ?? this.tileOverlays,
      onCameraMove: onCameraMove ?? this.onCameraMove,
      onCameraIdle: onCameraIdle ?? this.onCameraIdle,
    );
  }
}
