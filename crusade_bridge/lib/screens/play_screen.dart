import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../widgets/army_avatar.dart';

/// Battle size definitions with point limits
enum BattleSize {
  combatPatrol(name: 'Combat Patrol', points: 500, icon: Icons.group),
  incursion(name: 'Incursion', points: 1000, icon: Icons.groups),
  strikeForce(name: 'Strike Force', points: 2000, icon: Icons.military_tech),
  onslaught(name: 'Onslaught', points: 3000, icon: Icons.shield),
  apocalypse(name: 'Apocalypse', points: 3000, icon: Icons.whatshot, isUnlimited: true);

  final String name;
  final int points;
  final IconData icon;
  final bool isUnlimited;

  const BattleSize({
    required this.name,
    required this.points,
    required this.icon,
    this.isUnlimited = false,
  });

  String get pointsLabel => isUnlimited ? '3000+ pts' : '$points pts';
}

/// Determines the points status for a roster against a battle size
enum PointsStatus {
  underOrEqual, // Green - at or under limit
  slightlyOver, // Yellow - over by up to 5%
  grosslyOver,  // Red - over by more than 5%
}

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  BattleSize? _selectedBattleSize;

  @override
  Widget build(BuildContext context) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Play')),
        body: const Center(child: Text('No Crusade loaded.')),
      );
    }

    // Check if there are no rosters before even showing battle size selection
    if (currentCrusade.rosters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Play Game'),
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
        body: _buildNoRostersState(context, currentCrusade),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Game'),
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
      body: _selectedBattleSize == null
          ? _buildBattleSizeSelection(context)
          : _buildRosterSelection(context, currentCrusade),
    );
  }

  Widget _buildNoRostersState(BuildContext context, Crusade crusade) {
    final hasUnits = crusade.oob.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Rosters Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasUnits
                  ? 'Create a roster from your ${crusade.oob.length} units to start playing games.'
                  : 'Add units to your Order of Battle, then create a roster to play.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            if (hasUnits) ...[
              ElevatedButton.icon(
                onPressed: () => context.go('/rosters'),
                icon: const Icon(Icons.add),
                label: const Text('Create Roster'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => context.go('/oob'),
                icon: const Icon(Icons.military_tech),
                label: const Text('Build Order of Battle'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Then come back to create rosters and play!',
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

  Widget _buildBattleSizeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Battle Size',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Choose the size of the battle you want to play',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // Battle size options
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: BattleSize.values.length,
            itemBuilder: (context, index) {
              final battleSize = BattleSize.values[index];
              return _BattleSizeCard(
                battleSize: battleSize,
                onTap: () {
                  setState(() {
                    _selectedBattleSize = battleSize;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRosterSelection(BuildContext context, Crusade crusade) {
    final rosters = crusade.rosters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button and battle size info
        Container(
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedBattleSize = null;
                      });
                    },
                    tooltip: 'Change Battle Size',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedBattleSize!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedBattleSize!.pointsLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFFB6C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _selectedBattleSize!.icon,
                    size: 40,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a roster to deploy',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // Roster list or empty state
        Expanded(
          child: rosters.isEmpty
              ? _buildEmptyRosterState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rosters.length,
                  itemBuilder: (context, index) {
                    final roster = rosters[index];
                    final totalPoints = roster.calculateTotalPoints(crusade.oob);
                    final totalCP = roster.calculateTotalCrusadePoints(crusade.oob);
                    final status = _getPointsStatus(totalPoints, _selectedBattleSize!);

                    return _RosterCard(
                      roster: roster,
                      totalPoints: totalPoints,
                      totalCrusadePoints: totalCP,
                      battleSize: _selectedBattleSize!,
                      status: status,
                      unitCount: roster.unitIds.length,
                      onTap: () => _deployRoster(context, roster, totalPoints, totalCP),
                    );
                  },
                ),
        ),

        // Create roster button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/rosters'),
              icon: const Icon(Icons.add),
              label: const Text('Create New Roster'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRosterState(BuildContext context) {
    return Center(
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
            'No rosters available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a roster to deploy your forces',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/rosters'),
            icon: const Icon(Icons.add),
            label: const Text('Create Roster'),
          ),
        ],
      ),
    );
  }

  PointsStatus _getPointsStatus(int rosterPoints, BattleSize battleSize) {
    // Apocalypse is unlimited (3000+), so anything 3000+ is valid
    if (battleSize.isUnlimited) {
      return PointsStatus.underOrEqual;
    }

    final limit = battleSize.points;
    final overage = rosterPoints - limit;

    if (overage <= 0) {
      return PointsStatus.underOrEqual;
    }

    // 5% threshold
    final threshold = limit * 0.05;
    if (overage <= threshold) {
      return PointsStatus.slightlyOver;
    }

    return PointsStatus.grosslyOver;
  }

  void _deployRoster(BuildContext context, Roster roster, int totalPoints, int totalCP) {
    final status = _getPointsStatus(totalPoints, _selectedBattleSize!);

    // Navigate to the game/deployment screen (to be implemented)
    // For now, show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deploy ${roster.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Battle Size: ${_selectedBattleSize!.name}'),
            Text('Roster Points: $totalPoints pts'),
            Text('Crusade Points: $totalCP CP'),
            Text('Limit: ${_selectedBattleSize!.pointsLabel}'),
            if (status == PointsStatus.grosslyOver) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This roster exceeds the point limit. Consider a larger battle size.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Ready to start the game?',
              style: TextStyle(fontWeight: FontWeight.w500),
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
              Navigator.pop(context);
              // TODO: Navigate to active game screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${roster.name} deployed for ${_selectedBattleSize!.name}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Deploy'),
          ),
        ],
      ),
    );
  }
}

class _BattleSizeCard extends StatelessWidget {
  final BattleSize battleSize;
  final VoidCallback onTap;

  const _BattleSizeCard({
    required this.battleSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  battleSize.icon,
                  size: 28,
                  color: const Color(0xFFFFB6C1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      battleSize.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      battleSize.pointsLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _RosterCard extends StatelessWidget {
  final Roster roster;
  final int totalPoints;
  final int totalCrusadePoints;
  final BattleSize battleSize;
  final PointsStatus status;
  final int unitCount;
  final VoidCallback onTap;

  const _RosterCard({
    required this.roster,
    required this.totalPoints,
    required this.totalCrusadePoints,
    required this.battleSize,
    required this.status,
    required this.unitCount,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case PointsStatus.underOrEqual:
        return Colors.green;
      case PointsStatus.slightlyOver:
        return Colors.amber;
      case PointsStatus.grosslyOver:
        return Colors.red;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case PointsStatus.underOrEqual:
        return Icons.check_circle;
      case PointsStatus.slightlyOver:
        return Icons.warning;
      case PointsStatus.grosslyOver:
        return Icons.error;
    }
  }

  String get _statusMessage {
    switch (status) {
      case PointsStatus.underOrEqual:
        return 'Within limit';
      case PointsStatus.slightlyOver:
        return 'Slightly over';
      case PointsStatus.grosslyOver:
        return 'Consider larger battle size';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        Row(
                          children: [
                            Text(
                              '$unitCount units',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$totalCrusadePoints CP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Points indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 18, color: _statusColor),
                        const SizedBox(width: 6),
                        Text(
                          '$totalPoints pts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status message
              Row(
                children: [
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: _statusColor,
                    ),
                  ),
                  if (hasGames) ...[
                    const Spacer(),
                    Text(
                      '${roster.timesDeployed} games | ${roster.winRate} win rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
