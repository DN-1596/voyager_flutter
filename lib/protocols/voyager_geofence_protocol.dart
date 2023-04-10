


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/camera.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:voyager_flutter/components/index.dart';
import 'package:voyager_flutter/data_processor/algorithm/index.dart';
import 'package:voyager_flutter/data_processor/algorithm/polygon_util.dart';
import 'package:voyager_flutter/protocols/index.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';


const Duration kDelay = Duration(seconds: 1);
PolygonConfig tappedPolygonCofig = PolygonConfig(
  fillColor: Colors.transparent, strokeColor: Colors.transparent,);

class VoyagerGeofenceProtocol extends VoyagerProtocol {


  static String kManualGeofencePolygon = "VoyagerManualGeoPoly_";
  static String kEditPolyline = "VoyagerEditPolyline_";
  static String kEditMarker = "VoyagerEditMarker_";

  final PolylineConfig editPolylineConfig;
  final MarkerConfig editMarkerConfig;
  final PolygonConfig manualGeofenceConfig;
  final Widget deleteMarkerIcon;
  final Size deleteMarkerSize;

  VoyagerGeofenceProtocol({
    required super.mapController,
    required this.editPolylineConfig,
    required this.editMarkerConfig,
    required this.manualGeofenceConfig,
    this.deleteMarkerIcon = const Icon(
      Icons.delete,
      color: Colors.red,
      size: 20,
    ),
    this.deleteMarkerSize = const Size(25, 25),
  });

  // edit polyline to be rendered corresponding to the edit polygon
  Polyline? _editPolyline;
  Polygon? _editPolygon;

  @override
  void onSingleTap(LatLng latLng) async {

    if (_editPolyline != null) {
      mapTapToEditPolygon(latLng);
    } else {
      Polygon? tappedManualGeofence = _getTappedManualGeofence(latLng);
      if (tappedManualGeofence != null) {
        await markPolygonForEdit(tappedManualGeofence);
      }
    }
  }

  Polygon? _getTappedManualGeofence(LatLng tapLoc) {
    PolygonId? _tappedPolygonId;
    for (Polygon _polygon in mapController.getVoyagerFeatureSet().polygons) {
      if (PointAlgo.isPointInPolygons(tapLoc, {_polygon})) {
        _tappedPolygonId = _polygon.polygonId;
        if (_tappedPolygonId.value.contains(kManualGeofencePolygon)) {
          return _polygon;
        }
      }
    }
    return null;
  }

  /// cases being handled using [mapTapToEditPolygon],
  /// 1. if [_editPolyline] is not null then either a point will be inserted or added
  /// depending on tap location [tapLoc]
  /// 2. if [_editPolyline] is null then if the user taps on any of the polygon it will be made
  /// editable

  Future<void> mapTapToEditPolygon(LatLng tapLoc) async {
    if (_editPolygon == null) return;
    LatLngBounds bounds = await mapController.getVisibleRegion();
    List<LatLng> _editPolygonPoints = _editPolygon!.points;
    int idx = PointAlgo.locationIndexOnEdgeOrPath(tapLoc, _editPolygonPoints,bounds);
    if (idx >= 0) {
      _editPolygonPoints.insert(idx + 1, tapLoc);
    } else {
      if (_editPolygonPoints.length > 2  && _editPolygonPoints.first == _editPolygonPoints.last) {
        _editPolygonPoints.removeLast();
      }
      _editPolygonPoints.add(tapLoc);
    }
    _editPolygon = _editPolygon!.copyWith(pointsParam: ensureLinearRing(_editPolygonPoints),);
    if (_editPolygonPoints.isNotEmpty) {
      await generateEditPolyline();
    }
  }


  Future<void> markPolygonForEdit(Polygon tappedManualGeofence) async {
    _editPolygon = tappedManualGeofence;
    await generateEditPolyline();
  }

