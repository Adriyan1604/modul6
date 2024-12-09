import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/map_controller.dart';

class MapView extends GetView<MapController> {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Toko'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => controller.getCurrentLocation(),
          )
        ],
      ),
      body: Stack(
        children: [
          // Peta Google
          Obx(() => GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.tokoLocation,
              zoom: 14,
            ),
            markers: controller.markers.toSet(),
            polylines: controller.routePolyline.value != null
                ? {controller.routePolyline.value!}
                : {},
            myLocationEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController mapController) {
              controller.mapController = mapController;
            },
          )),

          // Informasi Jarak dan Koordinat Pengguna
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Obx(() {
              // Cek jika ada koordinat yang terdeteksi
              if (controller.currentPosition.value != null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jarak ke Toko: ${controller.calculateDistance().toStringAsFixed(2)} km',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        // Menampilkan koordinat lintang dan bujur pengguna
                        Text(
                          'Koordinat Anda: '
                              '${controller.currentPosition.value!.latitude.toStringAsFixed(4)}, '
                              '${controller.currentPosition.value!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.getCurrentLocation(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
