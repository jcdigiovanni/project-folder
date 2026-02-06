import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../widgets/army_avatar.dart';

/// Screen for tracking in-game agenda progress
/// Shows each unit with their agenda-specific tracking fields
class ActiveGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const ActiveGameScreen({super.key, required this.gameId});

  @override
  ConsumerState<ActiveGameScreen> createState() => _ActiveGameScreenState();
}

class _ActiveGameScreenState extends ConsumerState<ActiveGameScreen> {
  @override
  Widget build(BuildContext context) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Game')),
        body: const Center(child: Text('No Crusade loaded.')),
      );
    }

    // Find the game by ID
    final game = currentCrusade.games
        .where((g) => g.id == widget.gameId)
        .firstOrNull;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Game')),
        body: const Center(child: Text('Game not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArmyAvatar(
              factionAsset: currentCrusade.factionIconAsset,
              customPath: currentCrusade.armyIconPath,
              radius: 16,
            ),
            const SizedBox(width: 12),
            Text(game.name),
          ],
        ),
        actions: [
          // Defeat button
          TextButton.icon(
            onPressed: () => _showEndGameDialog(context, game, result: GameResult.loss),
            icon: Icon(Icons.cancel_outlined, color: Colors.red.shade300),
            label: Text('Defeat', style: TextStyle(color: Colors.red.shade300)),
          ),
          // Draw button (ENH-007)
          TextButton.icon(
            onPressed: () => _showEndGameDialog(context, game, result: GameResult.draw),
            icon: Icon(Icons.handshake_outlined, color: Colors.orange.shade300),
            label: Text('Draw', style: TextStyle(color: Colors.orange.shade300)),
          ),
          // Victory button
          TextButton.icon(
            onPressed: () => _showEndGameDialog(context, game, result: GameResult.win),
            icon: Icon(Icons.emoji_events_outlined, color: Colors.green.shade300),
            label: Text('Victory', style: TextStyle(color: Colors.green.shade300)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Crusade Points display (ENH-008)
          _CrusadePointsBar(crusadePoints: currentCrusade.totalCrusadePoints),
          // Agenda summary header
          _AgendaSummaryHeader(
            game: game,
            onSelectUnit: (agenda) => _showUnitSelectionDialog(context, game, agenda),
          ),
          const Divider(height: 1),
          // Unit list with agenda tracking (grouped by group membership)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _buildGroupedUnitList(game),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a list of widgets grouping units by their group membership
  List<Widget> _buildGroupedUnitList(Game game) {
    final List<Widget> widgets = [];
    final processedGroupIds = <String>{};

    for (final unitState in game.unitStates) {
      // If this unit is part of a group
      if (unitState.groupId != null) {
        // Skip if we've already processed this group
        if (processedGroupIds.contains(unitState.groupId)) continue;
        processedGroupIds.add(unitState.groupId!);

        // Get all units in this group
        final groupUnits = game.unitStates
            .where((u) => u.groupId == unitState.groupId)
            .toList();

        // Create a grouped container
        widgets.add(_GroupedUnitsContainer(
          groupName: unitState.groupName ?? 'Group',
          unitStates: groupUnits,
          agendas: game.agendas,
          onTallyChanged: (unitId, agendaId, newValue) {
            _updateTally(game, unitId, agendaId, newValue);
          },
          onTierChanged: (unitId, agendaId, newTier) {
            _updateUnitTier(game, unitId, agendaId, newTier);
          },
          onKillsChanged: (unitId, newKills) {
            _updateKills(game, unitId, newKills);
          },
          onDestroyedChanged: (unitId, wasDestroyed) {
            _updateDestroyed(game, unitId, wasDestroyed);
          },
        ));
      } else {
        // Standalone unit - use the regular card
        widgets.add(_UnitAgendaCard(
          unitState: unitState,
          agendas: game.agendas,
          onTallyChanged: (agendaId, newValue) {
            _updateTally(game, unitState.unitId, agendaId, newValue);
          },
          onTierChanged: (agendaId, newTier) {
            _updateUnitTier(game, unitState.unitId, agendaId, newTier);
          },
          onKillsChanged: (newKills) {
            _updateKills(game, unitState.unitId, newKills);
          },
          onDestroyedChanged: (wasDestroyed) {
            _updateDestroyed(game, unitState.unitId, wasDestroyed);
          },
        ));
      }
    }

    return widgets;
  }

  void _updateTally(Game game, String unitId, String agendaId, int newValue) {
    final agenda = game.agendas.where((a) => a.id == agendaId).firstOrNull;
    if (agenda != null && agenda.type == AgendaType.tally) {
      setState(() {
        agenda.unitTallies[unitId] = newValue;
      });
      // Save the game state
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  void _updateUnitTier(Game game, String unitId, String agendaId, int newTier) {
    final agenda = game.agendas.where((a) => a.id == agendaId).firstOrNull;
    if (agenda != null && agenda.type == AgendaType.objective) {
      setState(() {
        // For tiered objectives, we track per-unit tiers in unitTallies
        // (reusing the map to store tier level per unit)
        agenda.unitTallies[unitId] = newTier;
      });
      // Save the game state
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  void _updateKills(Game game, String unitId, int newKills) {
    final unitState = game.unitStates.where((u) => u.unitId == unitId).firstOrNull;
    if (unitState != null) {
      setState(() {
        unitState.kills = newKills;
      });
      // Save the game state
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  void _updateDestroyed(Game game, String unitId, bool wasDestroyed) {
    final unitState = game.unitStates.where((u) => u.unitId == unitId).firstOrNull;
    if (unitState != null) {
      setState(() {
        unitState.wasDestroyed = wasDestroyed;
      });
      // Save the game state
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  void _showEndGameDialog(BuildContext context, Game game, {required String result}) {
    // Determine dialog text based on result type (ENH-007)
    String title;
    String message;
    String buttonLabel;
    Color buttonColor;

    switch (result) {
      case GameResult.win:
        title = 'Claim Victory?';
        message = 'Mark this game as a victory? This will end the battle and prepare for post-game paperwork.';
        buttonLabel = 'Victory';
        buttonColor = Colors.green.shade700;
        break;
      case GameResult.draw:
        title = 'Declare Draw?';
        message = 'Mark this game as a draw? This will end the battle and prepare for post-game paperwork.';
        buttonLabel = 'Draw';
        buttonColor = Colors.orange.shade700;
        break;
      case GameResult.loss:
      default:
        title = 'Concede Defeat?';
        message = 'Mark this game as a defeat? This will end the battle and prepare for post-game paperwork.';
        buttonLabel = 'Defeat';
        buttonColor = Colors.red.shade700;
        break;
    }

    final playerScoreController = TextEditingController();
    final opponentScoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 20),
            // Score input row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: playerScoreController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: '0',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('vs.', style: TextStyle(color: Colors.grey.shade400)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: opponentScoreController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: '0',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Opp', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
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
              final playerScore = int.tryParse(playerScoreController.text);
              final opponentScore = int.tryParse(opponentScoreController.text);
              Navigator.pop(context);
              _endGame(game, result: result, playerScore: playerScore, opponentScore: opponentScore);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  void _endGame(Game game, {required String result, int? playerScore, int? opponentScore}) {
    game.completedAt = DateTime.now().millisecondsSinceEpoch;
    game.result = result;
    game.playerScore = playerScore;
    game.opponentScore = opponentScore;
    ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);

    // Navigate to post-game screen for review and XP calculation
    context.go('/postgame/${game.id}');
  }

  void _showUnitSelectionDialog(BuildContext context, Game game, GameAgenda agenda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Unit for ${agenda.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose ${agenda.maxUnits} unit${agenda.maxUnits! > 1 ? 's' : ''} to attempt this agenda:',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...game.unitStates.map((unitState) {
                      final isSelected = agenda.assignedUnitIds.contains(unitState.unitId);
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? const Color(0xFFFFB6C1) : Colors.grey,
                        ),
                        title: Text(unitState.unitName),
                        onTap: () {
                          Navigator.pop(context);
                          _assignUnitToAgenda(game, agenda, unitState.unitId);
                        },
                      );
                    }),
                    if (agenda.assignedUnitIds.isNotEmpty) ...[
                      const Divider(),
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(Icons.clear, color: Colors.red.shade300),
                        title: Text('Clear Selection', style: TextStyle(color: Colors.red.shade300)),
                        onTap: () {
                          Navigator.pop(context);
                          _clearAgendaAssignment(game, agenda);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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

  void _assignUnitToAgenda(Game game, GameAgenda agenda, String unitId) {
    setState(() {
      agenda.assignedUnitIds.clear();
      agenda.assignedUnitIds.add(unitId);
    });
    ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
  }

  void _clearAgendaAssignment(Game game, GameAgenda agenda) {
    setState(() {
      agenda.assignedUnitIds.clear();
    });
    ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
  }
}

/// Collapsible header showing agenda summary with progress tracking
class _AgendaSummaryHeader extends StatefulWidget {
  final Game game;
  final Function(GameAgenda agenda) onSelectUnit;

  const _AgendaSummaryHeader({
    required this.game,
    required this.onSelectUnit,
  });

  @override
  State<_AgendaSummaryHeader> createState() => _AgendaSummaryHeaderState();
}

class _AgendaSummaryHeaderState extends State<_AgendaSummaryHeader> {
  bool _isExpanded = false; // Default collapsed per ENH-015

  @override
  Widget build(BuildContext context) {
    if (widget.game.agendas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              'No agendas selected for this battle',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    // Build collapsed summary (agenda names + total tally)
    final agendaNames = widget.game.agendas.map((a) => a.name).join(', ');
    final totalTallies = widget.game.agendas.fold<int>(
      0,
      (sum, a) => sum + (a.type == AgendaType.tally ? a.totalTallies : a.tier),
    );

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable header row (always visible)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Expand/collapse chevron
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: Color(0xFFFFB6C1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Agendas label
                  Text(
                    'Agendas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  // Collapsed summary or active count
                  if (!_isExpanded)
                    Flexible(
                      child: Text(
                        agendaNames,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Progress badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB6C1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stacked_bar_chart,
                          size: 14,
                          color: Color(0xFFFFB6C1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalTallies',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFB6C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content (agenda cards)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.game.agendas
                    .map((agenda) => _AgendaProgressCard(
                          agenda: agenda,
                          game: widget.game,
                          onSelectUnit: () => widget.onSelectUnit(agenda),
                        ))
                    .toList(),
              ),
            ),
            crossFadeState:
                _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// Individual agenda card with progress tracking
class _AgendaProgressCard extends StatelessWidget {
  final GameAgenda agenda;
  final Game game;
  final VoidCallback onSelectUnit;

  const _AgendaProgressCard({
    required this.agenda,
    required this.game,
    required this.onSelectUnit,
  });

  String _getAssignedUnitName() {
    if (agenda.assignedUnitIds.isEmpty) return 'None';
    final unitState = game.unitStates
        .where((u) => u.unitId == agenda.assignedUnitIds.first)
        .firstOrNull;
    return unitState?.unitName ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final isTally = agenda.type == AgendaType.tally;
    final isObjective = agenda.type == AgendaType.objective;
    final hasUnitLimit = agenda.maxUnits != null;
    final needsUnitAssignment = hasUnitLimit && agenda.assignedUnitIds.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: needsUnitAssignment
          ? Colors.orange.withValues(alpha: 0.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isTally
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isTally ? Icons.leaderboard : Icons.emoji_events,
                    size: 16,
                    color: isTally ? Colors.blue : Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agenda.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isTally ? 'Tally Agenda' : 'Objective Agenda',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                // Tally total badge
                if (isTally)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB6C1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stacked_bar_chart, size: 14, color: Color(0xFFFFB6C1)),
                        const SizedBox(width: 4),
                        Text(
                          '${agenda.totalTallies}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFFFB6C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Tier progress for objective agendas
                if (isObjective && agenda.maxTier > 1)
                  _TierProgressIndicator(
                    currentTier: agenda.tier,
                    maxTier: agenda.maxTier,
                  ),
              ],
            ),

            // Description
            if (agenda.description != null) ...[
              const SizedBox(height: 8),
              Text(
                agenda.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],

            // Unit assignment for limited agendas
            if (hasUnitLimit) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: onSelectUnit,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: needsUnitAssignment
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: needsUnitAssignment
                          ? Colors.orange.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        needsUnitAssignment ? Icons.person_add : Icons.person,
                        size: 16,
                        color: needsUnitAssignment ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          needsUnitAssignment
                              ? 'Tap to assign unit'
                              : 'Assigned: ${_getAssignedUnitName()}',
                          style: TextStyle(
                            fontSize: 13,
                            color: needsUnitAssignment ? Colors.orange : null,
                            fontWeight: needsUnitAssignment ? FontWeight.w500 : null,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: needsUnitAssignment ? Colors.orange : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Progress bar for tally agendas with targets
            if (isTally && agenda.totalTallies > 0) ...[
              const SizedBox(height: 10),
              _TallyProgressBar(totalTallies: agenda.totalTallies),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tier progress indicator for objective agendas
class _TierProgressIndicator extends StatelessWidget {
  final int currentTier;
  final int maxTier;

  const _TierProgressIndicator({
    required this.currentTier,
    required this.maxTier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxTier, (index) {
        final tierNum = index + 1;
        final isAchieved = currentTier >= tierNum;
        return Container(
          margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isAchieved
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isAchieved
                  ? Colors.green
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: isAchieved
                ? const Icon(Icons.check, size: 14, color: Colors.green)
                : Text(
                    '$tierNum',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

/// Progress bar showing tally progress with milestone markers
class _TallyProgressBar extends StatelessWidget {
  final int totalTallies;

  const _TallyProgressBar({required this.totalTallies});

  @override
  Widget build(BuildContext context) {
    // Define milestone targets (e.g., XP thresholds)
    const milestones = [3, 6, 10];
    final maxMilestone = milestones.last;
    final progress = (totalTallies / maxMilestone).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              'Progress',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress fill
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFB6C1),
                      const Color(0xFFFFB6C1).withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Milestone markers
            ...milestones.map((milestone) {
              final position = milestone / maxMilestone;
              return Positioned(
                left: 0,
                right: 0,
                child: FractionallySizedBox(
                  widthFactor: position,
                  alignment: Alignment.centerLeft,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 2,
                      height: 8,
                      color: totalTallies >= milestone
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: milestones.map((m) {
            final achieved = totalTallies >= m;
            return Text(
              '$m',
              style: TextStyle(
                fontSize: 10,
                color: achieved ? const Color(0xFFFFB6C1) : Colors.grey.shade600,
                fontWeight: achieved ? FontWeight.bold : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Container that groups multiple units visually with a border and group name header
class _GroupedUnitsContainer extends StatelessWidget {
  final String groupName;
  final List<UnitGameState> unitStates;
  final List<GameAgenda> agendas;
  final Function(String unitId, String agendaId, int newValue) onTallyChanged;
  final Function(String unitId, String agendaId, int newTier) onTierChanged;
  final Function(String unitId, int newKills) onKillsChanged;
  final Function(String unitId, bool wasDestroyed) onDestroyedChanged;

  const _GroupedUnitsContainer({
    required this.groupName,
    required this.unitStates,
    required this.agendas,
    required this.onTallyChanged,
    required this.onTierChanged,
    required this.onKillsChanged,
    required this.onDestroyedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFFFB6C1).withValues(alpha: 0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group name header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB6C1).withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: Color(0xFFFFB6C1),
                ),
                const SizedBox(width: 8),
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB6C1),
                  ),
                ),
              ],
            ),
          ),
          // Unit cards within the group
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: unitStates.map((unitState) {
                return _UnitAgendaCard(
                  unitState: unitState,
                  agendas: agendas,
                  onTallyChanged: (agendaId, newValue) {
                    onTallyChanged(unitState.unitId, agendaId, newValue);
                  },
                  onTierChanged: (agendaId, newTier) {
                    onTierChanged(unitState.unitId, agendaId, newTier);
                  },
                  onKillsChanged: (newKills) {
                    onKillsChanged(unitState.unitId, newKills);
                  },
                  onDestroyedChanged: (wasDestroyed) {
                    onDestroyedChanged(unitState.unitId, wasDestroyed);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card for a single unit showing agenda tracking controls
class _UnitAgendaCard extends StatelessWidget {
  final UnitGameState unitState;
  final List<GameAgenda> agendas;
  final Function(String agendaId, int newValue) onTallyChanged;
  final Function(String agendaId, int newTier) onTierChanged;
  final Function(int newKills) onKillsChanged;
  final Function(bool wasDestroyed) onDestroyedChanged;

  const _UnitAgendaCard({
    required this.unitState,
    required this.agendas,
    required this.onTallyChanged,
    required this.onTierChanged,
    required this.onKillsChanged,
    required this.onDestroyedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit name and kill tally row
            Row(
              children: [
                Expanded(
                  child: Text(
                    unitState.unitName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Kill tally control
                _KillTallyControl(
                  kills: unitState.kills,
                  onChanged: onKillsChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Agenda tracking controls (only for assigned agendas)
            ...agendas
                .where((agenda) => agenda.isUnitAssigned(unitState.unitId))
                .map((agenda) => _buildAgendaControl(context, agenda)),
            // Unit status toggle (Survived / Destroyed)
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Survived button
                GestureDetector(
                  onTap: unitState.wasDestroyed ? () => onDestroyedChanged(false) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: !unitState.wasDestroyed
                          ? Colors.green.shade900.withValues(alpha: 0.5)
                          : Colors.grey.shade800.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      border: Border.all(
                        color: !unitState.wasDestroyed
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield,
                          size: 16,
                          color: !unitState.wasDestroyed
                              ? Colors.green.shade300
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Survived',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: !unitState.wasDestroyed
                                ? Colors.green.shade300
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Destroyed button
                GestureDetector(
                  onTap: !unitState.wasDestroyed ? () => onDestroyedChanged(true) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: unitState.wasDestroyed
                          ? Colors.red.shade900.withValues(alpha: 0.5)
                          : Colors.grey.shade800.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      border: Border.all(
                        color: unitState.wasDestroyed
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 16,
                          color: unitState.wasDestroyed
                              ? Colors.red.shade300
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Destroyed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: unitState.wasDestroyed
                                ? Colors.red.shade300
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaControl(BuildContext context, GameAgenda agenda) {
    if (agenda.type == AgendaType.tally) {
      return _TallyControl(
        agenda: agenda,
        unitId: unitState.unitId,
        currentValue: agenda.unitTallies[unitState.unitId] ?? 0,
        onChanged: (value) => onTallyChanged(agenda.id, value),
      );
    } else {
      return _TierControl(
        agenda: agenda,
        unitId: unitState.unitId,
        currentTier: agenda.unitTallies[unitState.unitId] ?? 0,
        onChanged: (tier) => onTierChanged(agenda.id, tier),
      );
    }
  }
}

/// Kill tally control - compact increment/decrement for tracking unit kills
/// Shows XP progress indicator (1 XP per 3 kills)
class _KillTallyControl extends StatelessWidget {
  final int kills;
  final Function(int) onChanged;

  const _KillTallyControl({
    required this.kills,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final xpEarned = kills ~/ 3;
    final progressToNext = kills % 3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // XP progress indicator
        if (kills > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: '$progressToNext/3 toward next XP',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress dots
                  ...List.generate(3, (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < progressToNext
                          ? Colors.amber
                          : Colors.grey.shade700,
                    ),
                  )),
                  if (xpEarned > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '+${xpEarned}XP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        // Label
        Text(
          'Kills:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 8),
        // Control
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement button
              InkWell(
                onTap: kills > 0 ? () => onChanged(kills - 1) : null,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Icon(
                    Icons.remove,
                    size: 18,
                    color: kills > 0 ? Colors.red.shade300 : Colors.grey.shade600,
                  ),
                ),
              ),
              // Kill count
              Container(
                constraints: const BoxConstraints(minWidth: 28),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                alignment: Alignment.center,
                child: Text(
                  '$kills',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade300,
                  ),
                ),
              ),
              // Increment button
              InkWell(
                onTap: () => onChanged(kills + 1),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.red.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tally control with increment/decrement buttons
class _TallyControl extends StatelessWidget {
  final GameAgenda agenda;
  final String unitId;
  final int currentValue;
  final Function(int) onChanged;

  const _TallyControl({
    required this.agenda,
    required this.unitId,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agenda.name,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement button
              IconButton(
                onPressed: currentValue > 0 ? () => onChanged(currentValue - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 28,
                color: const Color(0xFFFFB6C1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // Current value
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$currentValue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Increment button
              IconButton(
                onPressed: () => onChanged(currentValue + 1),
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 28,
                color: const Color(0xFFFFB6C1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tier selection control with radio-style buttons
class _TierControl extends StatelessWidget {
  final GameAgenda agenda;
  final String unitId;
  final int currentTier;
  final Function(int) onChanged;

  const _TierControl({
    required this.agenda,
    required this.unitId,
    required this.currentTier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Define tier labels based on maxTier
    final tierLabels = _getTierLabels();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agenda.name,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(
              agenda.maxTier + 1, // +1 for "none" option (tier 0)
              (index) => ChoiceChip(
                label: Text(tierLabels[index]),
                selected: currentTier == index,
                onSelected: (selected) {
                  if (selected) onChanged(index);
                },
                selectedColor: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                checkmarkColor: const Color(0xFFFFB6C1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTierLabels() {
    // For our placeholder "Survived" agenda with 2 tiers:
    // Tier 0 = None, Tier 1 = Survived, Tier 2 = Survived (half+ wounds)
    if (agenda.maxTier == 2) {
      return ['None', 'Survived', 'Survived (half+ wounds)'];
    }
    // Default labels
    return List.generate(
      agenda.maxTier + 1,
      (i) => i == 0 ? 'None' : 'Tier $i',
    );
  }
}

/// Displays total Crusade Points for the army (ENH-008)
/// Uses full label "Crusade Points" to avoid confusion with Command Points
class _CrusadePointsBar extends StatelessWidget {
  final int crusadePoints;

  const _CrusadePointsBar({required this.crusadePoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB6C1).withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.military_tech,
            size: 18,
            color: Color(0xFFFFB6C1),
          ),
          const SizedBox(width: 8),
          Text(
            'Crusade Points: $crusadePoints',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFB6C1),
            ),
          ),
        ],
      ),
    );
  }
}
