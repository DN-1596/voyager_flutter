//
//
//
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter_platform_interface/src/types/camera.dart';
// import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
// import 'package:voyager_flutter/models/voyager_map_controller.dart';
// import 'package:voyager_flutter/protocols/protocol.dart';
// import 'package:voyager_flutter/utils/index.dart';
//
// class PolygonCreationProtocol extends VoyagerProtocol {
//   PolygonCreationProtocol({
//     required MapController mapController,
//   }) : super(mapController: mapController);
//
//   // polyline to be rendered corresponding to the edit polygon
//   Polyline? editPolyline;
//
//   /// cases being handled using [mapTapToEditPolygon],
//   /// 1. if [editPolyline] is not null then either a point will be inserted or added
//   /// depending on tap location [tapLoc]
//   /// 2. if [editPolyline] is null then if the user taps on any of the polygon it will be made
//   /// editable
//   @override
//   void onSingleTap(LatLng tapLoc) {
//     String? _tappedPolygonId;
//     for (Polygon _polygon in mapController.getGoogleFeatureSet().polygons) {
//       if (MathUtil.isPointInPolygon(tapLoc, _polygon.points , true)) {
//         _tappedPolygonId = _polygon.polygonId.value;
//         break;
//       }
//     }
//     if (editPolyline!=null) {
//       List<LatLng> polylinePts = editPolyline!.points;
//       String pId = editPolyline!.polylineId.value;
//       int idx = MathUtil.locationIndexOnEdgeOrPath(tapLoc, polylinePts);
//       if (idx >= 0) {
//         polylinePts.insert(idx + 1, tapLoc);
//       } else {
//         if (_tappedPolygonId != null) {
//           onPolygonTap(_tappedPolygonId);
//           return;
//         }
//         if (polylinePts.length>1 && polylinePts.first == polylinePts.last)
//           polylinePts.removeLast();
//         polylinePts.add(tapLoc);
//       }
//       ensureLinearRing(polylinePts);
//       if (polylinePts.isNotEmpty) {
//         mapBloc.currentPolygonMap.update(
//           pId,
//               (value) => value.copyWith(pointsParam: polylinePts),
//         );
//         generateEditPolyline(pId);
//       }
//     } else if (_tappedPolygonId != null) {
//       onPolygonTap(_tappedPolygonId);
//       return;
//     }
//   }
//
//   @override
//   void onCameraMove(CameraPosition cameraPosition) {
//     // TODO: implement onCameraMove
//   }
//
//   @override
//   void onLongPress(LatLng latLng) {
//     // TODO: implement onLongPress
//   }
//
//   onPolygonTap(String pId) {
//
//     if (!(mapBloc.selectedPolygonIdSet.contains(pId) || !pId.contains(kService))) {
//       return;
//     }
//
//     if (!mapBloc.selectedPolygonIdSet.contains(pId)) {
//       mapBloc.selectedPolygonIdSet.add(pId);
//       if (!pId.contains(kManually)) {
//         mapBloc.mapEvents?.suggestionSelected(id: pId);
//       }
//     }
//
//     if (editPolyline == null) {
//       generateEditPolyline(pId);
//     } else  {
//       String idUnderEdit = editPolyline!.polylineId.value;
//       // removing edit polygon for the existing one
//       clearEditVariable();
//
//       if (idUnderEdit != pId) {
//         // adding edit for this polygon
//         generateEditPolyline(pId);
//       } else {
//         mapBloc.emit(UpdateConfig(mapBloc.mapConfig));
//       }
//     }
//   }
//
// }