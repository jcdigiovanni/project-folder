import '../models/crusade_models.dart';
import 'google_drive_service.dart';
import 'storage_service.dart';

/// Result of a sync operation with optional conflict
class SyncResult {
  final bool success;
  final String? message;
  final SyncConflict? conflict;

  SyncResult({
    required this.success,
    this.message,
    this.conflict,
  });
}

/// Represents a sync conflict requiring user intervention
class SyncConflict {
  final String crusadeId;
  final String crusadeName;
  final DateTime localModified;
  final DateTime remoteModified;
  final ConflictType type;

  SyncConflict({
    required this.crusadeId,
    required this.crusadeName,
    required this.localModified,
    required this.remoteModified,
    required this.type,
  });

  /// Returns whether the local version is newer
  bool get isLocalNewer => localModified.isAfter(remoteModified);

  /// Returns whether the remote version is newer
  bool get isRemoteNewer => remoteModified.isAfter(localModified);
}

/// Type of conflict
enum ConflictType {
  pushingOlderLocal, // Attempting to push a local file older than remote
  pullingOlderRemote, // Attempting to pull a remote file older than local
}

/// Service for bidirectional sync with smart conflict resolution
class SyncService {
  /// Push a single crusade to Google Drive
  /// Returns SyncResult with conflict if one exists that requires user confirmation
  static Future<SyncResult> pushCrusade(Crusade crusade) async {
    if (!GoogleDriveService.isSignedIn) {
      return SyncResult(
        success: false,
        message: 'Not signed in to Google Drive',
      );
    }

    try {
      // Check if crusade exists on Drive and get its modification time
      final remoteModified = await _getRemoteModificationTime(crusade.id);

      if (remoteModified != null) {
        final localModified = DateTime.fromMillisecondsSinceEpoch(crusade.lastModified);

        // Local is older than remote - prompt user
        if (localModified.isBefore(remoteModified)) {
          return SyncResult(
            success: false,
            message: 'Conflict detected when pushing crusade',
            conflict: SyncConflict(
              crusadeId: crusade.id,
              crusadeName: crusade.name,
              localModified: localModified,
              remoteModified: remoteModified,
              type: ConflictType.pushingOlderLocal,
            ),
          );
        }
        // Local is newer or equal - proceed without confirmation
      }

      // Update lastModified to current time before uploading
      crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
      
      // Upload to Drive
      final success = await GoogleDriveService.uploadCrusade(crusade);

      return SyncResult(
        success: success,
        message: success ? 'Crusade pushed to Drive' : 'Failed to push crusade',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error pushing crusade: $e',
      );
    }
  }

  /// Pull a crusade from Google Drive
  /// Returns SyncResult with conflict if one exists that requires user confirmation
  static Future<SyncResult> pullCrusade(
    String crusadeId,
    Map<String, dynamic> remoteData,
  ) async {
    try {
      final remoteModified = DateTime.fromMillisecondsSinceEpoch(
        remoteData['lastModified'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      );

      // Check if crusade exists locally
      final localCrusade = StorageService.loadCrusade(crusadeId);

      if (localCrusade != null) {
        final localModified = DateTime.fromMillisecondsSinceEpoch(localCrusade.lastModified);

        // Remote is older than local - prompt user
        if (remoteModified.isBefore(localModified)) {
          return SyncResult(
            success: false,
            message: 'Conflict detected when pulling crusade',
            conflict: SyncConflict(
              crusadeId: crusadeId,
              crusadeName: localCrusade.name,
              localModified: localModified,
              remoteModified: remoteModified,
              type: ConflictType.pullingOlderRemote,
            ),
          );
        }
        // Remote is newer or equal - proceed without confirmation
      }

      // Load and save the remote crusade
      final remoteCrusade = Crusade.fromJson(remoteData);
      await StorageService.saveCrusade(remoteCrusade);

      return SyncResult(
        success: true,
        message: 'Crusade pulled from Drive',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Error pulling crusade: $e',
      );
    }
  }

  /// Push all local crusades to Google Drive
  /// Returns list of conflicts that need user confirmation
  static Future<List<SyncConflict>> pushAllCrusades() async {
    if (!GoogleDriveService.isSignedIn) {
      return [];
    }

    final crusades = StorageService.loadAllCrusades();
    final conflicts = <SyncConflict>[];

    for (final crusade in crusades) {
      final result = await pushCrusade(crusade);
      if (result.conflict != null) {
        conflicts.add(result.conflict!);
      }
    }

    return conflicts;
  }

  /// Resolve a push conflict by either overwriting remote or keeping local
  static Future<bool> resolvePushConflict(
    Crusade crusade, {
    required bool overwriteRemote,
  }) async {
    if (!overwriteRemote) {
      // User chose to keep local unchanged, just return
      return true;
    }

    // Update timestamp and push
    crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
    return await GoogleDriveService.uploadCrusade(crusade);
  }

  /// Resolve a pull conflict by either accepting remote or keeping local
  static Future<bool> resolvePullConflict(
    String crusadeId,
    Map<String, dynamic> remoteData, {
    required bool acceptRemote,
  }) async {
    if (!acceptRemote) {
      // User chose to keep local, no action needed
      return true;
    }

    // Load and save the remote version
    final remoteCrusade = Crusade.fromJson(remoteData);
    await StorageService.saveCrusade(remoteCrusade);
    return true;
  }

  /// Get remote modification time for a crusade
  static Future<DateTime?> _getRemoteModificationTime(String crusadeId) async {
    try {
      final backupFiles = await GoogleDriveService.getBackupFiles();
      
      // For now, we'll check the latest backup file
      // In a more sophisticated system, you'd store metadata separately
      if (backupFiles.isNotEmpty) {
        final latestFile = backupFiles.first;
        if (latestFile.modifiedTime != null) {
          return latestFile.modifiedTime;
        }
      }
      return null;
    } catch (e) {
      print('Error getting remote modification time: $e');
      return null;
    }
  }
}
