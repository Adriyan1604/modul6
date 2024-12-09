import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';

class MapController extends GetxController {
  // Koordinat Toko
  final tokoLocation = const LatLng(-7.941258063937471, 112.60904721098531); // Koordinat Toko

  final Rx<Position?> currentPosition = Rx<Position?>(null);  // Menyimpan posisi pengguna
  final RxSet<Marker> markers = <Marker>{}.obs; // Marker untuk pengguna dan toko
  final RxList<LatLng> routeCoordinates = <LatLng>[].obs;
  final Rx<Polyline?> routePolyline = Rx<Polyline?>(null);

  GoogleMapController? mapController;
  final Dio _dio = Dio();

  // API Key dari Google Maps API
  static const String _googleMapsApiKey = 'AIzaSyAZ2jrE4KIgcwR9gHBB6X2rtmy4fzNe468'; // Ganti dengan API Key Anda

  // Mendapatkan Lokasi Saat Ini
  Future<void> getCurrentLocation() async {
    try {
      // Memeriksa dan meminta izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Izin lokasi ditolak');
        return;
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      // Update posisi dan marker
      currentPosition.value = position;
      _updateMarkers();

      // Ambil rute ke toko
      await _getDirectionsToToko();

      // Pindahkan kamera ke lokasi saat ini
      if (mapController != null) {
        mapController!.animateCamera(
            CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude)
            )
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi: $e');
    }
  }

  // Update Marker
  void _updateMarkers() {
    if (currentPosition.value == null) return;

    // Menambahkan Marker Lokasi Pengguna
    markers.value = {
      Marker(
        markerId: const MarkerId('userLocation'),
        position: LatLng(
            currentPosition.value!.latitude,
            currentPosition.value!.longitude
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Lokasi Anda'),
      ),

      // Menambahkan Marker Lokasi Toko (Harus selalu ada)
      Marker(
        markerId: const MarkerId('tokoLocation'),
        position: tokoLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Lokasi Toko'),
      ),
    };
  }

  // Dapatkan Rute ke Toko
  Future<void> _getDirectionsToToko() async {
    if (currentPosition.value == null) return;

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${currentPosition.value!.latitude},${currentPosition.value!.longitude}',
          'destination': '${tokoLocation.latitude},${tokoLocation.longitude}',
          'key': _googleMapsApiKey,
        },
      );

      if (response.data['routes'].isNotEmpty) {
        // Decode polyline rute
        List<LatLng> decodedRoute = _decodePolyline(
            response.data['routes'][0]['overview_polyline']['points']
        );

        routeCoordinates.value = decodedRoute;

        // Buat polyline rute
        routePolyline.value = Polyline(
          polylineId: const PolylineId('route'),
          points: routeCoordinates,
          color: Colors.blue,
          width: 5,
        );
      } else {
        Get.snackbar('Error', 'Rute tidak ditemukan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan rute: $e');
    }
  }

  // Decode Polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int result = 1;
      int shift = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result += b << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      result = 1;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result += b << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  // Fungsi untuk menghitung jarak
  double calculateDistance() {
    if (routeCoordinates.isEmpty) return 0;

    double totalDistance = 0;
    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
          routeCoordinates[i].latitude,
          routeCoordinates[i].longitude,
          routeCoordinates[i + 1].latitude,
          routeCoordinates[i + 1].longitude
      ) / 1000; // Konversi ke kilometer
    }
    return totalDistance;
  }
}
