import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crusade_models.dart';
import '../services/sync_service.dart';

/// Provider for tracking sync state
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier() : super(const SyncState.idle());

  /// Push the current crusade to Google Drive
  Future<void> pushCrusade(Crusade crusade) async {
    state = const SyncState.syncing();

    final result = await SyncService.pushCrusade(crusade);

    if (result.conflict != null) {
      state = SyncState.conflict(result.conflict!);
    } else if (result.success) {
      state = const SyncState.success('Crusade pushed successfully');
    } else {
      state = SyncState.error(result.message ?? 'Failed to push crusade');
    }
  }

  /// Push all crusades to Google Drive
  Future<void> pushAllCrusades(List<Crusade> crusades) async {
    state = const SyncState.syncing();

    final conflicts = await SyncService.pushAllCrusades();

    if (conflicts.isNotEmpty) {
      state = SyncState.multiConflict(conflicts);
    } else {
      state = const SyncState.success('All crusades pushed successfully');
    }
  }

  /// Pull a crusade from Google Drive
  Future<void> pullCrusade(
    String crusadeId,
    Map<String, dynamic> remoteData,
  ) async {
    state = const SyncState.syncing();

    final result = await SyncService.pullCrusade(crusadeId, remoteData);

    if (result.conflict != null) {
      state = SyncState.conflict(result.conflict!);
    } else if (result.success) {
      state = const SyncState.success('Crusade pulled successfully');
    } else {
      state = SyncState.error(result.message ?? 'Failed to pull crusade');
    }
  }

  /// Resolve a conflict by either overwriting or keeping local
  Future<void> resolvePushConflict(
    Crusade crusade, {
    required bool overwriteRemote,
  }) async {
    state = const SyncState.syncing();

    final success = await SyncService.resolvePushConflict(
      crusade,
      overwriteRemote: overwriteRemote,
    );

    if (success) {
      state = SyncState.success(
        overwriteRemote ? 'Crusade overwritten on Drive' : 'Local version kept',
      );
    } else {
      state = const SyncState.error('Failed to resolve conflict');
    }
  }

  /// Resolve a pull conflict by either accepting remote or keeping local
  Future<void> resolvePullConflict(
    String crusadeId,
    Map<String, dynamic> remoteData, {
    required bool acceptRemote,
  }) async {
    state = const SyncState.syncing();

    final success = await SyncService.resolvePullConflict(
      crusadeId,
      remoteData,
      acceptRemote: acceptRemote,
    );

    if (success) {
      state = SyncState.success(
        acceptRemote ? 'Remote version loaded' : 'Local version kept',
      );
    } else {
      state = const SyncState.error('Failed to resolve conflict');
    }
  }

  /// Reset to idle state
  void reset() {
    state = const SyncState.idle();
  }
}

final syncNotifierProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) => SyncNotifier(),
);

/// State for sync operations
abstract class SyncState {
  const SyncState();

  const factory SyncState.idle() = _Idle;
  const factory SyncState.syncing() = _Syncing;
  const factory SyncState.success(String message) = _Success;
  const factory SyncState.error(String message) = _Error;
  const factory SyncState.conflict(SyncConflict conflict) = _Conflict;
  const factory SyncState.multiConflict(List<SyncConflict> conflicts) = _MultiConflict;

  bool get isIdle => this is _Idle;
  bool get isSyncing => this is _Syncing;
  String? get successMessage => this is _Success ? (this as _Success).message : null;
  String? get errorMessage => this is _Error ? (this as _Error).message : null;
  SyncConflict? get conflict => this is _Conflict ? (this as _Conflict).conflict : null;
  List<SyncConflict>? get multiConflict => this is _MultiConflict ? (this as _MultiConflict).conflicts : null;
}

class _Idle extends SyncState {
  const _Idle();
}

class _Syncing extends SyncState {
  const _Syncing();
}

class _Success extends SyncState {
  final String message;
  const _Success(this.message);
}

class _Error extends SyncState {
  final String message;
  const _Error(this.message);
}

class _Conflict extends SyncState {
  final SyncConflict conflict;
  const _Conflict(this.conflict);
}

class _MultiConflict extends SyncState {
  final List<SyncConflict> conflicts;
  const _MultiConflict(this.conflicts);
}