  Future<void> generateEditPolyline() async {
    _clearEditGeometryFromFeatureSet();
    _editPolyline = Polyline(
      polylineId: PolylineId(kEditPolyline),
      color: editPolylineConfig.color,
      width: editPolylineConfig.width,
      consumeTapEvents: false,
      geodesic: true,
      visible: true,
      jointType: JointType.round,
      points: ensureLinearRing(_editPolygon!.points),
    );
    List<Marker> _editMarkers = await _generateEditMarkers();
    await mapController.updateGeometries(
      markers: _editMarkers.toSet(),
      polylines: {_editPolyline!},
      polygons: {
        _editPolygon!
            .copyWith(
              strokeColorParam: tappedPolygonCofig.strokeColor,
              fillColorParam: tappedPolygonCofig.fillColor,
            )
      },
    );
  }

  _clearEditGeometryFromFeatureSet() {
    List<MapsObject> mapsObj= [];
    if (_editPolyline != null) {
      mapsObj.add(_editPolyline!);
      _editPolyline = null;
    }
    mapsObj.addAll(
      mapController.getVoyagerFeatureSet().markers.where(
            (element) => element.markerId.value.contains(kEditMarker),
      ),
    );
    mapController.removeGeometry(
      mapsObj,
      autoRender: false,
    );
  }

  Future<List<Marker>> _generateEditMarkers() async {

    BitmapDescriptor editMarkerIcon = await editMarkerConfig.icon.future;
    List<Marker> _markers = [];
    List<LatLng> _editPolygonPoints = _editPolygon!.points;
    for (int i=0;i<_editPolygonPoints.length;i++) {
      String _markerId = kEditMarker+"_"+i.toString();

      Marker _marker = Marker(
        markerId: MarkerId(_markerId),
        position: _editPolygonPoints[i],
        icon: editMarkerIcon,
        consumeTapEvents: true,
        draggable: true,
        anchor: editMarkerConfig.anchor,
        onDragStart: (_) {
          mapController.getInfoWindowMarkerNotifier().value = null;
        },
        onDragEnd: (_newPt) {
          // in case the point is the last/first point
          // moving the first/last point as well
          // in order to maintain polygon shape.
          _editPolygonPoints[i] = _newPt;
            if (i == 0 && _editPolygonPoints.length > 2) {
              _editPolygonPoints[_editPolygonPoints.length - 1] = _newPt;
            }
            if (i == _editPolygonPoints.length - 1 && _editPolygonPoints.length > 2) {
              _editPolygonPoints[0] = _newPt;
            }
            _editPolyline = _editPolyline?.copyWith(
              pointsParam: _editPolygonPoints,
            );
            generateEditPolyline();
        },
        onTap: () {
            mapController.getInfoWindowMarkerNotifier().value =
                VoyagerInfoWindow(
              widget: GestureDetector(
                onTap: () {
                  LatLng ptToDelete = _editPolygonPoints[i];
                  _editPolygonPoints.removeWhere(
                    (element) => element == ptToDelete,
                  );
                  if (_editPolygonPoints.isEmpty) {
                    _clearEditGeometryFromFeatureSet();
                    mapController.removeGeometry([_editPolygon!]);
                  } else {
                    generateEditPolyline();
                  }
                  mapController.getInfoWindowMarkerNotifier().value = null;
                },
                child: deleteMarkerIcon,
              ),
              latLng: _editPolygonPoints[i],
              size: deleteMarkerSize,
            );
          }
      );
      _markers.add(_marker);
    }
    return _markers;
  }

  List<LatLng> ensureLinearRing(List<LatLng> pts) {
    List<LatLng> points = [];
    points.addAll(pts);
    if (pts.length >= 3) {
      if (pts.first != pts.last) {
        points.add(pts.first);
      }
    }
    return points;
  }


  @override
  void onLongPress(LatLng latLng) async {

    if (_editPolyline != null) {
      return;
    }

    LatLngBounds bounds = await mapController.getVisibleRegion();
    Polygon polygon = Polygon(
      polygonId: PolygonId(kManualGeofencePolygon + DateTime.now().toString()),
      points: PolygonUtil.getBoxAroundAPoint(latLng, bounds),
      strokeWidth: manualGeofenceConfig.strokeWidth,
      fillColor: manualGeofenceConfig.fillColor,
      strokeColor: manualGeofenceConfig.strokeColor,
    );

    await mapController.updateGeometries(
      polygons: {polygon},
      autoRender: false,
    );

    await markPolygonForEdit(polygon);

  }

  @override
  void onCameraMove(CameraPosition cameraPosition) {
    // TODO: implement onCameraMove
  }

}