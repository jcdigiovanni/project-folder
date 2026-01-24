import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../widgets/army_avatar.dart';
import '../utils/snackbar_utils.dart';

class RosterListScreen extends ConsumerWidget {
  const RosterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rosters')),
        body: const Center(child: Text('No Crusade loaded. Please select one from the home screen.')),
      );
    }

    final rosters = currentCrusade.rosters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rosters'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ArmyAvatar(
              factionAsset: currentCrusade.factionIconAsset,
              customPath: currentCrusade.armyIconPath,
            ),
          ),
        ],
      ),
      body: rosters.isEmpty
          ? _buildEmptyState(context, ref, currentCrusade)
          : _buildRosterList(context, ref, currentCrusade, rosters),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRosterDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Roster'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, Crusade crusade) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Rosters Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a roster to assemble your forces from ${crusade.oob.length} available units',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateRosterDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Create First Roster'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterList(
    BuildContext context,
    WidgetRef ref,
    Crusade crusade,
    List<Roster> rosters,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rosters.length,
      itemBuilder: (context, index) {
        final roster = rosters[index];
        return _RosterCard(
          roster: roster,
          oob: crusade.oob,
          onTap: () => context.go('/roster/${roster.id}'),
          onEdit: () => context.go('/roster/${roster.id}/edit'),
          onDelete: () => _confirmDeleteRoster(context, ref, roster),
        );
      },
    );
  }

  void _showCreateRosterDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Roster'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Roster Name',
            hintText: 'e.g., Tournament List, 1000pt Strike Force',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                SnackBarUtils.showError(context, 'Please enter a roster name');
                return;
              }

              final newRoster = Roster(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
              );

              ref.read(currentCrusadeNotifierProvider.notifier).addRoster(newRoster);
              Navigator.pop(context);

              // Navigate to edit the new roster
              context.go('/roster/${newRoster.id}/edit');
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRoster(BuildContext context, WidgetRef ref, Roster roster) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Roster?'),
        content: Text(
          'Are you sure you want to delete "${roster.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentCrusadeNotifierProvider.notifier).deleteRoster(roster.id);
              Navigator.pop(context);
              SnackBarUtils.showSuccess(context, 'Roster "${roster.name}" deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _RosterCard extends StatelessWidget {
  final Roster roster;
  final List<UnitOrGroup> oob;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RosterCard({
    required this.roster,
    required this.oob,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalPoints = roster.calculateTotalPoints(oob);
    final unitCount = roster.unitIds.length;
    final hasGames = roster.timesDeployed > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roster.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$unitCount units - $totalPoints pts',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit Roster',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete Roster',
                  ),
                ],
              ),

              // Game stats (if any games played)
              if (hasGames) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                      label: 'Deployed',
                      value: '${roster.timesDeployed}',
                      color: Colors.blue,
                    ),
                    _StatChip(
                      label: 'Wins',
                      value: '${roster.wins}',
                      color: Colors.green,
                    ),
                    _StatChip(
                      label: 'Losses',
                      value: '${roster.losses}',
                      color: Colors.red,
                    ),
                    _StatChip(
                      label: 'Draws',
                      value: '${roster.draws}',
                      color: Colors.orange,
                    ),
                    _StatChip(
                      label: 'Win Rate',
                      value: roster.winRate,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],

              // Last modified
              const SizedBox(height: 8),
              Text(
                'Last modified: ${_formatDate(roster.lastModified)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
