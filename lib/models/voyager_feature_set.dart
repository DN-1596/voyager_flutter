
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:voyager_flutter/models/index.dart';

class VoyagerFeatureSet {
  final Set<Polygon> polygons;
  final Map<PolygonId,FeatureMetadata> polygonMetadata= {};
  final Set<Marker> markers;
  final Map<MarkerId,FeatureMetadata> markerMetadata= {};
  final Set<Polyline> polylines;
  final Map<PolylineId,FeatureMetadata> polylineMetadata= {};

  VoyagerFeatureSet({
    required this.polygons,
    required this.markers,
    required this.polylines,
  });

  void updateVoyagerFeatureSet({
    Set<Polygon> polygons = const {},
    Set<Marker> markers = const {},
    Set<Polyline> polylines = const {},
  }) {

    polygons.forEach(removeFeatureFromVoyagerFeatureSet);
    markers.forEach(removeFeatureFromVoyagerFeatureSet);
    polylines.forEach(removeFeatureFromVoyagerFeatureSet);

    this
      ..polygons.addAll(polygons)
      ..markers.addAll(markers)
      ..polylines.addAll(polylines);
  }

  void removeFeatureFromVoyagerFeatureSet<MapsObject>(MapsObject mapsObject) {
    if (mapsObject is Polygon ) {
      polygons
          .removeWhere((element) => mapsObject.polygonId == element.polygonId);
    }
    if (mapsObject is Marker ) {
      markers
          .removeWhere((element) => mapsObject.markerId == element.markerId);
    }
    if (mapsObject is Polyline ) {
      polylines
          .removeWhere((element) => mapsObject.polylineId == element.polylineId);
    }
  }

  void resetFeatureSet() {
    this
      ..polygons.clear()
      ..polylines.clear()
      ..markers.clear()
      ..polygonMetadata.clear()
      ..polylineMetadata.clear()
      ..markerMetadata.clear();
  }

  LatLngBounds? getBoundsForFeatureSet() {
    List<LatLng> latLngs = [];

    for (Polygon element in polygons) {
      for (LatLng latlng in element.points) {
        latLngs.add(latlng);
      }
    }
    for (Polyline element in polylines) {
      for (LatLng latlng in element.points) {
        latLngs.add(latlng);
      }
    }
    for (Marker element in markers) {
      latLngs.add(element.position);
    }

    if (latLngs.isNotEmpty) {
      final southwestLat = latLngs.map((p) => p.latitude).reduce(
              (value, element) => value < element ? value : element); // smallest
      final southwestLon = latLngs
          .map((p) => p.longitude)
          .reduce((value, element) => value < element ? value : element);
      final northeastLat = latLngs.map((p) => p.latitude).reduce(
              (value, element) => value > element ? value : element); // biggest
      final northeastLon = latLngs
          .map((p) => p.longitude)
          .reduce((value, element) => value > element ? value : element);


      return LatLngBounds(
          southwest: LatLng(southwestLat, southwestLon),
          northeast: LatLng(northeastLat, northeastLon)
      );

    }
    return null;
  }

  void updateFeatureMetaData(
      {required MapsObjectId mapsObjectId,
      required String key,
      required String data}) {

    Map<MapsObjectId,FeatureMetadata> metadataToUpdate;

    if (mapsObjectId is PolygonId) {
      metadataToUpdate = polygonMetadata;
    } else if (mapsObjectId is PolylineId) {
      metadataToUpdate = polylineMetadata;
    } else if (mapsObjectId is MarkerId) {
      metadataToUpdate = markerMetadata;
    } else {
      throw "UNKNOWN MAP OBJECT";
    }

    metadataToUpdate.update(
      mapsObjectId,
          (value) => value.updateMetadata(
        key: key,
        data: data,
      ),
      ifAbsent: () => FeatureMetadata().updateMetadata(
        key: key,
        data: data,
      ),
    );
  }

  FeatureMetadata? getFeatureMetaData({
    required MapsObjectId mapsObjectId,
  }) {
    Map<MapsObjectId,FeatureMetadata> metaDataForFetch;

    if (mapsObjectId is PolygonId) {
      metaDataForFetch = polygonMetadata;
    } else if (mapsObjectId is PolylineId) {
      metaDataForFetch = polylineMetadata;
    } else if (mapsObjectId is MarkerId) {
      metaDataForFetch = markerMetadata;
    } else {
      return null;
    }

    if (metaDataForFetch.containsKey(mapsObjectId)) {
      return metaDataForFetch[mapsObjectId];
    }

    return null;
  }


}

class FeatureMetadata {
  final Map<String,String> _metadata = {};

  Map<String,String> getMetaData() => _metadata;

  FeatureMetadata updateMetadata({required String key, required String data}) {
    _metadata.update(
      key,
      (value) => data,
      ifAbsent: () => data,
    );
    return this;
  }

  String? getData(String key) => containsKey(key) ? _metadata[key] : null;

  bool containsKey(String key) => _metadata.containsKey(key);

}