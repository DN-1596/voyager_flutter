
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/protocols/index.dart';

class VoyagerMarkerProtocol extends VoyagerProtocol {

  late double devicePixelRatio;

  VoyagerMarkerProtocol({
    required super.mapController,
    required this.updateInfoWindow,
  }) {
    mapController.getInfoWindowMarkerNotifier().addListener(updateInfoWindow);
  }

  final VoidCallback updateInfoWindow;

  @override
  void onCameraMove(CameraPosition cameraPosition) {
    updateInfoWindow();
  }

  @override
  void onLongPress(LatLng latLng) {
    // TODO: implement onLongPress
  }

  @override
  void onSingleTap(LatLng latLng) {
    // TODO: implement onSingleTap
  }

}