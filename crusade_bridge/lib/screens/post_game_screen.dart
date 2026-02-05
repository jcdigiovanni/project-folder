import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../services/google_drive_service.dart';

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
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load any existing marked for greatness selection and notes
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
        // Load existing notes
        if (game.notes != null) {
          _notesController.text = game.notes!;
        }
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
    final isDraw = game.result == GameResult.draw;

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
          _ResultBanner(game: game, isVictory: isVictory, isDraw: isDraw),

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

                // Unit Summary Section (with integrated XP preview and agenda controls)
                _UnitSummarySection(
                  game: game,
                  crusade: crusade!,
                  markedForGreatnessUnitId: _markedForGreatnessUnitId,
                  xpPreviews: _calculateXpPreviews(game, crusade),
                  onKillsChanged: (unitId, newKills) {
                    _updateKills(game, unitId, newKills);
                  },
                  onDestroyedChanged: (unitId, wasDestroyed) {
                    _updateDestroyed(game, unitId, wasDestroyed);
                  },
                  onAgendaTallyChanged: (agendaId, unitId, newTally) {
                    _updateAgendaTally(game, agendaId, unitId, newTally);
                  },
                ),
                const SizedBox(height: 24),

                // OOA Resolution Section (only if there are destroyed units)
                if (game.unitStates.any((u) => u.wasDestroyed))
                  _OOAResolutionSection(
                    game: game,
                    crusade: crusade,
                    onOOAResolved: () {
                      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
                      setState(() {}); // Refresh UI
                    },
                  ),
                if (game.unitStates.any((u) => u.wasDestroyed))
                  const SizedBox(height: 24),

                // Notes Section
                _NotesSection(
                  controller: _notesController,
                  onChanged: (value) => _updateNotes(game, value),
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

  void _updateAgendaTally(Game game, String agendaId, String unitId, int newTally) {
    final agenda = game.agendas.where((a) => a.id == agendaId).firstOrNull;
    if (agenda != null) {
      setState(() {
        if (newTally <= 0) {
          agenda.unitTallies.remove(unitId);
        } else {
          agenda.unitTallies[unitId] = newTally;
        }
      });
      ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
    }
  }

  void _updateNotes(Game game, String notes) {
    game.notes = notes.isEmpty ? null : notes;
    ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);
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

      // 3. Marked for Greatness XP: +3 XP bonus (10th ed rules)
      if (unitState.markedForGreatness) {
        xpGained += 3;
      }

      // 4. Agenda XP: Calculate XP from each agenda for this unit
      for (final agenda in game.agendas) {
        xpGained += agenda.calculateXpForUnit(unitState.unitId);
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

      // Apply OOA outcomes (battle scars or devastating blow)
      if (unitState.wasDestroyed && unitState.ooaTestResolved && unitState.ooaTestPassed == false) {
        if (unitState.ooaOutcome == 'battle_scar' && unitState.battleScarGained != null) {
          // Add battle scar to unit (-1 CP, min 0)
          unit.scars.add(unitState.battleScarGained!);
          if (unit.crusadePoints > 0) {
            unit.crusadePoints -= 1;
          }
        } else if (unitState.ooaOutcome == 'devastating_blow') {
          // Remove one Battle Honour (last one added)
          if (unit.honours.isNotEmpty) {
            final removedHonour = unit.honours.removeLast();
            // Decrement CP for lost honour (-1 CP, min 0)
            if (unit.crusadePoints > 0) {
              unit.crusadePoints -= 1;
            }
            // Also remove from specific lists if applicable
            if (removedHonour.startsWith('Trait: ')) {
              final traitName = removedHonour.substring(7);
              unit.battleTraits.remove(traitName);
            } else if (removedHonour.startsWith('Weapon: ')) {
              final weaponName = removedHonour.substring(8);
              unit.weaponEnhancements.remove(weaponName);
            } else if (removedHonour.startsWith('Relic: ')) {
              unit.crusadeRelic = null;
            } else if (removedHonour.startsWith('Psychic: ')) {
              final psychicName = removedHonour.substring(9);
              unit.battleTraits.remove(psychicName);
            }
          }
        }
      }
    }

    // Award +1 RP to the crusade for playing a battle (max 10)
    if (crusade.rp < 10) {
      crusade.rp += 1;
    }

    // Save the crusade with updated units via provider
    ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);

    // Log battle history event via provider (immutable pattern)
    final totalUnits = game.unitStates.length;
    final resultLabel = game.result == 'win' ? 'Victory' : game.result == 'loss' ? 'Defeat' : 'Draw';
    ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
      type: CrusadeEventType.battle,
      description: 'Battle: $resultLabel ($totalUnits units deployed)',
      metadata: {
        'gameId': game.id,
        'result': game.result,
        'unitsDeployed': totalUnits,
      },
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Results committed! XP and tallies updated.'),
        backgroundColor: Colors.green,
      ),
    );

    // Prompt for Drive backup if supported and signed in
    if (GoogleDriveService.isSupported && GoogleDriveService.isSignedIn) {
      _promptDriveBackup();
    } else {
      // Navigate to dashboard
      context.go('/dashboard');
    }
  }

  void _promptDriveBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup to Drive?'),
        content: const Text(
          'Would you like to backup your Crusade data to Google Drive?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backing up to Drive...')),
              );
              final success = await GoogleDriveService.backupCrusades();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Backup complete!'
                        : 'Backup failed. Check your connection.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                context.go('/dashboard');
              }
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  /// Calculate XP preview for all units without applying changes (ENH-010)
  List<_UnitXPPreview> _calculateXpPreviews(Game game, Crusade crusade) {
    final previews = <_UnitXPPreview>[];

    for (final unitState in game.unitStates) {
      final unit = _findUnitInOOB(crusade, unitState.unitId);
      if (unit == null) continue;

      // Epic Heroes don't gain XP
      if (unit.isEpicHero == true) {
        previews.add(_UnitXPPreview(
          unitName: unitState.unitName,
          participation: 0,
          killsXp: 0,
          markedXp: 0,
          agendaXp: 0,
          isEpicHero: true,
          killsThisGame: unitState.kills,
        ));
        continue;
      }

      // 1. Participation XP
      const participation = 1;

      // 2. Kill tally XP: 1 XP per 3 cumulative kills
      final previousKills = unit.tallies['kills'] ?? 0;
      final projectedTotalKills = previousKills + unitState.kills;
      final previousKillXP = previousKills ~/ 3;
      final newKillXP = projectedTotalKills ~/ 3;
      final killsXp = newKillXP - previousKillXP;

      // 3. Marked for Greatness
      final markedXp = unitState.markedForGreatness ? 3 : 0;

      // 4. Agenda XP
      int agendaXp = 0;
      for (final agenda in game.agendas) {
        agendaXp += agenda.calculateXpForUnit(unitState.unitId);
      }

      previews.add(_UnitXPPreview(
        unitName: unitState.unitName,
        participation: participation,
        killsXp: killsXp,
        markedXp: markedXp,
        agendaXp: agendaXp,
        isEpicHero: false,
        killsThisGame: unitState.kills,
      ));
    }

    return previews;
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

/// Banner showing victory/defeat/draw and score (ENH-007: added draw support)
class _ResultBanner extends StatelessWidget {
  final Game game;
  final bool isVictory;
  final bool isDraw;

  const _ResultBanner({required this.game, required this.isVictory, required this.isDraw});

  @override
  Widget build(BuildContext context) {
    // Determine colors and text based on result
    Color resultColor;
    IconData resultIcon;
    String resultText;

    if (isDraw) {
      resultColor = Colors.orange;
      resultIcon = Icons.handshake;
      resultText = 'DRAW';
    } else if (isVictory) {
      resultColor = Colors.green;
      resultIcon = Icons.emoji_events;
      resultText = 'VICTORY';
    } else {
      resultColor = Colors.red;
      resultIcon = Icons.sentiment_dissatisfied;
      resultText = 'DEFEAT';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.2),
        border: Border(
          bottom: BorderSide(
            color: resultColor,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            resultIcon,
            color: resultColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                resultText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
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

/// Section showing agenda recap with rewards summary
class _AgendaRecapSection extends StatefulWidget {
  final Game game;

  const _AgendaRecapSection({required this.game});

  @override
  State<_AgendaRecapSection> createState() => _AgendaRecapSectionState();
}

class _AgendaRecapSectionState extends State<_AgendaRecapSection> {
  bool _isExpanded = false;

  Game get game => widget.game;

  /// Calculate total VP from agendas
  int _calculateTotalVP() {
    int totalVP = 0;
    for (final agenda in game.agendas) {
      if (agenda.type == AgendaType.objective) {
        // VP rewards based on agenda ID and completion
        final tier = agenda.tier;
        if (tier > 0) {
          // Common VP rewards by agenda
          if (agenda.id.contains('behind_enemy_lines')) {
            totalVP += 3; // 3 VP if completed
          } else if (agenda.id.contains('secure_objective')) {
            totalVP += 2; // 2 VP if completed
          } else if (agenda.id.contains('domination')) {
            totalVP += 3; // 3 VP if completed
          } else {
            // Default: 1 VP per tier achieved
            totalVP += tier;
          }
        }
      }
    }
    return totalVP;
  }

  /// Get count of completed agendas
  int _getCompletedCount() {
    return game.agendas.where((a) {
      if (a.type == AgendaType.objective) {
        return a.tier > 0;
      } else {
        return a.totalTallies > 0;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    if (game.agendas.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedCount = _getCompletedCount();
    final totalVP = _calculateTotalVP();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tappable header row - toggles expand/collapse
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_outlined, size: 20, color: Color(0xFFFFB6C1)),
                const SizedBox(width: 8),
                const Text(
                  'Agenda Recap',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // Completion badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: completedCount == game.agendas.length
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount/${game.agendas.length} complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: completedCount == game.agendas.length ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),

        // Collapsed summary
        if (!_isExpanded) ...[
          const SizedBox(height: 4),
          Text(
            '${game.agendas.map((a) => a.name).join(", ")}${totalVP > 0 ? " \u2022 +$totalVP VP" : ""}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Expanded content
        if (_isExpanded) ...[
          const SizedBox(height: 8),

          // Summary row showing total VP earned
          if (totalVP > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.15),
                    Colors.amber.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Agenda VP Earned: +$totalVP VP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),

          // Agenda cards
          ...game.agendas.map((agenda) => _AgendaRecapCard(agenda: agenda, game: game)),
        ],
      ],
    );
  }
}

class _AgendaRecapCard extends StatelessWidget {
  final GameAgenda agenda;
  final Game game;

  const _AgendaRecapCard({required this.agenda, required this.game});

  /// Get the XP reward description for tally agendas
  String _getTallyXPReward() {
    final total = agenda.totalTallies;
    if (total == 0) return 'No progress';

    // Calculate XP based on agenda type
    if (agenda.id.contains('assassins')) {
      final xp = total.clamp(0, 3);
      return '+$xp XP ($total character${total != 1 ? 's' : ''} destroyed)';
    } else if (agenda.id.contains('reaper')) {
      final xp = total.clamp(0, 3);
      return '+$xp XP ($total unit${total != 1 ? 's' : ''} destroyed)';
    } else if (agenda.id.contains('cull_the_horde')) {
      final xp = total ~/ 10;
      return xp > 0 ? '+$xp XP ($total melee kills)' : '$total/10 toward 1 XP';
    } else if (agenda.id.contains('glory_seekers')) {
      // Count units with 3+ kills
      int unitsQualified = 0;
      for (final entry in agenda.unitTallies.entries) {
        if (entry.value >= 3) unitsQualified++;
      }
      return unitsQualified > 0
          ? '+$unitsQualified XP ($unitsQualified unit${unitsQualified != 1 ? 's' : ''} with 3+ kills)'
          : 'No units with 3+ kills';
    }

    return 'Total: $total';
  }

  /// Get the VP/XP reward for objective agendas
  String _getObjectiveReward() {
    final tier = agenda.tier;
    if (tier == 0) return 'Not achieved';

    // Known objective rewards
    if (agenda.id.contains('behind_enemy_lines')) {
      return '+3 VP';
    } else if (agenda.id.contains('kingslayer')) {
      return '+2 XP to destroyer';
    } else if (agenda.id.contains('survivor')) {
      if (tier >= 2) return '+2 XP (full strength)';
      return '+1 XP (survived)';
    } else if (agenda.id.contains('secure_objective')) {
      return '+2 VP';
    } else if (agenda.id.contains('priority_target')) {
      return '+2 XP to destroyer';
    } else if (agenda.id.contains('domination')) {
      return '+3 VP';
    } else if (agenda.id.contains('first_blood')) {
      return '+1 XP';
    }

    return 'Tier $tier achieved';
  }

  bool get _isCompleted {
    if (agenda.type == AgendaType.objective) {
      return agenda.tier > 0;
    }
    return agenda.totalTallies > 0;
  }

  @override
  Widget build(BuildContext context) {
    final isTally = agenda.type == AgendaType.tally;
    final isCompleted = _isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCompleted
          ? Colors.green.withValues(alpha: 0.05)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and type icon
            Row(
              children: [
                // Type icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isTally
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isTally ? Icons.leaderboard : Icons.emoji_events,
                    size: 14,
                    color: isTally ? Colors.blue : Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    agenda.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Completion status
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: isCompleted ? Colors.green : Colors.grey.shade600,
                ),
              ],
            ),

            // Description if available
            if (agenda.description != null) ...[
              const SizedBox(height: 6),
              Text(
                agenda.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],

            const SizedBox(height: 10),

            // Reward/Progress row
            if (isTally) ...[
              // Tally progress with reward
              Row(
                children: [
                  // Progress bar
                  Expanded(
                    child: _buildTallyProgressBar(),
                  ),
                  const SizedBox(width: 12),
                  // Reward badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: agenda.totalTallies > 0
                          ? const Color(0xFFFFB6C1).withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: agenda.totalTallies > 0
                            ? const Color(0xFFFFB6C1).withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getTallyXPReward(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: agenda.totalTallies > 0 ? const Color(0xFFFFB6C1) : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Objective status with unit and reward
              _buildObjectiveStatus(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTallyProgressBar() {
    final total = agenda.totalTallies;
    const maxDisplay = 10;
    final progress = (total / maxDisplay).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFB6C1),
                    const Color(0xFFFFB6C1).withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Total: $total',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildObjectiveStatus() {
    final tier = agenda.tier;
    final reward = _getObjectiveReward();

    // Get assigned unit info
    String? assignedUnitName;
    if (agenda.maxUnits != null && agenda.assignedUnitIds.isNotEmpty) {
      final unitId = agenda.assignedUnitIds.first;
      final unitState = game.unitStates.where((u) => u.unitId == unitId).firstOrNull;
      assignedUnitName = unitState?.unitName ?? 'Unknown';
    }

    return Row(
      children: [
        // Assigned unit (if applicable)
        if (agenda.maxUnits != null) ...[
          if (agenda.assignedUnitIds.isEmpty)
            Text(
              'No unit assigned',
              style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic, fontSize: 13),
            )
          else ...[
            Icon(Icons.person, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              assignedUnitName ?? 'Unknown',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
          const Spacer(),
        ] else
          const Spacer(),

        // Tier indicator for multi-tier objectives
        if (agenda.maxTier > 1) ...[
          ...List.generate(agenda.maxTier, (index) {
            final tierNum = index + 1;
            final isAchieved = tier >= tierNum;
            return Container(
              margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isAchieved
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isAchieved ? Colors.green : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: isAchieved
                    ? const Icon(Icons.check, size: 12, color: Colors.green)
                    : Text(
                        '$tierNum',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
              ),
            );
          }),
          const SizedBox(width: 8),
        ],

        // Reward badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: tier > 0
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tier > 0
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            reward,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: tier > 0 ? Colors.green : Colors.grey.shade500,
            ),
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
          'Select one unit to receive +3 XP bonus',
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
  final Crusade crusade;
  final String? markedForGreatnessUnitId;
  final List<_UnitXPPreview> xpPreviews;
  final Function(String unitId, int newKills) onKillsChanged;
  final Function(String unitId, bool wasDestroyed) onDestroyedChanged;
  final Function(String agendaId, String unitId, int newTally) onAgendaTallyChanged;

  const _UnitSummarySection({
    required this.game,
    required this.crusade,
    required this.markedForGreatnessUnitId,
    required this.xpPreviews,
    required this.onKillsChanged,
    required this.onDestroyedChanged,
    required this.onAgendaTallyChanged,
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
        ...game.unitStates.map((unitState) {
          // Find matching XP preview for this unit
          final preview = xpPreviews.where((p) => p.unitName == unitState.unitName).firstOrNull;
          return _UnitSummaryCard(
            unitState: unitState,
            game: game,
            isMarkedForGreatness: markedForGreatnessUnitId == unitState.unitId,
            xpPreview: preview,
            onKillsChanged: (newKills) => onKillsChanged(unitState.unitId, newKills),
            onDestroyedChanged: (wasDestroyed) => onDestroyedChanged(unitState.unitId, wasDestroyed),
            onAgendaTallyChanged: (agendaId, newTally) => onAgendaTallyChanged(agendaId, unitState.unitId, newTally),
          );
        }),
      ],
    );
  }
}

class _UnitSummaryCard extends StatelessWidget {
  final UnitGameState unitState;
  final Game game;
  final bool isMarkedForGreatness;
  final _UnitXPPreview? xpPreview;
  final Function(int) onKillsChanged;
  final Function(bool) onDestroyedChanged;
  final Function(String agendaId, int newTally) onAgendaTallyChanged;

  const _UnitSummaryCard({
    required this.unitState,
    required this.game,
    required this.isMarkedForGreatness,
    required this.xpPreview,
    required this.onKillsChanged,
    required this.onDestroyedChanged,
    required this.onAgendaTallyChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Get tally agendas relevant to this unit
    final tallyAgendas = game.agendas.where((a) => a.type == AgendaType.tally).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit name row with XP badge
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
                // XP preview badge
                if (xpPreview != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: xpPreview!.isEpicHero
                          ? Colors.purple.withValues(alpha: 0.2)
                          : Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: xpPreview!.isEpicHero
                            ? Colors.purple.withValues(alpha: 0.5)
                            : Colors.amber.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      xpPreview!.isEpicHero ? 'Epic Hero' : '+${xpPreview!.totalXp} XP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: xpPreview!.isEpicHero ? Colors.purple : Colors.amber,
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
            const SizedBox(height: 10),

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

            // Per-unit agenda tally controls (ENH-011)
            if (tallyAgendas.isNotEmpty) ...[
              const SizedBox(height: 6),
              Divider(color: Colors.grey.shade800, height: 1),
              const SizedBox(height: 8),
              Text(
                'Agenda Tallies',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 4),
              ...tallyAgendas.map((agenda) {
                final tally = agenda.unitTallies[unitState.unitId] ?? 0;
                final agendaXp = agenda.calculateXpForUnit(unitState.unitId);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          agenda.name,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 16),
                        onPressed: tally > 0 ? () => onAgendaTallyChanged(agenda.id, tally - 1) : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        iconSize: 16,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$tally',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 16),
                        onPressed: () => onAgendaTallyChanged(agenda.id, tally + 1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        iconSize: 16,
                        color: Colors.grey.shade500,
                      ),
                      if (agendaXp > 0)
                        Text(
                          '+${agendaXp}XP',
                          style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w500),
                        )
                      else
                        Text(
                          '0XP',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                );
              }),
            ],

            // XP breakdown (compact, below controls)
            if (xpPreview != null && !xpPreview!.isEpicHero) ...[
              const SizedBox(height: 6),
              Divider(color: Colors.grey.shade800, height: 1),
              const SizedBox(height: 6),
              Row(
                children: [
                  _XPBreakdownChip(label: 'Battle', value: xpPreview!.participation),
                  const SizedBox(width: 6),
                  _XPBreakdownChip(label: 'Kills', value: xpPreview!.killsXp),
                  if (xpPreview!.markedXp > 0) ...[
                    const SizedBox(width: 6),
                    _XPBreakdownChip(label: 'Marked', value: xpPreview!.markedXp),
                  ],
                  if (xpPreview!.agendaXp > 0) ...[
                    const SizedBox(width: 6),
                    _XPBreakdownChip(label: 'Agendas', value: xpPreview!.agendaXp),
                  ],
                ],
              ),
            ] else if (xpPreview != null && xpPreview!.isEpicHero) ...[
              const SizedBox(height: 4),
              Text(
                'Epic Heroes do not gain XP',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact chip for XP breakdown display within unit cards
class _XPBreakdownChip extends StatelessWidget {
  final String label;
  final int value;

  const _XPBreakdownChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: value > 0
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: value > 0
              ? Colors.grey.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        '$label +$value',
        style: TextStyle(
          fontSize: 10,
          color: value > 0 ? Colors.grey.shade300 : Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Section for optional game notes
class _NotesSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _NotesSection({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notes, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Game Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Optional notes about the battle',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add notes about this battle...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFB6C1)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Section for Out of Action (OOA) test resolution
class _OOAResolutionSection extends StatefulWidget {
  final Game game;
  final Crusade? crusade;
  final VoidCallback onOOAResolved;

  const _OOAResolutionSection({
    required this.game,
    required this.crusade,
    required this.onOOAResolved,
  });

  @override
  State<_OOAResolutionSection> createState() => _OOAResolutionSectionState();
}

class _OOAResolutionSectionState extends State<_OOAResolutionSection> {
  Map<String, dynamic>? _battleScarsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBattleScarsData();
  }

  Future<void> _loadBattleScarsData() async {
    try {
      final jsonString = await DefaultAssetBundle.of(context).loadString('assets/data/battle_honours.json');
      final data = Map<String, dynamic>.from(
        (const JsonDecoder().convert(jsonString)) as Map,
      );
      if (mounted) {
        setState(() {
          _battleScarsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<UnitGameState> get _destroyedUnits =>
      widget.game.unitStates.where((u) => u.wasDestroyed).toList();

  bool get _allOOAResolved =>
      _destroyedUnits.every((u) => u.ooaTestResolved);

  UnitOrGroup? _findUnit(String unitId) {
    if (widget.crusade == null) return null;
    for (final unit in widget.crusade!.oob) {
      if (unit.id == unitId) return unit;
      if (unit.type == 'group' && unit.components != null) {
        for (final component in unit.components!) {
          if (component.id == unitId) return component;
        }
      }
    }
    return null;
  }

  bool _shouldAutoPass(UnitGameState unitState) {
    final unit = _findUnit(unitState.unitId);
    if (unit == null) return false;
    // Epic Heroes auto-pass OOA tests
    return unit.isEpicHero == true;
  }

  void _runOOATest(UnitGameState unitState) {
    final unit = _findUnit(unitState.unitId);
    if (unit == null) return;

    // Check for auto-pass (Epic Hero)
    if (_shouldAutoPass(unitState)) {
      setState(() {
        unitState.ooaTestResolved = true;
        unitState.ooaTestPassed = true;
        unitState.ooaTestRoll = null; // Auto-pass, no roll
      });
      widget.onOOAResolved();
      return;
    }

    // Show dice roll modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _OOATestModal(
        unitState: unitState,
        unit: unit,
        battleScarsData: _battleScarsData,
        onResolved: () {
          setState(() {});
          widget.onOOAResolved();
        },
      ),
    );
  }

  void _runAllOOATests() {
    // Process each destroyed unit that hasn't been resolved
    for (final unitState in _destroyedUnits) {
      if (!unitState.ooaTestResolved) {
        if (_shouldAutoPass(unitState)) {
          unitState.ooaTestResolved = true;
          unitState.ooaTestPassed = true;
          unitState.ooaTestRoll = null;
        }
      }
    }
    setState(() {});
    widget.onOOAResolved();

    // Show modal for remaining units that need manual resolution
    final needsManualResolution = _destroyedUnits.where((u) => !u.ooaTestResolved).toList();
    if (needsManualResolution.isNotEmpty) {
      _runOOATest(needsManualResolution.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.healing, color: Colors.orange.shade400, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Out of Action Tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_allOOAResolved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('Complete', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Destroyed units must take an Out of Action test (D6 roll of 2+ to pass)',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // Run All button if not all resolved
        if (!_allOOAResolved)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: _runAllOOATests,
              icon: const Icon(Icons.casino),
              label: const Text('Run All OOA Tests'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),

        // List of destroyed units
        ..._destroyedUnits.map((unitState) => _OOAUnitCard(
          unitState: unitState,
          unit: _findUnit(unitState.unitId),
          isAutoPass: _shouldAutoPass(unitState),
          onRunTest: () => _runOOATest(unitState),
        )),
      ],
    );
  }
}

/// Card showing a single unit's OOA status
class _OOAUnitCard extends StatelessWidget {
  final UnitGameState unitState;
  final UnitOrGroup? unit;
  final bool isAutoPass;
  final VoidCallback onRunTest;

  const _OOAUnitCard({
    required this.unitState,
    required this.unit,
    required this.isAutoPass,
    required this.onRunTest,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved = unitState.ooaTestResolved;
    final passed = unitState.ooaTestPassed ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isResolved
          ? (passed ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1))
          : null,
      child: ListTile(
        leading: Icon(
          isResolved
              ? (passed ? Icons.check_circle : Icons.cancel)
              : Icons.help_outline,
          color: isResolved
              ? (passed ? Colors.green : Colors.red)
              : Colors.orange,
        ),
        title: Text(unitState.unitName),
        subtitle: _buildSubtitle(),
        trailing: isResolved
            ? _buildResolvedBadge(passed)
            : TextButton(
                onPressed: onRunTest,
                child: Text(isAutoPass ? 'Auto-Pass' : 'Roll Test'),
              ),
      ),
    );
  }

  Widget _buildSubtitle() {
    if (!unitState.ooaTestResolved) {
      if (isAutoPass) {
        return const Text('Epic Hero - Automatic pass', style: TextStyle(color: Colors.amber));
      }
      return const Text('Awaiting OOA test');
    }

    final passed = unitState.ooaTestPassed ?? false;
    if (passed) {
      if (unitState.ooaTestRoll != null) {
        return Text('Rolled ${unitState.ooaTestRoll} - Passed!');
      }
      return const Text('Auto-passed (Epic Hero)');
    }

    // Failed
    String outcome = 'Rolled ${unitState.ooaTestRoll} - Failed!';
    if (unitState.ooaOutcome == 'devastating_blow') {
      outcome += ' (Devastating Blow)';
    } else if (unitState.ooaOutcome == 'battle_scar' && unitState.battleScarGained != null) {
      outcome += '\nScar: ${unitState.battleScarGained}';
    }
    return Text(outcome, style: const TextStyle(color: Colors.red));
  }

  Widget _buildResolvedBadge(bool passed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: passed ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        passed ? 'Passed' : 'Failed',
        style: TextStyle(
          color: passed ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Modal for running OOA test with dice roll
class _OOATestModal extends StatefulWidget {
  final UnitGameState unitState;
  final UnitOrGroup unit;
  final Map<String, dynamic>? battleScarsData;
  final VoidCallback onResolved;

  const _OOATestModal({
    required this.unitState,
    required this.unit,
    required this.battleScarsData,
    required this.onResolved,
  });

  @override
  State<_OOATestModal> createState() => _OOATestModalState();
}

class _OOATestModalState extends State<_OOATestModal> {
  int? _rollResult;
  bool _isRolling = false;
  bool _showOutcomeChoice = false;
  String? _selectedOutcome;
  String? _scarResult;
  int? _scarRoll;

  bool get _testPassed => _rollResult != null && _rollResult! >= 2;
  bool get _testFailed => _rollResult != null && _rollResult == 1;

  void _rollDice() async {
    setState(() => _isRolling = true);

    // Animate through random values
    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() {
        _rollResult = (DateTime.now().millisecondsSinceEpoch % 6) + 1;
      });
    }

    // Final roll
    final random = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _rollResult = (random % 6) + 1;
      _isRolling = false;
      if (_testFailed) {
        _showOutcomeChoice = true;
      }
    });
  }

  void _selectOutcome(String outcome) {
    setState(() {
      _selectedOutcome = outcome;
      if (outcome == 'battle_scar') {
        // Auto-roll for battle scar
        _rollForScar();
      }
    });
  }

  void _rollForScar() async {
    setState(() => _isRolling = true);

    // Animate
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() {
        _scarRoll = (DateTime.now().millisecondsSinceEpoch % 6) + 1;
      });
    }

    // Final roll
    final roll = (DateTime.now().millisecondsSinceEpoch % 6) + 1;
    setState(() {
      _scarRoll = roll;
      _isRolling = false;

      // Find scar from table
      final scarsTable = widget.battleScarsData?['battleScars']?['table'] as List?;
      if (scarsTable != null) {
        for (final scar in scarsTable) {
          if (scar['roll'] == roll) {
            _scarResult = scar['name'] as String;
            break;
          }
        }
      }
      _scarResult ??= 'Unknown Scar';
    });
  }

  void _confirmResult() {
    // Update unit state
    widget.unitState.ooaTestResolved = true;
    widget.unitState.ooaTestRoll = _rollResult;
    widget.unitState.ooaTestPassed = _testPassed;

    if (_testFailed) {
      widget.unitState.ooaOutcome = _selectedOutcome;
      if (_selectedOutcome == 'battle_scar') {
        widget.unitState.battleScarGained = _scarResult;
      }
    }

    widget.onResolved();
    Navigator.pop(context);
  }

  bool get _canConfirm {
    if (_rollResult == null) return false;
    if (_testPassed) return true;
    if (_testFailed && _selectedOutcome != null) {
      if (_selectedOutcome == 'battle_scar') {
        return _scarResult != null;
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Out of Action Test',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.unitState.unitName,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // Dice display
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _rollResult != null
                  ? (_testPassed ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2))
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _rollResult != null
                    ? (_testPassed ? Colors.green : Colors.red)
                    : colorScheme.outline,
                width: 3,
              ),
            ),
            child: Center(
              child: _rollResult != null
                  ? Text(
                      '$_rollResult',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _testPassed ? Colors.green : Colors.red,
                      ),
                    )
                  : Icon(Icons.casino, size: 40, color: colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),

          // Result text
          if (_rollResult != null)
            Text(
              _testPassed ? 'Passed! (2+ required)' : 'Failed! (Rolled 1)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _testPassed ? Colors.green : Colors.red,
              ),
            ),

          const SizedBox(height: 24),

          // Outcome choice (if failed)
          if (_showOutcomeChoice && !_testPassed) ...[
            const Text(
              'Choose your fate:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OutcomeCard(
                    title: 'Devastating Blow',
                    description: 'Lose one Battle Honour',
                    icon: Icons.auto_awesome_mosaic,
                    color: Colors.purple,
                    isSelected: _selectedOutcome == 'devastating_blow',
                    onTap: widget.unit.honours.isNotEmpty
                        ? () => _selectOutcome('devastating_blow')
                        : null,
                    isDisabled: widget.unit.honours.isEmpty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutcomeCard(
                    title: 'Battle Scar',
                    description: 'Gain a permanent scar',
                    icon: Icons.healing,
                    color: Colors.red,
                    isSelected: _selectedOutcome == 'battle_scar',
                    onTap: () => _selectOutcome('battle_scar'),
                  ),
                ),
              ],
            ),
          ],

          // Scar result (if battle scar selected)
          if (_selectedOutcome == 'battle_scar' && _scarResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Text('Rolled: $_scarRoll', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    _scarResult!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          if (_rollResult == null)
            FilledButton.icon(
              onPressed: _isRolling ? null : _rollDice,
              icon: _isRolling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.casino),
              label: Text(_isRolling ? 'Rolling...' : 'Roll D6'),
            )
          else
            FilledButton.icon(
              onPressed: _canConfirm ? _confirmResult : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirm'),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Card for outcome selection
class _OutcomeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _OutcomeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Card(
        color: isSelected ? color.withValues(alpha: 0.2) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.grey : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isDisabled ? 'No honours to lose' : description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDisabled ? Colors.grey : Colors.grey.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for XP preview per unit (ENH-010)
class _UnitXPPreview {
  final String unitName;
  final int participation;
  final int killsXp;
  final int markedXp;
  final int agendaXp;
  final bool isEpicHero;
  final int killsThisGame;

  const _UnitXPPreview({
    required this.unitName,
    required this.participation,
    required this.killsXp,
    required this.markedXp,
    required this.agendaXp,
    required this.isEpicHero,
    required this.killsThisGame,
  });

  int get totalXp => participation + killsXp + markedXp + agendaXp;
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
