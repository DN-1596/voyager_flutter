



import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/components/index.dart';
import 'package:voyager_flutter/models/index.dart';
import 'package:voyager_flutter/protocols/protocol.dart';
import 'package:voyager_flutter/src/map_bloc.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';


class VoyagerMapController {

  late MapBloc _mapBloc;

  VoyagerMapController({
    required this.initialCameraPosition,
    required this.onMapInitiated,
    required VoyagerMapConfig voyagerMapConfig,
  }) {
    _mapBloc = MapBloc(
      voyagerMapConfig: voyagerMapConfig,
    );
  }
  final CameraPosition initialCameraPosition;
  final VoidCallback onMapInitiated;

  final Set<TileOverlay> tileOverlays = {};
  final List<VoyagerProtocol> _protocols = [];

  GoogleMapController get googleMapController => _mapBloc.googleMapController;

  Future<bool> getIsMapReady() => _mapBloc.isMapReady.future;

  ValueNotifier<VoyagerMapConfig> getMapConfigNotifier() => _mapBloc.mapConfigNotifier;

  Future<void> onSingleTap(LatLng latLng) async {
    await _mapBloc.isMapReady.future;
    for (VoyagerProtocol protocol in _protocols) {
      protocol.onSingleTap(latLng);
    }
  }

  Future<void> onLongPress(LatLng latLng) async {
    await _mapBloc.isMapReady.future;
    for (VoyagerProtocol protocol in _protocols) {
      protocol.onLongPress(latLng);
    }
  }

  Future<void> onCameraMove(CameraPosition position) async {
    await _mapBloc.isMapReady.future;
    for (VoyagerProtocol protocol in _protocols) {
      protocol.onCameraMove(position);
    }
  }

  void initiateMaps(GoogleMapController googleMapController) {
    _mapBloc.googleMapController = googleMapController;
    _mapBloc.isMapReady.complete(true);
    onMapInitiated();
  }


  // Sends Geometries to [MapsBaseView] to render using [autoRender]
  // if [autoRender] is false it just updated the [VoyagerFeatureSet]
  Future<void> updateGeometries({
    Set<Polygon> polygons = const {},
    Set<Marker> markers = const {},
    Set<Polyline> polylines = const {},
    bool autoRender = true,
  }) async {

    await _mapBloc.isMapReady.future;

    _mapBloc.updateGeometries(
        polygons: polygons,
        markers: markers,
        polylines: polylines,
      );

      if (autoRender) {
        _mapBloc.updateMapConfig(
          _mapBloc.mapConfigNotifier.value.copyWith(
            polygons: _mapBloc.voyagerFeatureSet.polygons,
            markers: _mapBloc.voyagerFeatureSet.markers,
            polylines: _mapBloc.voyagerFeatureSet.polylines,
          ),
        );
      }
  }

  Future<void> removeGeometry(
    List<MapsObject> mapsObjects, {
    bool autoRender = true,
  }) async {
    await _mapBloc.isMapReady.future;


    for (MapsObject obj in mapsObjects) {
      _mapBloc.voyagerFeatureSet.removeFeatureFromVoyagerFeatureSet(
          obj
        );
    }

    if (autoRender) {
      _mapBloc.updateMapConfig(
        _mapBloc.mapConfigNotifier.value.copyWith(
          polygons: _mapBloc.voyagerFeatureSet.polygons,
          markers: _mapBloc.voyagerFeatureSet.markers,
          polylines: _mapBloc.voyagerFeatureSet.polylines,
        ),
      );
    }
  }


  Future<void> registerTileOverlay(TileOverlay tileOverlay) async {
    await _mapBloc.isMapReady.future;
    tileOverlays.add(tileOverlay);
    _updateOverlays();
  }

  Future<void> deRegisterTileOverlay(TileOverlayId tileOverlayId) async {
    await _mapBloc.isMapReady.future;
    tileOverlays.removeWhere(
      (tileOverlay) => tileOverlay.tileOverlayId == tileOverlayId,
    );
    _updateOverlays();
  }

  void removeAllOverlays() {
    tileOverlays.clear();
    _updateOverlays();
  }

  void _updateOverlays() => _mapBloc.updateMapConfig(
        _mapBloc.mapConfigNotifier.value.copyWith(
          tileOverlays: tileOverlays,
        ),
      );

  VoyagerFeatureSet getVoyagerFeatureSet()=> _mapBloc.voyagerFeatureSet;

  Future<void> resetFeatureSet() async {
    await _mapBloc.isMapReady.future;
    _mapBloc
      ..voyagerFeatureSet.resetFeatureSet()
      ..updateMapConfig(
        _mapBloc.mapConfigNotifier.value.copyWith(
          polygons: _mapBloc.voyagerFeatureSet.polygons,
          markers: _mapBloc.voyagerFeatureSet.markers,
          polylines: _mapBloc.voyagerFeatureSet.polylines,
        ),
      );
  }

  void addProtocol(VoyagerProtocol protocol) => _protocols.add(protocol);

  void removeProtocol<T>() {
    if (T is! VoyagerProtocol) return ;
    _protocols.removeWhere((protocol) => protocol is T);
  }

  void onMarkerInfoWindowTap({required String markerId}) =>
      _mapBloc.onMarkerInfoWindowTap(
        markerId: markerId,
      );

  Future<void> focusOnFeatureSet({
    VoyagerFeatureSet? featureSet,
    double padding = 100.0,
  }) async {
    try {
      await _mapBloc.isMapReady.future;
      await Future.delayed(
        const Duration(seconds: 1),
        () => _mapBloc.googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
              (featureSet ?? getVoyagerFeatureSet()).getBoundsForFeatureSet()!,padding),
        ),
      );
    } catch (e) {
      log("Error!!! Unable to focus to feature set");
    }
  }

  void updateMetaData({
    Map<PolygonId, FeatureMetadata>? polygonMetadata,
    Map<PolygonId, FeatureMetadata>? polylineMetadata,
    Map<PolygonId, FeatureMetadata>? markerMetadata,
  }) =>
      _mapBloc.updateMetaData(
        polygonMetadata: polygonMetadata ?? {},
        polylineMetadata: polylineMetadata ?? {},
        markerMetadata: markerMetadata ?? {},
      );

  FeatureMetadata? getFeatureMetaData({required MapsObjectId mapsObjectId}) {
    return _mapBloc.voyagerFeatureSet.getFeatureMetaData(mapsObjectId: mapsObjectId,);
  }

  Future<LatLngBounds> getVisibleRegion() => _mapBloc.googleMapController.getVisibleRegion();

  ValueNotifier<VoyagerInfoWindow?> getInfoWindowMarkerNotifier() => _mapBloc.infoWindowMarkerNotifier;

}