import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _hasInternet = true;

  bool get hasInternet => _hasInternet;

  ConnectivityProvider() {
    checkInternet();
    Connectivity().onConnectivityChanged.listen((results) {
      _hasInternet = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
  }

  Future<void> checkInternet() async {
    final results = await Connectivity().checkConnectivity();
    _hasInternet = results.any((r) => r != ConnectivityResult.none);
    notifyListeners();
  }
}
