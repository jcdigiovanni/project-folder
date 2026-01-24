import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../widgets/army_avatar.dart';

class RosterViewScreen extends ConsumerWidget {
  final String rosterId;

  const RosterViewScreen({super.key, required this.rosterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Roster')),
        body: const Center(child: Text('No Crusade loaded.')),
      );
    }

    final roster = currentCrusade.rosters.where((r) => r.id == rosterId).firstOrNull;

    if (roster == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Roster')),
        body: const Center(child: Text('Roster not found.')),
      );
    }

    final units = roster.getUnits(currentCrusade.oob);
    final totalPoints = roster.calculateTotalPoints(currentCrusade.oob);

    return Scaffold(
      appBar: AppBar(
        title: Text(roster.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/roster/$rosterId/edit'),
            tooltip: 'Edit Roster',
          ),
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
          // Roster summary header
          _RosterSummaryHeader(
            roster: roster,
            totalPoints: totalPoints,
            unitCount: units.length,
            supplyLimit: currentCrusade.supplyLimit,
          ),

          // Unit list
          Expanded(
            child: units.isEmpty
                ? Center(
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
                          'No units in this roster',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/roster/$rosterId/edit'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Units'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      return _UnitDetailCard(unit: unit);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/rosters'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Rosters'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showStatsDialog(context, roster),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View Stats'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, Roster roster) {
    final hasGames = roster.timesDeployed > 0;

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
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${roster.name} Stats',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Stats content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  if (!hasGames) ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.sports_kabaddi,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No battles yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This roster has not been deployed in any games.',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Win rate card
                    _StatsCard(
                      title: 'Performance',
                      children: [
                        _LargeStatRow(
                          label: 'Win Rate',
                          value: roster.winRate,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: 'Games',
                                value: '${roster.timesDeployed}',
                                icon: Icons.sports_kabaddi,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                label: 'Wins',
                                value: '${roster.wins}',
                                icon: Icons.emoji_events,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: 'Losses',
                                value: '${roster.losses}',
                                icon: Icons.sentiment_dissatisfied,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                label: 'Draws',
                                value: '${roster.draws}',
                                icon: Icons.handshake,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Roster info card
                    _StatsCard(
                      title: 'Roster Info',
                      children: [
                        _InfoRow(
                          label: 'Created',
                          value: _formatDate(roster.createdAt),
                        ),
                        _InfoRow(
                          label: 'Last Modified',
                          value: _formatDate(roster.lastModified),
                        ),
                        _InfoRow(
                          label: 'Units',
                          value: '${roster.unitIds.length}',
                        ),
                      ],
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

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _RosterSummaryHeader extends StatelessWidget {
  final Roster roster;
  final int totalPoints;
  final int unitCount;
  final int supplyLimit;

  const _RosterSummaryHeader({
    required this.roster,
    required this.totalPoints,
    required this.unitCount,
    required this.supplyLimit,
  });

  @override
  Widget build(BuildContext context) {
    final hasGames = roster.timesDeployed > 0;

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
          // Points and unit count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unitCount Units',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalPoints / $supplyLimit pts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: totalPoints > supplyLimit
                          ? Colors.red
                          : const Color(0xFFFFB6C1),
                    ),
                  ),
                ],
              ),
              if (hasGames)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        roster.winRate,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Win Rate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Game stats row (if any)
          if (hasGames) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  value: '${roster.timesDeployed}',
                  label: 'Games',
                  color: Colors.blue,
                ),
                _StatColumn(
                  value: '${roster.wins}',
                  label: 'Wins',
                  color: Colors.green,
                ),
                _StatColumn(
                  value: '${roster.losses}',
                  label: 'Losses',
                  color: Colors.red,
                ),
                _StatColumn(
                  value: '${roster.draws}',
                  label: 'Draws',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _UnitDetailCard extends StatelessWidget {
  final UnitOrGroup unit;

  const _UnitDetailCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    final displayName = unit.customName ?? unit.name;
    final isWarlord = unit.isWarlord == true;
    final isEpicHero = unit.isEpicHero == true;
    final isCharacter = unit.isCharacter == true;
    final hasEnhancements = unit.enhancements.isNotEmpty;
    final hasHonours = unit.honours.isNotEmpty;
    final hasScars = unit.scars.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                      Row(
                        children: [
                          if (isWarlord)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.star, size: 18, color: Colors.amber),
                            ),
                          if (isEpicHero)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.auto_awesome, size: 18, color: Colors.purple),
                            ),
                          if (isCharacter && !isEpicHero)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.person, size: 18, color: Colors.blue),
                            ),
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (unit.customName != null)
                        Text(
                          unit.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                // Points badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB6C1).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${unit.points} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB6C1),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Rank and XP row
            Row(
              children: [
                _InfoChip(
                  icon: Icons.military_tech,
                  label: unit.rank,
                  color: _getRankColor(unit.rank),
                ),
                if (!isEpicHero) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.trending_up,
                    label: '${unit.xp} XP',
                    color: Colors.purple,
                  ),
                ],
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.workspace_premium,
                  label: '${unit.crusadePoints} CP',
                  color: Colors.amber,
                ),
              ],
            ),

            // Enhancements
            if (hasEnhancements) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: unit.enhancements
                    .map((e) => _TagChip(label: e, color: Colors.teal))
                    .toList(),
              ),
            ],

            // Honours
            if (hasHonours) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: unit.honours
                    .map((h) => _TagChip(label: h, color: Colors.amber))
                    .toList(),
              ),
            ],

            // Scars
            if (hasScars) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: unit.scars
                    .map((s) => _TagChip(label: s, color: Colors.red))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'Legendary':
        return Colors.purple;
      case 'Heroic':
        return Colors.orange;
      case 'Battle-hardened':
        return Colors.blue;
      case 'Blooded':
        return Colors.green;
      case 'Epic Hero':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

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

class _StatsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _StatsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LargeStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LargeStatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
