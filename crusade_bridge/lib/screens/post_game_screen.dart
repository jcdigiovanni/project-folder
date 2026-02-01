import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../services/storage_service.dart';
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
          // Add battle scar to unit
          unit.scars.add(unitState.battleScarGained!);
        } else if (unitState.ooaOutcome == 'devastating_blow') {
          // Remove one Battle Honour (last one added)
          if (unit.honours.isNotEmpty) {
            final removedHonour = unit.honours.removeLast();
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

    // Save the crusade with updated units
    StorageService.saveCrusade(crusade);

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
