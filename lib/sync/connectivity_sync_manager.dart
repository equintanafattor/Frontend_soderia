import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_service.dart';

class ConnectivitySyncManager {
  final SyncService syncService;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivitySyncManager(this.syncService);

  void start() {
    _sub = Connectivity().onConnectivityChanged.listen((results) async {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        await syncService.syncPendientes();
      }
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}