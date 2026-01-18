import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to check network connectivity
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  static Future<bool> hasConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      // Double check with actual internet access
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Check connectivity with a timeout
  static Future<bool> hasConnectionWithTimeout({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      // Double check with actual internet access
      final result = await InternetAddress.lookup('google.com').timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
