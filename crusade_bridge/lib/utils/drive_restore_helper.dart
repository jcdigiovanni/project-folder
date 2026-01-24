import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/google_drive_service.dart';
import '../services/storage_service.dart';
import '../providers/crusade_provider.dart';
import '../providers/app_settings_provider.dart';
import 'snackbar_utils.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// Helper class for Google Drive restore operations.
/// Provides shared functionality for restoring crusades from Google Drive
/// that can be used across different screens (landing page, settings, etc.)
class DriveRestoreHelper {
  /// Shows a restore dialog and handles the complete restore flow.
  ///
  /// [context] - BuildContext for showing dialogs and snackbars
  /// [ref] - WidgetRef for accessing providers
  /// [useBottomSheet] - If true, uses ModalBottomSheet; if false, uses AlertDialog
  /// [onRestoreComplete] - Optional callback when restore completes successfully
  static Future<void> showRestoreDialog({
    required BuildContext context,
    required WidgetRef ref,
    bool useBottomSheet = false,
    VoidCallback? onRestoreComplete,
  }) async {
    // Check if user is signed in
    if (!GoogleDriveService.isSignedIn) {
      SnackBarUtils.showError(
        context,
        'Please sign in to Google Drive first',
      );
      return;
    }

    try {
      // Fetch backup files
      final backupFiles = await GoogleDriveService.getBackupFiles();

      if (!context.mounted) return;

      if (backupFiles.isEmpty) {
        final settings = ref.read(appSettingsProvider);
        SnackBarUtils.showMessage(
          context,
          'No backup files found',
          settings: settings,
          icon: Icons.info,
        );
        return;
      }

      // Show appropriate dialog based on preference
      if (useBottomSheet) {
        await _showBottomSheetDialog(
          context,
          ref,
          backupFiles,
          onRestoreComplete,
        );
      } else {
        await _showAlertDialog(
          context,
          ref,
          backupFiles,
          onRestoreComplete,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final settings = ref.read(appSettingsProvider);
      SnackBarUtils.showError(
        context,
        'Error fetching backups: $e',
        settings: settings,
      );
    }
  }

  /// Shows backup files in an AlertDialog
  static Future<void> _showAlertDialog(
    BuildContext context,
    WidgetRef ref,
    List<drive.File> files,
    VoidCallback? onRestoreComplete,
  ) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Crusade'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final modifiedTime = file.modifiedTime ?? DateTime.now();
              final description = file.description ?? '';
              final crusadeCount = file.properties?['crusadeCount'];
              final crusadeNames = file.properties?['crusadeNames'] ?? '';

              // Build subtitle based on available metadata
              String subtitle;
              if (description.isNotEmpty) {
                subtitle = '$description\n${_formatDateTime(modifiedTime)}';
              } else if (crusadeNames.isNotEmpty) {
                subtitle = '$crusadeNames\n${_formatDateTime(modifiedTime)}';
              } else {
                subtitle = _formatDateTime(modifiedTime);
              }

              return ListTile(
                leading: Icon(
                  crusadeCount != null && int.tryParse(crusadeCount) != null && int.parse(crusadeCount) > 1
                      ? Icons.folder_special
                      : Icons.backup,
                  color: Colors.blue,
                ),
                title: Text(
                  file.name ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                isThreeLine: description.isNotEmpty || crusadeNames.isNotEmpty,
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await performRestore(
                    context: context,
                    ref: ref,
                    fileId: file.id!,
                    onRestoreComplete: onRestoreComplete,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Shows backup files in a ModalBottomSheet
  static Future<void> _showBottomSheetDialog(
    BuildContext context,
    WidgetRef ref,
    List<drive.File> files,
    VoidCallback? onRestoreComplete,
  ) async {
    return showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Backup to Restore',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final modifiedTime = file.modifiedTime ?? DateTime.now();
                    final description = file.description ?? '';
                    final crusadeCount = file.properties?['crusadeCount'];
                    final crusadeNames = file.properties?['crusadeNames'] ?? '';

                    // Build subtitle based on available metadata
                    String subtitle;
                    if (description.isNotEmpty) {
                      subtitle = '$description\n${_formatDateTime(modifiedTime)}';
                    } else if (crusadeNames.isNotEmpty) {
                      subtitle = '$crusadeNames\n${_formatDateTime(modifiedTime)}';
                    } else {
                      subtitle = _formatDateTime(modifiedTime);
                    }

                    return ListTile(
                      leading: Icon(
                        crusadeCount != null && int.tryParse(crusadeCount) != null && int.parse(crusadeCount) > 1
                            ? Icons.folder_special
                            : Icons.backup,
                        color: Colors.blue,
                      ),
                      title: Text(
                        file.name ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      isThreeLine: description.isNotEmpty || crusadeNames.isNotEmpty,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await performRestore(
                          context: context,
                          ref: ref,
                          fileId: file.id!,
                          onRestoreComplete: onRestoreComplete,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Performs the actual restore operation.
  ///
  /// Downloads the backup from Google Drive, deserializes all crusades,
  /// saves to local storage, and shows success/error messages.
  static Future<void> performRestore({
    required BuildContext context,
    required WidgetRef ref,
    required String fileId,
    VoidCallback? onRestoreComplete,
  }) async {
    try {
      // Use the existing restoreFromBackup method which handles the backup format
      // The backup format is: { "version": "1.0", "timestamp": "...", "crusades": [...] }
      final success = await GoogleDriveService.restoreFromBackup(fileId);

      if (!context.mounted) return;

      final settings = ref.read(appSettingsProvider);

      if (!success) {
        SnackBarUtils.showError(
          context,
          'Failed to restore crusades from backup. The backup file may be empty or corrupted.',
          settings: settings,
        );
        return;
      }

      // Load all crusades and set the first one as current (if any)
      final crusades = StorageService.loadAllCrusades();
      if (crusades.isNotEmpty) {
        ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusades.first);
      }

      if (!context.mounted) return;

      SnackBarUtils.showSuccess(
        context,
        'Restored ${crusades.length} crusade(s) from backup',
        settings: settings,
      );

      // Call completion callback if provided
      onRestoreComplete?.call();
    } catch (e, stackTrace) {
      if (!context.mounted) return;
      final settings = ref.read(appSettingsProvider);
      print('Error restoring crusades: $e');
      print('Stack trace: $stackTrace');
      SnackBarUtils.showError(
        context,
        'Error restoring crusades: ${e.toString().split('\n').first}',
        settings: settings,
      );
    }
  }

  /// Formats a DateTime to a readable string
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
