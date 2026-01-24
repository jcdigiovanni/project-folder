import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../widgets/army_avatar.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Crusade History')),
        body: const Center(child: Text('No Crusade loaded. Create one first.')),
      );
    }

    final history = currentCrusade.history;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentCrusade.name} History'),
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
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No history yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Events will appear here as you play',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                // Show newest first
                final event = history[history.length - 1 - index];
                return _HistoryEventCard(event: event);
              },
            ),
    );
  }
}

class _HistoryEventCard extends StatelessWidget {
  final CrusadeEvent event;

  const _HistoryEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getEventColor(event.type).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(event.type),
                color: _getEventColor(event.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timestamp
                  Text(
                    '${event.formattedDate} at ${event.formattedTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Unit name (if applicable)
                  if (event.unitName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.unitName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Metadata display (optional details)
                  if (event.metadata != null && event.metadata!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _buildMetadataChips(event.metadata!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case CrusadeEventType.unitAdded:
        return Icons.add_circle;
      case CrusadeEventType.unitRemoved:
        return Icons.remove_circle;
      case CrusadeEventType.requisition:
        return Icons.workspace_premium;
      case CrusadeEventType.battle:
        return Icons.sports_kabaddi;
      case CrusadeEventType.xpGain:
        return Icons.trending_up;
      case CrusadeEventType.rankUp:
        return Icons.military_tech;
      case CrusadeEventType.honour:
        return Icons.stars;
      case CrusadeEventType.scar:
        return Icons.healing;
      case CrusadeEventType.outOfAction:
        return Icons.warning;
      case CrusadeEventType.enhancement:
        return Icons.auto_awesome;
      case CrusadeEventType.crusadeCreated:
        return Icons.flag;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case CrusadeEventType.unitAdded:
        return Colors.green;
      case CrusadeEventType.unitRemoved:
        return Colors.red;
      case CrusadeEventType.requisition:
        return Colors.amber;
      case CrusadeEventType.battle:
        return Colors.blue;
      case CrusadeEventType.xpGain:
        return Colors.purple;
      case CrusadeEventType.rankUp:
        return Colors.orange;
      case CrusadeEventType.honour:
        return Colors.yellow.shade700;
      case CrusadeEventType.scar:
        return Colors.red.shade700;
      case CrusadeEventType.outOfAction:
        return Colors.deepOrange;
      case CrusadeEventType.enhancement:
        return Colors.teal;
      case CrusadeEventType.crusadeCreated:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildMetadataChips(Map<String, dynamic> metadata) {
    final chips = <Widget>[];

    // RP cost
    if (metadata['rpCost'] != null) {
      chips.add(_MetadataChip(
        label: '${metadata['rpCost']} RP',
        color: Colors.amber,
      ));
    }

    // Points
    if (metadata['points'] != null) {
      chips.add(_MetadataChip(
        label: '${metadata['points']} pts',
        color: Colors.blue,
      ));
    }

    // Enhancement points
    if (metadata['enhancementPoints'] != null) {
      chips.add(_MetadataChip(
        label: '+${metadata['enhancementPoints']} pts',
        color: Colors.teal,
      ));
    }

    // XP
    if (metadata['xp'] != null) {
      chips.add(_MetadataChip(
        label: '+${metadata['xp']} XP',
        color: Colors.purple,
      ));
    }

    // First character flag
    if (metadata['firstCharacter'] == true) {
      chips.add(_MetadataChip(
        label: 'First Character',
        color: Colors.green,
      ));
    }

    // Rank up flag
    if (metadata['onRankUp'] == true) {
      chips.add(_MetadataChip(
        label: 'On Rank Up',
        color: Colors.orange,
      ));
    }

    return chips;
  }
}

class _MetadataChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetadataChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
