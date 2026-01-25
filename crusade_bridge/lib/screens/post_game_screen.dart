import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../services/storage_service.dart';

/// Post-game screen for reviewing and finalizing battle results
/// Allows adjustments before committing XP and tally updates to units
class PostGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const PostGameScreen({super.key, required this.gameId});

  @override
  ConsumerState<PostGameScreen> createState() => _PostGameScreenState();
}

class _PostGameScreenState extends ConsumerState<PostGameScreen> {
  String? _markedForGreatnessUnitId;

  @override
  void initState() {
    super.initState();
    // Load any existing marked for greatness selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final crusade = ref.read(currentCrusadeNotifierProvider);
      final game = crusade?.games.where((g) => g.id == widget.gameId).firstOrNull;
      if (game != null) {
        final markedUnit = game.unitStates.where((u) => u.markedForGreatness).firstOrNull;
        if (markedUnit != null) {
          setState(() {
            _markedForGreatnessUnitId = markedUnit.unitId;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final crusade = ref.watch(currentCrusadeNotifierProvider);
    final game = crusade?.games.where((g) => g.id == widget.gameId).firstOrNull;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post-Game')),
        body: const Center(child: Text('Game not found')),
      );
    }

    final isVictory = game.result == GameResult.win;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post-Game Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Column(
        children: [
          // Result banner
          _ResultBanner(game: game, isVictory: isVictory),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Agenda Recap Section
                _AgendaRecapSection(game: game),
                const SizedBox(height: 24),

                // Mark for Greatness Section
                _MarkForGreatnessSection(
                  game: game,
                  selectedUnitId: _markedForGreatnessUnitId,
                  onUnitSelected: (unitId) {
                    setState(() {
                      _markedForGreatnessUnitId = unitId;
                    });
                    _updateMarkedForGreatness(game, unitId);
                  },
                ),
                const SizedBox(height: 24),

                // Unit Summary Section
                _UnitSummarySection(
                  game: game,
                  markedForGreatnessUnitId: _markedForGreatnessUnitId,
                  onKillsChanged: (unitId, newKills) {
                    _updateKills(game, unitId, newKills);
                  },
                  onDestroyedChanged: (unitId, wasDestroyed) {
                    _updateDestroyed(game, unitId, wasDestroyed);
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Commit button
          _CommitButton(
            onCommit: () => _commitResults(game),
          ),
        ],
      ),
    );
  }

  void _updateMarkedForGreatness(Game game, String? unitId) {
    // Clear previous mark
    for (final unitState in game.unitStates) {
      unitState.markedForGreatness = false;
    }
    // Set new mark
    if (unitId != null) {
      final unitState = game.unitStates.where((u) => u.unitId == unitId).firstOrNull;
      if (unitState != null) {
        unitState.markedForGreatness = true;
      }
    }
    ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
  }

  void _updateKills(Game game, String unitId, int newKills) {
    final unitState = game.unitStates.where((u) => u.unitId == unitId).firstOrNull;
    if (unitState != null) {
      setState(() {
        unitState.kills = newKills;
      });
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  void _updateDestroyed(Game game, String unitId, bool wasDestroyed) {
    final unitState = game.unitStates.where((u) => u.unitId == unitId).firstOrNull;
    if (unitState != null) {
      setState(() {
        unitState.wasDestroyed = wasDestroyed;
      });
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  void _commitResults(Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Commit Results?'),
        content: const Text(
          'This will apply XP gains and update unit tallies. '
          'Make sure all adjustments are complete before committing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyResultsToUnits(game);
            },
            child: const Text('Commit'),
          ),
        ],
      ),
    );
  }

  void _applyResultsToUnits(Game game) {
    final crusade = ref.read(currentCrusadeNotifierProvider);
    if (crusade == null) return;

    // Apply results to each unit
    for (final unitState in game.unitStates) {
      // Find the actual unit in the crusade OOB (could be in a group)
      final unit = _findUnitInOOB(crusade, unitState.unitId);
      if (unit == null) continue;

      // Update tallies
      unit.tallies['played'] = (unit.tallies['played'] ?? 0) + 1;
      if (unitState.wasDestroyed) {
        unit.tallies['destroyed'] = (unit.tallies['destroyed'] ?? 0) + 1;
      } else {
        unit.tallies['survived'] = (unit.tallies['survived'] ?? 0) + 1;
      }

      // Add kills to permanent kill tally
      unit.tallies['kills'] = (unit.tallies['kills'] ?? 0) + unitState.kills;

      // Calculate and apply XP
      int xpGained = 0;

      // 1. Participation XP: 1 XP for taking part
      xpGained += 1;

      // 2. Kill tally XP: 1 XP per 3 cumulative kills
      final totalKills = unit.tallies['kills'] ?? 0;
      final previousKills = totalKills - unitState.kills;
      final previousKillXP = previousKills ~/ 3;
      final newKillXP = totalKills ~/ 3;
      xpGained += (newKillXP - previousKillXP);

      // 3. Marked for Greatness XP: 1 XP bonus
      if (unitState.markedForGreatness) {
        xpGained += 1;
      }

      // Apply XP (Epic Heroes don't gain XP)
      if (unit.isEpicHero != true) {
        final previousRank = unit.rank;
        unit.xp += xpGained;
        final newRank = unit.rank;

        // Check if unit ranked up
        if (newRank != previousRank) {
          unit.pendingRankUp = true;
        }
      }
    }

    // Award +1 RP to the crusade for playing a battle
    crusade.rp += 1;

    // Save the crusade with updated units
    StorageService.saveCrusade(crusade);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Results committed! XP and tallies updated.'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to dashboard
    context.go('/dashboard');
  }

  UnitOrGroup? _findUnitInOOB(Crusade crusade, String unitId) {
    for (final unit in crusade.oob) {
      if (unit.id == unitId) return unit;
      // Check group components
      if (unit.type == 'group' && unit.components != null) {
        for (final component in unit.components!) {
          if (component.id == unitId) return component;
        }
      }
    }
    return null;
  }
}

/// Banner showing victory/defeat and score
class _ResultBanner extends StatelessWidget {
  final Game game;
  final bool isVictory;

  const _ResultBanner({required this.game, required this.isVictory});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: isVictory
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        border: Border(
          bottom: BorderSide(
            color: isVictory ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVictory ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: isVictory ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                isVictory ? 'VICTORY' : 'DEFEAT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isVictory ? Colors.green : Colors.red,
                ),
              ),
              if (game.playerScore != null || game.opponentScore != null)
                Text(
                  '${game.playerScore ?? 0} - ${game.opponentScore ?? 0}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section showing agenda recap
class _AgendaRecapSection extends StatelessWidget {
  final Game game;

  const _AgendaRecapSection({required this.game});

  @override
  Widget build(BuildContext context) {
    if (game.agendas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agenda Recap',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...game.agendas.map((agenda) => _AgendaRecapCard(agenda: agenda, game: game)),
      ],
    );
  }
}

class _AgendaRecapCard extends StatelessWidget {
  final GameAgenda agenda;
  final Game game;

  const _AgendaRecapCard({required this.agenda, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    agenda.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (agenda.type == AgendaType.tally)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB6C1).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Total: ${agenda.totalTallies}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            if (agenda.type == AgendaType.objective && agenda.maxUnits != null) ...[
              const SizedBox(height: 8),
              _buildObjectiveStatus(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveStatus() {
    if (agenda.assignedUnitIds.isEmpty) {
      return Text(
        'No unit assigned',
        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      );
    }

    final unitId = agenda.assignedUnitIds.first;
    final unitState = game.unitStates.where((u) => u.unitId == unitId).firstOrNull;
    final tier = agenda.unitTallies[unitId] ?? 0;

    return Row(
      children: [
        Text(
          unitState?.unitName ?? 'Unknown',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        const SizedBox(width: 8),
        if (tier > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Tier $tier',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Not achieved',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Section for marking a unit for greatness
class _MarkForGreatnessSection extends StatelessWidget {
  final Game game;
  final String? selectedUnitId;
  final Function(String?) onUnitSelected;

  const _MarkForGreatnessSection({
    required this.game,
    required this.selectedUnitId,
    required this.onUnitSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Mark for Greatness',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select one unit to receive +1 XP bonus',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.unitStates.map((unitState) {
            final isSelected = selectedUnitId == unitState.unitId;
            return ChoiceChip(
              label: Text(unitState.unitName),
              selected: isSelected,
              onSelected: (selected) {
                onUnitSelected(selected ? unitState.unitId : null);
              },
              selectedColor: Colors.amber.withValues(alpha: 0.3),
              side: BorderSide(
                color: isSelected ? Colors.amber : Colors.grey.shade600,
              ),
              avatar: isSelected ? const Icon(Icons.star, size: 16, color: Colors.amber) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Section showing unit summaries with editable kills and destroyed status
class _UnitSummarySection extends StatelessWidget {
  final Game game;
  final String? markedForGreatnessUnitId;
  final Function(String unitId, int newKills) onKillsChanged;
  final Function(String unitId, bool wasDestroyed) onDestroyedChanged;

  const _UnitSummarySection({
    required this.game,
    required this.markedForGreatnessUnitId,
    required this.onKillsChanged,
    required this.onDestroyedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unit Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Review and adjust unit performance before committing',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...game.unitStates.map((unitState) => _UnitSummaryCard(
          unitState: unitState,
          isMarkedForGreatness: markedForGreatnessUnitId == unitState.unitId,
          onKillsChanged: (newKills) => onKillsChanged(unitState.unitId, newKills),
          onDestroyedChanged: (wasDestroyed) => onDestroyedChanged(unitState.unitId, wasDestroyed),
        )),
      ],
    );
  }
}

class _UnitSummaryCard extends StatelessWidget {
  final UnitGameState unitState;
  final bool isMarkedForGreatness;
  final Function(int) onKillsChanged;
  final Function(bool) onDestroyedChanged;

  const _UnitSummaryCard({
    required this.unitState,
    required this.isMarkedForGreatness,
    required this.onKillsChanged,
    required this.onDestroyedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit name row
            Row(
              children: [
                if (isMarkedForGreatness) ...[
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    unitState.unitName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Destroyed status chip
                GestureDetector(
                  onTap: () => onDestroyedChanged(!unitState.wasDestroyed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: unitState.wasDestroyed
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: unitState.wasDestroyed
                            ? Colors.red.withValues(alpha: 0.5)
                            : Colors.green.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      unitState.wasDestroyed ? 'Destroyed' : 'Survived',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: unitState.wasDestroyed ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Kill tally row
            Row(
              children: [
                Text(
                  'Kills:',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: unitState.kills > 0 ? () => onKillsChanged(unitState.kills - 1) : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  color: Colors.grey.shade400,
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '${unitState.kills}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => onKillsChanged(unitState.kills + 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Commit button fixed at bottom
class _CommitButton extends StatelessWidget {
  final VoidCallback onCommit;

  const _CommitButton({required this.onCommit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCommit,
            icon: const Icon(Icons.check_circle),
            label: const Text('Commit Results'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB6C1),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
