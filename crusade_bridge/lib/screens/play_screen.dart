import 'dart:convert';

import '../common.dart';
import '../models/combat_elixirs.dart';
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
  bool _didCheckForActiveGame = false;

  @override
  void initState() {
    super.initState();
    // Check for active game only once when screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForActiveGame();
    });
  }

  void _checkForActiveGame() {
    if (_didCheckForActiveGame) return;
    _didCheckForActiveGame = true;

    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    // Check for in-progress game first
    final activeGame = currentCrusade.games.where((g) => g.isInProgress).firstOrNull;
    if (activeGame != null && mounted) {
      _showActiveGameDialog(context, activeGame);
      return;
    }

    // Check for completed but uncommitted game
    final uncommittedGame = currentCrusade.games.where((g) => g.needsCommit).firstOrNull;
    if (uncommittedGame != null && mounted) {
      _showUncommittedGameDialog(context, uncommittedGame);
    }
  }

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
                style: actionButtonStyle(),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => context.go('/oob'),
                icon: const Icon(Icons.military_tech),
                label: const Text('Build Order of Battle'),
                style: actionButtonStyle(),
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
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/landing'),
              icon: const Icon(Icons.folder_open),
              label: const Text('Load Army'),
            ),
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
                            color: kAccentPink,
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

  void _showActiveGameDialog(BuildContext context, Game activeGame) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game In Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have an active game:',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: kAccentPink.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeGame.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activeGame.agendas.length} agendas • ${activeGame.unitStates.length} units',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Would you like to return to your game in progress?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/game/${activeGame.id}');
            },
            style: TextButton.styleFrom(foregroundColor: kAccentPink),
            child: const Text('Return to Game'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEndBattleConfirmation(context, activeGame);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade300),
            child: const Text('End Battle'),
          ),
        ],
      ),
    );
  }

  void _showEndBattleConfirmation(BuildContext context, Game activeGame) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Battle?'),
        content: const Text(
          'Are you sure you want to end this battle? '
          'Any unrecorded progress will be lost and the game will be marked as incomplete.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endBattle(activeGame);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Battle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUncommittedGameDialog(BuildContext context, Game uncommittedGame) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Uncommitted Post-Game'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have a completed game that hasn\'t been committed:',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uncommittedGame.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${uncommittedGame.unitStates.length} units • XP and tallies not yet applied',
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Would you like to return to the post-game review to commit your results?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/postgame/${uncommittedGame.id}');
            },
            style: TextButton.styleFrom(foregroundColor: kAccentPink),
            child: const Text('Return to Post-Game'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }

  void _endBattle(Game game) {
    game.completedAt = DateTime.now().millisecondsSinceEpoch;
    game.result = GameResult.draw; // Mark as draw/incomplete
    ref.read(currentCrusadeNotifierProvider.notifier).updateGame(game);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Battle ended. You can now start a new game.'),
        backgroundColor: Colors.orange,
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
              _showAgendaSelectionDialog(context, roster, totalPoints, totalCP);
            },
            style: TextButton.styleFrom(foregroundColor: kAccentPink),
            child: const Text('Deploy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Load available agendas from modular JSON files
  /// Loads core agendas (universal) + faction-specific agendas if player faction matches
  Future<List<GameAgenda>> _loadAvailableAgendas(BuildContext context, String? playerFaction) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final allAgendas = <GameAgenda>[];

    // Helper to parse agenda JSON into GameAgenda objects
    List<GameAgenda> parseAgendas(List<dynamic> agendasList) {
      return agendasList.map((agendaData) {
        final a = agendaData as Map<String, dynamic>;
        return GameAgenda(
          id: '${a['id']}_$timestamp',
          name: a['name'] as String,
          type: a['type'] as String,
          description: a['description'] as String?,
          maxTier: a['maxTier'] as int? ?? 1,
          maxUnits: a['maxUnits'] as int?,
          xpPerTally: a['xpPerTally'] as int?,
          tallyDivisor: a['tallyDivisor'] as int?,
          maxXp: a['maxXp'] as int?,
          xpPerTier: a['xpPerTier'] as int?,
        );
      }).toList();
    }

    // 1. Load core agendas (universal, always available)
    try {
      final coreJson = await DefaultAssetBundle.of(context).loadString('assets/data/agendas/core.json');
      final coreData = json.decode(coreJson) as Map<String, dynamic>;
      allAgendas.addAll(parseAgendas(coreData['agendas'] as List<dynamic>));
    } catch (e) {
      // Core agendas failed to load
    }

    // 2. Load faction-specific agendas if player has a faction
    if (playerFaction != null && playerFaction.isNotEmpty) {
      final factionFileName = playerFaction.toLowerCase().replaceAll(' ', '_').replaceAll("'", '');
      try {
        final factionJson = await DefaultAssetBundle.of(context).loadString('assets/data/agendas/$factionFileName.json');
        final factionData = json.decode(factionJson) as Map<String, dynamic>;
        allAgendas.addAll(parseAgendas(factionData['agendas'] as List<dynamic>));
      } catch (e) {
        // No faction-specific agendas for this faction (expected for most factions)
      }
    }

    return allAgendas;
  }

  void _showAgendaSelectionDialog(BuildContext context, Roster roster, int totalPoints, int totalCP) async {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    final playerFaction = currentCrusade?.faction;
    final availableAgendas = await _loadAvailableAgendas(context, playerFaction);
    if (!mounted) return;
    final selectedAgendas = <GameAgenda>[];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Agendas'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose up to 2 agendas for this battle',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Scrollable agenda list (or empty state message)
                Expanded(
                  child: availableAgendas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.playlist_remove, size: 48, color: Colors.grey.shade600),
                              const SizedBox(height: 16),
                              Text(
                                'No Agendas Available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Agenda data is being updated.\nYou can still start a game without agendas.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                    itemCount: availableAgendas.length,
                    itemBuilder: (context, index) {
                      final agenda = availableAgendas[index];
                      final isSelected = selectedAgendas.any((a) => a.id == agenda.id);
                      final canSelect = selectedAgendas.length < 2 || isSelected;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected
                            ? kAccentPink.withValues(alpha: 0.15)
                            : null,
                        child: InkWell(
                          onTap: canSelect
                              ? () {
                                  setDialogState(() {
                                    if (isSelected) {
                                      selectedAgendas.removeWhere((a) => a.id == agenda.id);
                                    } else {
                                      selectedAgendas.add(agenda);
                                    }
                                  });
                                }
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? kAccentPink
                                      : canSelect
                                          ? Colors.grey
                                          : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              agenda.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: canSelect ? null : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: agenda.type == AgendaType.tally
                                                  ? Colors.blue.withValues(alpha: 0.2)
                                                  : Colors.orange.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              agenda.type == AgendaType.tally ? 'Tally' : 'Tiered',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: agenda.type == AgendaType.tally
                                                    ? Colors.blue.shade300
                                                    : Colors.orange.shade300,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (agenda.description != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          agenda.description!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: canSelect
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${selectedAgendas.length}/2 selected',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              // Allow starting without agendas if none are available, otherwise require selection
              onPressed: (selectedAgendas.isNotEmpty || availableAgendas.isEmpty)
                  ? () {
                      Navigator.pop(context);
                      final crusade = ref.read(currentCrusadeNotifierProvider);
                      if (crusade?.faction == "Emperor's Children") {
                        _showElixirEquipDialog(context, roster, totalPoints, totalCP, selectedAgendas);
                      } else {
                        _startGame(context, roster, totalPoints, totalCP, selectedAgendas);
                      }
                    }
                  : null,
              style: TextButton.styleFrom(foregroundColor: kAccentPink),
              child: Text(availableAgendas.isEmpty ? 'Start Without Agendas' : 'Start Game'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, Roster roster, int totalPoints, int totalCP, List<GameAgenda> selectedAgendas, {EquippedElixirs? equippedElixirs}) {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    // Create the game
    final gameId = 'game_${DateTime.now().millisecondsSinceEpoch}';
    final game = Game(
      id: gameId,
      name: '${_selectedBattleSize!.name} - ${DateTime.now().day}/${DateTime.now().month}',
      rosterId: roster.id,
      battleSize: _selectedBattleSize!.name.toLowerCase().replaceAll(' ', '_'),
      rosterPoints: totalPoints,
      rosterCrusadePoints: totalCP,
      agendas: selectedAgendas,
      equippedElixirsJson: equippedElixirs?.toJsonString(),
    );

    // Initialize unit states from the roster
    final rosterUnits = roster.getUnits(currentCrusade.oob);
    game.initializeUnitStates(rosterUnits);

    // If elixirs were equipped, deduct from stash
    if (equippedElixirs != null && !equippedElixirs.isEmpty) {
      final stash = currentCrusade.combatElixirsStash ?? CombatElixirsStash.empty();
      for (final key in equippedElixirs.armyElixirs) {
        if ((stash.armyElixirs[key] ?? 0) > 0) {
          stash.armyElixirs[key] = stash.armyElixirs[key]! - 1;
          if (stash.armyElixirs[key] == 0) stash.armyElixirs.remove(key);
        }
      }
      for (final key in equippedElixirs.personalElixirs.values) {
        if ((stash.personalElixirs[key] ?? 0) > 0) {
          stash.personalElixirs[key] = stash.personalElixirs[key]! - 1;
          if (stash.personalElixirs[key] == 0) stash.personalElixirs.remove(key);
        }
      }
      currentCrusade.combatElixirsStash = stash;
    }

    // Save the game
    ref.read(currentCrusadeNotifierProvider.notifier).addGame(game);

    // Navigate to active game screen
    context.go('/game/$gameId');
  }

  void _showElixirEquipDialog(BuildContext context, Roster roster, int totalPoints, int totalCP, List<GameAgenda> selectedAgendas) async {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    final elixirData = await loadElixirData();
    if (!mounted) return;

    final stash = currentCrusade.combatElixirsStash ?? CombatElixirsStash.empty();
    final rosterUnits = roster.getUnits(currentCrusade.oob);
    final characters = rosterUnits.where((u) => u.isCharacter == true).toList();

    // State for selection
    final selectedArmy = <String>{};
    final selectedPersonal = <String, String>{}; // unitId → elixir key

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final totalEquipped = selectedArmy.length + selectedPersonal.length;
          final cpCost = totalEquipped > 0 ? (totalEquipped / 2).ceil() : 0;
          final noElixirs = stash.totalElixirDoses == 0;

          return AlertDialog(
            title: const Text('Equip Combat Elixirs'),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.65,
              child: ListView(
                children: [
                  // Warning: no elixirs equipped = Battle-shocked Round 1
                  if (totalEquipped == 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Without elixirs, all EC units are Battle-shocked in Round 1.',
                              style: TextStyle(color: Colors.orange, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // CP cost indicator
                  if (totalEquipped > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Equipped: $totalEquipped elixir${totalEquipped == 1 ? '' : 's'} (+$cpCost Crusade Points)',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ),

                  // ── Army Elixirs ──
                  Text(
                    'Army Elixirs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.purple.shade200,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apply to all EMPEROR\'S CHILDREN units',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...elixirData.armyElixirs.map((elixir) {
                    final doses = stash.armyElixirs[elixir.key] ?? 0;
                    final blocked = stash.wasUsedLastBattle(elixir.key);
                    final available = doses > 0 && !blocked;
                    final isSelected = selectedArmy.contains(elixir.key);

                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: isSelected,
                      onChanged: available
                          ? (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedArmy.add(elixir.key);
                                } else {
                                  selectedArmy.remove(elixir.key);
                                }
                              });
                            }
                          : null,
                      title: Text(
                        '${elixir.label} ($doses dose${doses == 1 ? '' : 's'})',
                        style: TextStyle(
                          fontSize: 14,
                          color: available ? null : Colors.grey.shade600,
                          decoration: blocked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        blocked
                            ? 'Used last battle — cannot equip consecutively'
                            : elixir.effect,
                        style: TextStyle(
                          fontSize: 11,
                          color: blocked ? Colors.red.shade300 : Colors.grey.shade500,
                        ),
                      ),
                      activeColor: Colors.purple,
                    );
                  }),

                  const Divider(height: 24),

                  // ── Personal Elixirs ──
                  Text(
                    'Personal Elixirs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal.shade200,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assign one to each CHARACTER',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  if (characters.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No CHARACTER units in this roster.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    )
                  else
                    ...characters.map((unit) {
                      final assignedKey = selectedPersonal[unit.id];
                      // Build available personal elixir options for dropdown
                      final availableOptions = <DropdownMenuItem<String?>>[];
                      availableOptions.add(const DropdownMenuItem(
                        value: null,
                        child: Text('None', style: TextStyle(fontSize: 13)),
                      ));
                      for (final pElixir in elixirData.personalElixirs) {
                        final doses = stash.personalElixirs[pElixir.key] ?? 0;
                        final blocked = stash.wasUsedLastBattle(pElixir.key);
                        // Available if has doses, not blocked, and not already assigned to another unit
                        final assignedElsewhere = selectedPersonal.entries
                            .any((e) => e.key != unit.id && e.value == pElixir.key);
                        final usable = doses > 0 && !blocked && !assignedElsewhere;
                        // Show if currently assigned to this unit OR usable
                        if (usable || assignedKey == pElixir.key) {
                          availableOptions.add(DropdownMenuItem(
                            value: pElixir.key,
                            child: Text(
                              '${pElixir.label} ($doses)',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ));
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                unit.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String?>(
                                value: assignedKey,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  border: OutlineInputBorder(),
                                ),
                                items: availableOptions,
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == null) {
                                      selectedPersonal.remove(unit.id);
                                    } else {
                                      selectedPersonal[unit.id] = val;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  // Personal elixir effects reference
                  if (selectedPersonal.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...selectedPersonal.entries.map((e) {
                      final unitName = characters.where((u) => u.id == e.key).firstOrNull?.name ?? '?';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '$unitName: ${elixirData.elixirEffect(e.value) ?? e.value}',
                          style: TextStyle(fontSize: 11, color: Colors.teal.shade300),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            actions: [
              if (noElixirs)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startGame(context, roster, totalPoints, totalCP, selectedAgendas);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  child: const Text('Skip (No Elixirs)'),
                )
              else
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startGame(context, roster, totalPoints, totalCP, selectedAgendas);
                  },
                  child: const Text('Skip'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final equipped = EquippedElixirs(
                    armyElixirs: selectedArmy.toList(),
                    personalElixirs: selectedPersonal,
                  );
                  _startGame(context, roster, totalPoints, totalCP, selectedAgendas, equippedElixirs: equipped);
                },
                style: TextButton.styleFrom(foregroundColor: kAccentPink),
                child: Text(totalEquipped > 0 ? 'Equip & Start' : 'Start Game'),
              ),
            ],
          );
        },
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
                  color: kAccentPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  battleSize.icon,
                  size: 28,
                  color: kAccentPink,
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
