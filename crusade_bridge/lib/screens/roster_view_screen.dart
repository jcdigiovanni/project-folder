import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../widgets/army_avatar.dart';
import '../utils/snackbar_utils.dart';

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
                  onPressed: units.isEmpty
                      ? null
                      : () => _showRecordGameDialog(context, ref, roster),
                  icon: const Icon(Icons.sports_kabaddi),
                  label: const Text('Record Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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

  void _showRecordGameDialog(BuildContext context, WidgetRef ref, Roster roster) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Game Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Record the result for "${roster.name}"'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ResultButton(
                  label: 'Win',
                  icon: Icons.emoji_events,
                  color: Colors.green,
                  onTap: () => _recordResult(context, ref, roster, 'win'),
                ),
                _ResultButton(
                  label: 'Loss',
                  icon: Icons.sentiment_dissatisfied,
                  color: Colors.red,
                  onTap: () => _recordResult(context, ref, roster, 'loss'),
                ),
                _ResultButton(
                  label: 'Draw',
                  icon: Icons.handshake,
                  color: Colors.orange,
                  onTap: () => _recordResult(context, ref, roster, 'draw'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _recordResult(BuildContext context, WidgetRef ref, Roster roster, String result) {
    // Create updated roster with new game record
    final updatedRoster = Roster(
      id: roster.id,
      name: roster.name,
      unitIds: roster.unitIds,
      createdAt: roster.createdAt,
      lastModified: DateTime.now().millisecondsSinceEpoch,
      timesDeployed: roster.timesDeployed + 1,
      wins: roster.wins + (result == 'win' ? 1 : 0),
      losses: roster.losses + (result == 'loss' ? 1 : 0),
      draws: roster.draws + (result == 'draw' ? 1 : 0),
    );

    ref.read(currentCrusadeNotifierProvider.notifier).updateRoster(updatedRoster);
    Navigator.pop(context);

    final resultText = result == 'win' ? 'Victory' : result == 'loss' ? 'Defeat' : 'Draw';
    SnackBarUtils.showSuccess(context, '$resultText recorded for "${roster.name}"');
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

class _ResultButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ResultButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
