import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../api/yandex_geocoder.dart';

class AddressMapPicker extends StatefulWidget {
  const AddressMapPicker({
    super.key,
    required this.addressController,
    required this.languageCode,
  });

  final TextEditingController addressController;
  final String languageCode;

  @override
  State<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker> {
  static const _initialPoint = Point(latitude: 41.311081, longitude: 69.240562);
  final YandexGeocoder _geocoder = const YandexGeocoder();
  YandexMapController? _controller;
  Timer? _debounce;
  bool _userLayerEnabled = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.map_outlined,
          color: Color(0x66000000),
          size: 36,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) async {
              _controller = controller;
              await _controller!.moveCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(target: _initialPoint, zoom: 15),
                ),
              );
              await _enableUserLayer();
              _scheduleReverseGeocode(_initialPoint);
            },
            onCameraPositionChanged: (cameraPosition, _, isFinished) {
              if (isFinished) {
                _scheduleReverseGeocode(cameraPosition.target);
              }
            },
            mapObjects: const [],
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _centerOnUser,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.my_location,
                    size: 20,
                    color: Color(0xFFB38C4A),
                  ),
                ),
              ),
            ),
          ),
          const IgnorePointer(
            child: Center(
              child: Icon(
                Icons.place,
                size: 36,
                color: Color(0xFFB38C4A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleReverseGeocode(Point point) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final lang = widget.languageCode.toLowerCase() == 'uz'
          ? 'uz_UZ'
          : 'ru_RU';
      final text = await _geocoder.reverseGeocode(
        latitude: point.latitude,
        longitude: point.longitude,
        language: lang,
      );
      if (!mounted || text == null) return;
      widget.addressController.text = text;
      widget.addressController.selection = TextSelection.collapsed(
        offset: text.length,
      );
    });
  }

  Future<void> _enableUserLayer() async {
    if (_controller == null || _userLayerEnabled) return;
    final allowed = await _ensureLocationPermission();
    if (!allowed) return;
    _userLayerEnabled = true;
    try {
      await _controller!.toggleUserLayer(
        visible: true,
        headingEnabled: true,
        autoZoomEnabled: false,
      );
    } catch (_) {}
  }

  Future<void> _centerOnUser() async {
    if (_controller == null) return;
    await _enableUserLayer();
    try {
      final position = await _controller!.getUserCameraPosition();
      if (position == null) return;
      await _controller!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position.target, zoom: 16),
        ),
      );
    } catch (_) {}
  }

  Future<bool> _ensureLocationPermission() async {
    if (kIsWeb) return false;
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;
    final result = await Permission.locationWhenInUse.request();
    return result.isGranted;
  }
}
