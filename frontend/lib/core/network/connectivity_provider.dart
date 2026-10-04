
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';

// CONNECTIVITY SERVICE PROVIDER
final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// CONNECTIVITY STATUS PROVIDER
final connectivityStatusProvider =
    StreamProvider<List<ConnectivityResult>>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);

  // Emit the initial connectivity status.
  yield await service.checkConnectivity();

  // Listen for subsequent connectivity changes.
  yield* service.onConnectivityChanged;
});

// CHECK WHETHER A NETWORK TRANSPORT IS AVAILABLE
bool hasNetworkConnection(List<ConnectivityResult> results) {
  return results.any(
    (result) => result != ConnectivityResult.none,
  );
}