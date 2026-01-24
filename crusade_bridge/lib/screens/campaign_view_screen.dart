import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/campaign_provider.dart';
import '../services/storage_service.dart';
import '../utils/snackbar_utils.dart';

class CampaignViewScreen extends ConsumerWidget {
  final String campaignId;

  const CampaignViewScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    final campaign = campaigns.where((c) => c.id == campaignId).firstOrNull;

    if (campaign == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Campaign')),
        body: const Center(child: Text('Campaign not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, campaign, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: campaign.isActive ? 'end' : 'reactivate',
                child: Row(
                  children: [
                    Icon(
                      campaign.isActive ? Icons.flag : Icons.play_arrow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(campaign.isActive ? 'End Campaign' : 'Reactivate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Details'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Campaign header
          _CampaignHeader(campaign: campaign),

          // Crusade forces list
          Expanded(
            child: campaign.crusadeLinks.isEmpty
                ? _buildEmptyForcesState(context, ref, campaign)
                : _buildForcesList(context, ref, campaign),
          ),
        ],
      ),
      floatingActionButton: campaign.isActive
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCrusadeDialog(context, ref, campaign),
              icon: const Icon(Icons.add),
              label: const Text('Add Force'),
            )
          : null,
    );
  }

  Widget _buildEmptyForcesState(BuildContext context, WidgetRef ref, Campaign campaign) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Forces Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add crusade forces to track their progress in this campaign.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
            if (campaign.isActive) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddCrusadeDialog(context, ref, campaign),
                icon: const Icon(Icons.add),
                label: const Text('Add Crusade Force'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForcesList(BuildContext context, WidgetRef ref, Campaign campaign) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campaign.crusadeLinks.length + 1, // +1 for bottom padding
      itemBuilder: (context, index) {
        if (index == campaign.crusadeLinks.length) {
          return const SizedBox(height: 80); // Space for FAB
        }

        final link = campaign.crusadeLinks[index];
        return _CrusadeForceCard(
          link: link,
          isActive: campaign.isActive,
          onRemove: campaign.isActive
              ? () => _confirmRemoveCrusade(context, ref, campaign, link)
              : null,
        );
      },
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    Campaign campaign,
    String action,
  ) {
    switch (action) {
      case 'end':
        _confirmEndCampaign(context, ref, campaign);
        break;
      case 'reactivate':
        ref.read(campaignsProvider.notifier).reactivateCampaign(campaign.id);
        SnackBarUtils.showSuccess(context, 'Campaign reactivated');
        break;
      case 'edit':
        _showEditCampaignDialog(context, ref, campaign);
        break;
    }
  }

  void _confirmEndCampaign(BuildContext context, WidgetRef ref, Campaign campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Campaign?'),
        content: const Text(
          'This will mark the campaign as ended. You can reactivate it later if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(campaignsProvider.notifier).endCampaign(campaign.id);
              Navigator.pop(context);
              SnackBarUtils.showSuccess(context, 'Campaign ended');
            },
            child: const Text('End Campaign'),
          ),
        ],
      ),
    );
  }

  void _showEditCampaignDialog(BuildContext context, WidgetRef ref, Campaign campaign) {
    final nameController = TextEditingController(text: campaign.name);
    final descriptionController = TextEditingController(text: campaign.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Campaign'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Campaign Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
          ],
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
                SnackBarUtils.showError(context, 'Please enter a campaign name');
                return;
              }

              campaign.name = name;
              campaign.description = descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim();
              campaign.lastModified = DateTime.now().millisecondsSinceEpoch;

              ref.read(campaignsProvider.notifier).updateCampaign(campaign);
              Navigator.pop(context);
              SnackBarUtils.showSuccess(context, 'Campaign updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddCrusadeDialog(BuildContext context, WidgetRef ref, Campaign campaign) {
    final allCrusades = StorageService.loadAllCrusades();

    // Filter out crusades already in this campaign
    final availableCrusades = allCrusades
        .where((c) => !campaign.hasCrusade(c.id))
        .toList();

    if (availableCrusades.isEmpty) {
      SnackBarUtils.showMessage(
        context,
        allCrusades.isEmpty
            ? 'No crusade forces available. Create one first!'
            : 'All crusade forces are already in this campaign.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.add, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Add Crusade Force',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableCrusades.length,
                itemBuilder: (context, index) {
                  final crusade = availableCrusades[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.withValues(alpha: 0.2),
                        child: const Icon(Icons.shield, color: Colors.purple),
                      ),
                      title: Text(crusade.name),
                      subtitle: Text(crusade.faction),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        ref.read(campaignsProvider.notifier).addCrusadeToCampaign(
                              campaign.id,
                              crusade,
                            );
                        Navigator.pop(context);
                        SnackBarUtils.showSuccess(
                          context,
                          '${crusade.name} added to campaign',
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveCrusade(
    BuildContext context,
    WidgetRef ref,
    Campaign campaign,
    CrusadeCampaignLink link,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Force?'),
        content: Text(
          'Remove "${link.crusadeName}" from this campaign?\n\n'
          'Campaign statistics for this force will be lost, but the crusade itself will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(campaignsProvider.notifier).removeCrusadeFromCampaign(
                    campaign.id,
                    link.crusadeId,
                  );
              Navigator.pop(context);
              SnackBarUtils.showSuccess(context, 'Force removed from campaign');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _CampaignHeader extends StatelessWidget {
  final Campaign campaign;

  const _CampaignHeader({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!campaign.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ENDED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              Expanded(
                child: Row(
                  children: [
                    _StatBadge(
                      icon: Icons.groups,
                      value: '${campaign.crusadeLinks.length}',
                      label: 'Forces',
                    ),
                    const SizedBox(width: 16),
                    _StatBadge(
                      icon: Icons.sports_kabaddi,
                      value: '${campaign.totalGames}',
                      label: 'Games',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (campaign.description != null && campaign.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              campaign.description!,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _CrusadeForceCard extends StatelessWidget {
  final CrusadeCampaignLink link;
  final bool isActive;
  final VoidCallback? onRemove;

  const _CrusadeForceCard({
    required this.link,
    required this.isActive,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasGames = link.gamesPlayed > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                  child: const Icon(Icons.shield, color: Colors.purple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.crusadeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        link.faction,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasGames)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      link.winRate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: onRemove,
                    tooltip: 'Remove from campaign',
                  ),
                ],
              ],
            ),
            if (hasGames) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniStat(label: 'Games', value: '${link.gamesPlayed}'),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'Wins', value: '${link.wins}', color: Colors.green),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'Losses', value: '${link.losses}', color: Colors.red),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'Draws', value: '${link.draws}', color: Colors.orange),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'No games played yet',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MiniStat({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
