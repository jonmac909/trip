import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

export 'geo_point.dart';

/// Native Apple Maps widget
class AppMapWidget extends StatelessWidget {
  const AppMapWidget({
    super.key,
    required this.locationName,
    this.latitude = 35.6762,
    this.longitude = 139.6503,
    this.zoom = 13.0,
  });

  final String locationName;
  final double latitude;
  final double longitude;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return AppleMap(
      key: ValueKey('map_$locationName'),
      mapType: MapType.standard,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: zoom,
      ),
      annotations: {
        Annotation(
          annotationId: AnnotationId('pin_$locationName'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: locationName),
        ),
      },
      myLocationEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      pitchGesturesEnabled: true,
    );
  }
}
