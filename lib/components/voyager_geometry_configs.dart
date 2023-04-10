

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


abstract class VoyagerGeometryConfig {}

class MarkerConfig extends VoyagerGeometryConfig{
  final Completer<BitmapDescriptor> icon = Completer<BitmapDescriptor>();
  InfoWindow infoWindow;
  final Offset anchor;

  MarkerConfig({
    required String imgPath,
    this.anchor = const Offset(0,0),
    this.infoWindow = InfoWindow.noText,
  }) {
    icon.complete(BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: window.devicePixelRatio,
      ),
      imgPath,
    ));
  }

  Future<void> updateConfigs({
    String? imgPath,
    InfoWindow? infoWindow,
  }) async {
    if (imgPath != null) {
      icon.complete(BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: window.devicePixelRatio,
        ),
        imgPath,
      ));
    }
    this.infoWindow = infoWindow ?? this.infoWindow;
  }

}

class PolygonConfig extends VoyagerGeometryConfig {
  Color fillColor;
  Color strokeColor;
  int strokeWidth;

  PolygonConfig({
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 2,
  });

  void updateConfigs({
    Color? fillColor,
    Color? strokeColor,
    int? strokeWidth,
  }) {
    this.fillColor = fillColor ?? this.fillColor;
    this.strokeColor = strokeColor ?? this.strokeColor;
    this.strokeWidth = strokeWidth ?? this.strokeWidth;
  }
}

class PolylineConfig extends VoyagerGeometryConfig {
  List<PatternItem> patterns;
  int width;
  Color color;

  PolylineConfig({
    required this.color,
    this.width = 5,
    this.patterns = const <PatternItem>[],
  });

  void updateConfigs({
    List<PatternItem>? patterns,
    int? width,
    Color? color,
  }) {
    this.patterns = patterns ?? this.patterns;
    this.width = width ?? this.width;
    this.color = color ?? this.color;
  }
}

