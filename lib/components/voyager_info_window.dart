


import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voyager_flutter/models/index.dart';
import 'package:voyager_flutter/protocols/voyager_marker_protocol.dart';


class VoyagerInfoWindow {
  final LatLng latLng;
  final Widget widget;
  final Size size;

  const VoyagerInfoWindow({
    required this.widget,
    required this.latLng,
    required this.size,
  });
}

class VoyagerInfoWindowView extends StatefulWidget {

  final VoyagerMapController voyagerMapController;

  const VoyagerInfoWindowView({
    Key? key,
    required this.voyagerMapController,
  }) : super(key: key);

  @override
  State<VoyagerInfoWindowView> createState() => _VoyagerInfoWindowViewState();
}

class _VoyagerInfoWindowViewState extends State<VoyagerInfoWindowView> {


  late double devicePixelRatio;
  double _leftMargin = 0;
  double _topMargin = 0;
  VoyagerInfoWindow? voyagerInfoWindow;


  @override
  void initState() {
    widget.voyagerMapController.addProtocol(
      VoyagerMarkerProtocol(
        mapController: widget.voyagerMapController,
        updateInfoWindow: _updateInfoWindow,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    widget.voyagerMapController.getInfoWindowMarkerNotifier().removeListener(_updateInfoWindow);
    widget.voyagerMapController.removeProtocol<VoyagerMarkerProtocol>();
    super.dispose();
  }

  void _updateInfoWindow() async {
    VoyagerInfoWindow? infoWindow = widget.voyagerMapController.getInfoWindowMarkerNotifier().value;
    if (infoWindow == null) {
      setState(() {
        voyagerInfoWindow = infoWindow;
      });
      return;
    }

    try {
      await widget.voyagerMapController.getIsMapReady();
      ScreenCoordinate screenCoordinate = await widget.voyagerMapController.googleMapController
          .getScreenCoordinate(infoWindow.latLng);
      double devicePixelRatio =
      Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
      double left = screenCoordinate.x.toDouble() / devicePixelRatio -  infoWindow.size.width/2;
      double top = screenCoordinate.y.toDouble() / devicePixelRatio - infoWindow.size.height;
      setState(() {
        voyagerInfoWindow = infoWindow;
        _leftMargin = left;
        _topMargin = top;
      });
    } catch(e) {
      log("NO MARKER FOUND - $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    if (voyagerInfoWindow == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _leftMargin,
      top: _topMargin,
      child:  SizedBox(
        child: voyagerInfoWindow!.widget,
        height: voyagerInfoWindow!.size.height,
        width: voyagerInfoWindow!.size.width,
      ),
    );
  }
}
