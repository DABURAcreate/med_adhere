import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network reachability and exposes a stream of [bool] values.
///
/// true  → at least one non-none connectivity type is active
/// false → no connectivity detected
///
/// Consumers (primarily SyncService) listen to [onConnectivityChanged] and
/// trigger a sync whenever the value flips from false → true.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Emits the current connectivity state whenever it changes.
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_isConnected);

  /// Returns the current connectivity state synchronously (async check).
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
