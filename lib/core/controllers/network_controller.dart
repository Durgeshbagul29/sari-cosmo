import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/widgets/no_internet_screen.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isOfflineScreenShown = false;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> initConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      Get.log("Couldn't check connectivity status: $e");
      return;
    }
    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    bool hasConnection = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasConnection) {
      if (!_isOfflineScreenShown) {
        _isOfflineScreenShown = true;
        // Show the offline screen without allowing it to be dismissed manually
        Get.to(() => const NoInternetScreen(), preventDuplicates: true);
      }
    } else {
      if (_isOfflineScreenShown) {
        _isOfflineScreenShown = false;
        // If we are on the NoInternetScreen, pop it.
        if (Get.currentRoute.contains('NoInternetScreen') ||
            Get.isDialogOpen == true) {
          Get.back();
        } else {
          // Fallback in case route name is not exactly matching but screen is active
          Get.until((route) =>
              route.isFirst || route.settings.name != 'NoInternetScreen');
        }
      }
    }
  }

  void checkConnectivity() {
    initConnectivity();
  }
}
