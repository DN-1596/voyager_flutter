

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/components/index.dart';
import 'package:voyager_flutter/models/voyager_feature_set.dart';
import 'package:voyager_flutter/models/map_config.dart';

class MapBloc {

  late GoogleMapController googleMapController;

  late ValueNotifier<VoyagerMapConfig> mapConfigNotifier;

  MapBloc({
    required VoyagerMapConfig voyagerMapConfig,
  }) {
    mapConfigNotifier = ValueNotifier<VoyagerMapConfig>(
      voyagerMapConfig,
    );
  }

  Completer<bool> isMapReady = Completer();

  final VoyagerFeatureSet voyagerFeatureSet = VoyagerFeatureSet(
    polygons: {},
    markers: {},
    polylines: {},
  );

  final ValueNotifier<VoyagerInfoWindow?> infoWindowMarkerNotifier = ValueNotifier(null);

  void updateGeometries({
    Set<Polygon> polygons = const {},
    Set<Marker> markers = const {},
    Set<Polyline> polylines = const {},
  }) {
    voyagerFeatureSet.updateVoyagerFeatureSet(
        polygons: polygons,
        markers: markers,
        polylines: polylines,
      );
  }


 void onMarkerInfoWindowTap({required String markerId}) async {
   MarkerId mId = MarkerId(markerId);
   if (await googleMapController.isMarkerInfoWindowShown(mId)) {
     googleMapController.hideMarkerInfoWindow(mId);
   } else {
     googleMapController.showMarkerInfoWindow(mId);
   }
 }


  void updateMapConfig(VoyagerMapConfig event) {
    mapConfigNotifier.value = event;
  }

  void updateMetaData({
    required Map<PolygonId, FeatureMetadata> polygonMetadata,
    required Map<PolygonId, FeatureMetadata> polylineMetadata,
    required Map<PolygonId, FeatureMetadata> markerMetadata,
  }) {
    polygonMetadata.forEach((polygonId, _featureMetadata) {
      _featureMetadata.getMetaData().forEach(
            (key, data) => voyagerFeatureSet.updateFeatureMetaData(
          mapsObjectId: polygonId,
          key: key,
          data: data,
        ),
      );
    });
    polylineMetadata.forEach((polygonId, _featureMetadata) {
      _featureMetadata.getMetaData().forEach(
            (key, data) => voyagerFeatureSet.updateFeatureMetaData(
          mapsObjectId: polygonId,
          key: key,
          data: data,
        ),
      );
    });
    markerMetadata.forEach((polygonId, _featureMetadata) {
      _featureMetadata.getMetaData().forEach(
            (key, data) => voyagerFeatureSet.updateFeatureMetaData(
          mapsObjectId: polygonId,
          key: key,
          data: data,
        ),
      );
    });
  }


}