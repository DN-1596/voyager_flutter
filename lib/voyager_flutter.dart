library voyager_flutter;

import 'package:flutter/material.dart';
import 'package:voyager_flutter/components/voyager_info_window.dart';
import 'package:voyager_flutter/maps_base_view.dart';
import 'package:voyager_flutter/models/voyager_map_controller.dart';
export 'package:google_maps_flutter/google_maps_flutter.dart';
export 'package:voyager_flutter/models/index.dart';
export 'package:voyager_flutter/components/index.dart';
export 'package:voyager_flutter/data_processor/algorithm/index.dart';
export 'package:voyager_flutter/data_processor/voyager_data_processor/index.dart';
export 'package:voyager_flutter/protocols/index.dart';

class VoyagerMapView extends StatefulWidget {

  final Size mapSize;
  final VoyagerMapController voyagerMapController;
  final Function(BuildContext context)? canvasBuilder;
  final Key mapsKey;

  const VoyagerMapView({
    super.key,
    required this.mapsKey,
    required this.mapSize,
    required this.voyagerMapController,
    this.canvasBuilder
  });

  @override
  State<VoyagerMapView> createState() => _VoyagerMapViewState();
}

class _VoyagerMapViewState extends State<VoyagerMapView> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.mapSize.height,
      width: widget.mapSize.width,
      child: Stack(
        children: [
          MapsBaseView(
            mapController: widget.voyagerMapController,
            mapsKey: widget.mapsKey,
          ),
          VoyagerInfoWindowView(
            voyagerMapController: widget.voyagerMapController,
          ),
          if (widget.canvasBuilder!=null)
           widget.canvasBuilder!(context)
        ],
      ),
    );
  }


}
