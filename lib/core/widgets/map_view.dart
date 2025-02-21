import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/station.dart';
import '../../app/routes.dart';

class MapView extends StatefulWidget {
  final Position? initialPosition;
  final bool isPreview;
  final Function(Station)? onStationSelected;
  final List<Station>? stations;

  const MapView({
    super.key,
    this.initialPosition,
    this.isPreview = false,
    this.onStationSelected,
    this.stations,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  NaverMapController? _mapController;
  Set<NMarker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: widget.initialPosition != null
                  ? NLatLng(
                      widget.initialPosition!.latitude,
                      widget.initialPosition!.longitude,
                    )
                  : const NLatLng(
                      37.5665, 126.9780), // Default: Seoul City Hall
              zoom: 15,
            ),
            contentPadding: const EdgeInsets.all(0),
          ),
          onMapReady: (controller) async {
            _mapController = controller;

            // Show current location overlay
            if (widget.initialPosition != null) {
              final locationOverlay = await controller.getLocationOverlay();
              locationOverlay.setPosition(
                NLatLng(
                  widget.initialPosition!.latitude,
                  widget.initialPosition!.longitude,
                ),
              );
              locationOverlay.setIsVisible(true);
            }

            // 지도가 완전히 로드된 후 마커 추가
            await Future.delayed(const Duration(milliseconds: 500));
            if (widget.stations != null) {
              _addStationMarkers();
            }
          },
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed(Routes.map);
          },
          child: Container(
            color:
                Colors.transparent, // Transparent overlay to block interactions
          ),
        ),
      ],
    );
  }

  void _addStationMarkers() async {
    if (widget.stations == null) return;

    final markerIcon = await NOverlayImage.fromAssetImage(
      'assets/images/honey.png',
    );

    for (final station in widget.stations!) {
      final marker = NMarker(
        id: station.id.toString(),
        position: NLatLng(
          station.latitude,
          station.longitude,
        ),
        icon: markerIcon,
        size: const Size(48, 48),
        anchor: const NPoint(0.5, 0.5),
      );

      marker.setOnTapListener((marker) {
        if (widget.onStationSelected != null) {
          final selectedStation = widget.stations!.firstWhere(
            (s) => s.id == marker.info.id,
          );
          widget.onStationSelected!(selectedStation);
        }
      });

      _markers.add(marker);
    }

    _mapController?.addOverlayAll(_markers);
  }
}
