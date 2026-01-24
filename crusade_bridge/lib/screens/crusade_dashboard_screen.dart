import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../providers/sync_provider.dart';
import '../services/sync_service.dart';
import '../widgets/army_avatar.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/sync_conflict_dialog.dart';

class CrusadeDashboardScreen extends ConsumerWidget {
  const CrusadeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);
    final syncState = ref.watch(syncNotifierProvider);
    final syncNotifier = ref.read(syncNotifierProvider.notifier);

    // Listen for sync state changes
    ref.listen<SyncState>(syncNotifierProvider, (_, state) {
      if (state.successMessage != null) {
        SnackBarUtils.showMessage(context, state.successMessage!);
        // Reset sync state after showing message
        Future.delayed(const Duration(seconds: 2), () {
          syncNotifier.reset();
        });
      } else if (state.errorMessage != null) {
        SnackBarUtils.showError(context, state.errorMessage!);
        syncNotifier.reset();
      } else if (state.conflict != null && currentCrusade != null) {
        _showConflictDialog(context, state.conflict!, ref, syncNotifier, currentCrusade);
      }
    });

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Crusade Dashboard')),
        body: const Center(child: Text('No Crusade loaded. Please select one from the home screen.')),
      );
    }

    final isSyncing = syncState.isSyncing;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCrusade.name),
        actions: [
          if (isSyncing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ArmyAvatar(
                factionAsset: currentCrusade.factionIconAsset,
                customPath: currentCrusade.armyIconPath,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Crusade Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentCrusade.faction,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  currentCrusade.detachment,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currentCrusade.totalOobPoints}/${currentCrusade.supplyLimit} pts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentCrusade.remainingPoints < 0 ? Colors.red : const Color(0xFFFFB6C1),
                      ),
                    ),
                    Text(
                      '${currentCrusade.rp} RP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFF59D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Tiles Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  // 1. Modify Order of Battle
                  _ActionTile(
                    icon: Icons.list_alt,
                    label: 'Modify OOB',
                    color: Colors.blue,
                    onTap: () => context.go('/oob'),
                  ),
                  // 2. Spend Requisition
                  _ActionTile(
                    icon: Icons.stars,
                    label: 'Requisitions',
                    color: Colors.purple,
                    onTap: () => context.go('/requisition'),
                  ),
                  // 3. Assemble Roster
                  _ActionTile(
                    icon: Icons.groups,
                    label: 'Assemble Roster',
                    color: Colors.green,
                    onTap: () {
                      SnackBarUtils.showMessage(context, 'Roster assembly coming soon');
                    },
                  ),
                  // 4. Play Game
                  _ActionTile(
                    icon: Icons.play_arrow,
                    label: 'Play Game',
                    color: Colors.orange,
                    onTap: () {
                      SnackBarUtils.showMessage(context, 'Play mode coming soon');
                    },
                  ),
                  // 5. Post-Game Update
                  _ActionTile(
                    icon: Icons.update,
                    label: 'Post-Game Update',
                    color: Colors.amber,
                    onTap: () {
                      SnackBarUtils.showMessage(context, 'Post-game updates coming soon');
                    },
                  ),
                  // 6. Resources
                  _ActionTile(
                    icon: Icons.menu_book,
                    label: 'Resources',
                    color: Colors.teal,
                    onTap: () {
                      SnackBarUtils.showMessage(context, 'Resources coming soon');
                    },
                  ),
                  // 7. Save to GDrive
                  _ActionTile(
                    icon: Icons.cloud_upload,
                    label: 'Save to Drive',
                    color: const Color(0xFFC2185B),
                    onTap: isSyncing
                        ? null
                        : () async {
                            await syncNotifier.pushCrusade(currentCrusade);
                          },
                  ),
                  // 8. Disband Crusade
                  _ActionTile(
                    icon: Icons.delete_forever,
                    label: 'Disband Crusade',
                    color: Colors.red,
                    onTap: () {
                      _showDisbandConfirmation(context, ref, currentCrusade);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: onTap != null ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showConflictDialog(
  BuildContext context,
  SyncConflict conflict,
  WidgetRef ref,
  SyncNotifier syncNotifier,
  Crusade currentCrusade,
) {
  showDialog(
    context: context,
    builder: (context) => SyncConflictDialog(
      conflict: conflict,
      onResolve: (overwrite) async {
        switch (conflict.type) {
          case ConflictType.pushingOlderLocal:
            await syncNotifier.resolvePushConflict(
              currentCrusade,
              overwriteRemote: overwrite,
            );
          case ConflictType.pullingOlderRemote:
            // For pull conflicts, this would need the remote data
            // For now, just handle the local decision
            await syncNotifier.resolvePullConflict(
              conflict.crusadeId,
              {},
              acceptRemote: overwrite,
            );
        }
      },
    ),
  );
}

void _showDisbandConfirmation(
  BuildContext context,
  WidgetRef ref,
  Crusade crusade,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Disband Crusade?'),
      content: Text(
        'Are you sure you want to disband "${crusade.name}"?\n\nThis will permanently delete all data for this crusade. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Close the dialog
            Navigator.pop(context);

            // Navigate to landing screen first
            context.go('/landing');

            // Then delete the crusade
            await ref.read(currentCrusadeNotifierProvider.notifier).deleteCrusade(crusade.id);

            // Show confirmation
            if (context.mounted) {
              SnackBarUtils.showSuccess(context, 'Crusade "${crusade.name}" has been disbanded');
            }
          },
          child: const Text('Disband', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
