


import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/models/voyager_map_controller.dart';

abstract class VoyagerProtocol {
  final VoyagerMapController mapController;

  VoyagerProtocol({
    required this.mapController,
  });


  void onSingleTap(LatLng latLng);

  void onLongPress(LatLng latLng);

  void onCameraMove(CameraPosition cameraPosition);

}

