import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/campaign_provider.dart';
import '../utils/snackbar_utils.dart';

class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(campaignsProvider);
    final activeCampaigns = campaigns.where((c) => c.isActive).toList();
    final endedCampaigns = campaigns.where((c) => !c.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/landing'),
        ),
      ),
      body: campaigns.isEmpty
          ? _buildEmptyState(context, ref)
          : _buildCampaignList(context, ref, activeCampaigns, endedCampaigns),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCampaignDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Campaigns Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a campaign to track narrative battles across multiple crusade forces.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateCampaignDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create Campaign'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignList(
    BuildContext context,
    WidgetRef ref,
    List<Campaign> activeCampaigns,
    List<Campaign> endedCampaigns,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (activeCampaigns.isNotEmpty) ...[
          _SectionHeader(
            title: 'Active Campaigns',
            count: activeCampaigns.length,
          ),
          const SizedBox(height: 8),
          ...activeCampaigns.map((campaign) => _CampaignCard(
                campaign: campaign,
                onTap: () => context.go('/campaign/${campaign.id}'),
                onDelete: () => _confirmDeleteCampaign(context, ref, campaign),
              )),
        ],
        if (endedCampaigns.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Ended Campaigns',
            count: endedCampaigns.length,
          ),
          const SizedBox(height: 8),
          ...endedCampaigns.map((campaign) => _CampaignCard(
                campaign: campaign,
                onTap: () => context.go('/campaign/${campaign.id}'),
                onDelete: () => _confirmDeleteCampaign(context, ref, campaign),
                isEnded: true,
              )),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  void _showCreateCampaignDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Campaign'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Campaign Name',
                hintText: 'e.g., The Armageddon Crusade',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'A brief description of the campaign...',
              ),
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
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                SnackBarUtils.showError(context, 'Please enter a campaign name');
                return;
              }

              final campaign = await ref.read(campaignsProvider.notifier).createCampaign(
                    name: name,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  );

              if (context.mounted) {
                Navigator.pop(context);
                SnackBarUtils.showSuccess(context, 'Campaign "$name" created');
                context.go('/campaign/${campaign.id}');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCampaign(BuildContext context, WidgetRef ref, Campaign campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign?'),
        content: Text(
          'Are you sure you want to delete "${campaign.name}"?\n\n'
          'This will not delete any crusade forces, but campaign statistics will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(campaignsProvider.notifier).deleteCampaign(campaign.id);
              if (context.mounted) {
                Navigator.pop(context);
                SnackBarUtils.showSuccess(context, 'Campaign "${campaign.name}" deleted');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isEnded;

  const _CampaignCard({
    required this.campaign,
    required this.onTap,
    required this.onDelete,
    this.isEnded = false,
  });

  @override
  Widget build(BuildContext context) {
    final forceCount = campaign.crusadeLinks.length;
    final totalGames = campaign.totalGames;

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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isEnded
                          ? Colors.grey.withValues(alpha: 0.2)
                          : Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEnded ? Icons.flag : Icons.flag_outlined,
                      color: isEnded ? Colors.grey : Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isEnded ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$forceCount ${forceCount == 1 ? 'force' : 'forces'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.sports_kabaddi,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$totalGames ${totalGames == 1 ? 'game' : 'games'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (campaign.description != null && campaign.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  campaign.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
