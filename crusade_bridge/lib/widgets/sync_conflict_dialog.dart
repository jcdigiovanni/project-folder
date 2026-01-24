import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncConflictDialog extends StatelessWidget {
  final SyncConflict conflict;
  final Function(bool) onResolve;

  const SyncConflictDialog({
    super.key,
    required this.conflict,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final localTime = conflict.localModified;
    final remoteTime = conflict.remoteModified;

    String getTitle() {
      switch (conflict.type) {
        case ConflictType.pushingOlderLocal:
          return 'Local version is older';
        case ConflictType.pullingOlderRemote:
          return 'Remote version is older';
      }
    }

    String getDescription() {
      switch (conflict.type) {
        case ConflictType.pushingOlderLocal:
          return 'You\'re trying to push "${conflict.crusadeName}" to Drive, but a newer version already exists there. Overwrite it?';
        case ConflictType.pullingOlderRemote:
          return 'You\'re pulling an older version of "${conflict.crusadeName}" from Drive. Your local version is newer. Replace it?';
      }
    }

    String getKeepButtonLabel() {
      switch (conflict.type) {
        case ConflictType.pushingOlderLocal:
          return 'Keep Remote';
        case ConflictType.pullingOlderRemote:
          return 'Keep Local';
      }
    }

    String getOverwriteButtonLabel() {
      switch (conflict.type) {
        case ConflictType.pushingOlderLocal:
          return 'Overwrite Remote';
        case ConflictType.pullingOlderRemote:
          return 'Replace Local';
      }
    }

    return AlertDialog(
      title: Text(getTitle()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getDescription()),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local: ${_formatDateTime(localTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remote: ${_formatDateTime(remoteTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onResolve(false);
          },
          child: Text(getKeepButtonLabel()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onResolve(true);
          },
          child: Text(getOverwriteButtonLabel()),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
