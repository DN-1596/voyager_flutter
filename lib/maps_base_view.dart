

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/models/map_config.dart';
import 'package:voyager_flutter/models/voyager_map_controller.dart';

class MapsBaseView extends StatelessWidget {

  final VoyagerMapController mapController;

  final Key mapsKey;

  MapsBaseView({
    required this.mapsKey,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VoyagerMapConfig>(
        valueListenable: mapController.getMapConfigNotifier(),
      builder: (context, mapConfig,_) {
        return GoogleMap(
          key: mapsKey,
          initialCameraPosition: mapController.initialCameraPosition,
          onMapCreated: mapController.initiateMaps,
          gestureRecognizers: mapConfig.gestureRecognizers,
          compassEnabled: mapConfig.compassEnabled,
          mapToolbarEnabled: mapConfig.mapToolbarEnabled,
          cameraTargetBounds: mapConfig.cameraTargetBounds,
          mapType: mapConfig.mapType,
          minMaxZoomPreference: mapConfig.minMaxZoomPreference,
          rotateGesturesEnabled: mapConfig.rotateGesturesEnabled,
          scrollGesturesEnabled: mapConfig.scrollGesturesEnabled,
          zoomControlsEnabled: mapConfig.zoomControlsEnabled,
          zoomGesturesEnabled: mapConfig.zoomGesturesEnabled,
          liteModeEnabled: mapConfig.liteModeEnabled,
          tiltGesturesEnabled: mapConfig.tiltGesturesEnabled,
          myLocationEnabled: mapConfig.myLocationEnabled,
          myLocationButtonEnabled: mapConfig.myLocationButtonEnabled,
          padding: mapConfig.padding,
          indoorViewEnabled: mapConfig.indoorViewEnabled,
          trafficEnabled: mapConfig.trafficEnabled,
          buildingsEnabled: mapConfig.buildingsEnabled,
          markers: mapConfig.markers,
          polygons: mapConfig.polygons,
          polylines: mapConfig.polylines,
          circles: mapConfig.circles,
          onCameraMoveStarted: mapConfig.onCameraMoveStarted,
          tileOverlays: mapConfig.tileOverlays,
          onCameraMove: mapController.onCameraMove,
          onTap: mapController.onSingleTap,
          onLongPress: mapController.onLongPress,
        );
      }
    );
  }
}
