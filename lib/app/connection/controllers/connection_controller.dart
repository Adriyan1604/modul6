import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../../modules/home/home_page/views/home_page_view.dart';
import '../views/no_connection_view.dart';

class ConnectionController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();

    // Mendengarkan perubahan koneksi
    _connectivity.onConnectivityChanged.listen((connectivityResults) {
      // Jika connectivityResults adalah List<ConnectivityResult>, kita ambil hasil pertama
      if (connectivityResults.isNotEmpty) {
        _updateConnectionStatus(connectivityResults.first);
      }
    });
  }

  // Fungsi untuk mengupdate status koneksi
  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    // Jika tidak ada koneksi
    if (connectivityResult == ConnectivityResult.none) {
      // Pindah ke tampilan NoConnectionView
      if (Get.currentRoute != '/NoConnectionView') {
        Get.offAll(() => const NoConnectionView());
      }
    } else {
      // Jika aplikasi terhubung dengan Wi-Fi atau mobile data
      // Pindah ke HomeView jika sebelumnya di NoConnectionView
      if (Get.currentRoute == '/NoConnectionView') {
        Get.offAll(() => const HomePageView());
      }
    }
  }
}
