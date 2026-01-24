import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crusade_models.dart';
import '../providers/crusade_provider.dart';
import '../widgets/army_avatar.dart';
import '../utils/snackbar_utils.dart';

class RosterBuildScreen extends ConsumerStatefulWidget {
  final String rosterId;

  const RosterBuildScreen({super.key, required this.rosterId});

  @override
  ConsumerState<RosterBuildScreen> createState() => _RosterBuildScreenState();
}

class _RosterBuildScreenState extends ConsumerState<RosterBuildScreen> {
  late TextEditingController _nameController;
  late Set<String> _selectedUnitIds;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedUnitIds = {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initializeFromRoster(Roster roster) {
    if (!_isInitialized) {
      _nameController.text = roster.name;
      _selectedUnitIds = Set.from(roster.unitIds);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Build Roster')),
        body: const Center(child: Text('No Crusade loaded.')),
      );
    }

    final roster = currentCrusade.rosters.where((r) => r.id == widget.rosterId).firstOrNull;

    if (roster == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Build Roster')),
        body: const Center(child: Text('Roster not found.')),
      );
    }

    _initializeFromRoster(roster);

    final oob = currentCrusade.oob;
    final selectedUnits = oob.where((u) => _selectedUnitIds.contains(u.id)).toList();
    final availableUnits = oob.where((u) => !_selectedUnitIds.contains(u.id)).toList();
    final totalPoints = selectedUnits.fold<int>(0, (sum, u) => sum + u.points);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Roster'),
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
      body: Column(
        children: [
          // Roster name and summary header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              children: [
                // Roster name field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Roster Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Points summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedUnits.length} units selected',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$totalPoints pts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: totalPoints > currentCrusade.supplyLimit
                            ? Colors.red
                            : const Color(0xFFFFB6C1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Two-panel layout
          Expanded(
            child: Row(
              children: [
                // Left panel - Available units
                Expanded(
                  child: _UnitPanel(
                    title: 'Available Units',
                    titleColor: Colors.grey,
                    units: availableUnits,
                    emptyMessage: 'All units in roster',
                    onUnitTap: (unit) {
                      setState(() {
                        _selectedUnitIds.add(unit.id);
                      });
                    },
                    actionIcon: Icons.add_circle,
                    actionColor: Colors.green,
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                // Right panel - Roster units
                Expanded(
                  child: _UnitPanel(
                    title: 'In Roster',
                    titleColor: Colors.green,
                    units: selectedUnits,
                    emptyMessage: 'Tap units to add',
                    onUnitTap: (unit) {
                      setState(() {
                        _selectedUnitIds.remove(unit.id);
                      });
                    },
                    actionIcon: Icons.remove_circle,
                    actionColor: Colors.red,
                  ),
                ),
              ],
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
                child: OutlinedButton(
                  onPressed: () => context.go('/rosters'),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _saveRoster(roster),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Roster'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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

  void _saveRoster(Roster roster) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      SnackBarUtils.showError(context, 'Please enter a roster name');
      return;
    }

    // Create updated roster
    final updatedRoster = Roster(
      id: roster.id,
      name: name,
      unitIds: _selectedUnitIds.toList(),
      createdAt: roster.createdAt,
      lastModified: DateTime.now().millisecondsSinceEpoch,
      timesDeployed: roster.timesDeployed,
      wins: roster.wins,
      losses: roster.losses,
      draws: roster.draws,
    );

    ref.read(currentCrusadeNotifierProvider.notifier).updateRoster(updatedRoster);
    SnackBarUtils.showSuccess(context, 'Roster "$name" saved');
    context.go('/rosters');
  }
}

class _UnitPanel extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<UnitOrGroup> units;
  final String emptyMessage;
  final Function(UnitOrGroup) onUnitTap;
  final IconData actionIcon;
  final Color actionColor;

  const _UnitPanel({
    required this.title,
    required this.titleColor,
    required this.units,
    required this.emptyMessage,
    required this.onUnitTap,
    required this.actionIcon,
    required this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Panel header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: titleColor.withValues(alpha: 0.2),
          child: Text(
            '$title (${units.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        // Unit list
        Expanded(
          child: units.isEmpty
              ? Center(
                  child: Text(
                    emptyMessage,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    return _UnitTile(
                      unit: unit,
                      onTap: () => onUnitTap(unit),
                      actionIcon: actionIcon,
                      actionColor: actionColor,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _UnitTile extends StatelessWidget {
  final UnitOrGroup unit;
  final VoidCallback onTap;
  final IconData actionIcon;
  final Color actionColor;

  const _UnitTile({
    required this.unit,
    required this.onTap,
    required this.actionIcon,
    required this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = unit.customName ?? unit.name;
    final isWarlord = unit.isWarlord == true;
    final isEpicHero = unit.isEpicHero == true;
    final isCharacter = unit.isCharacter == true;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // Action button
            Icon(actionIcon, color: actionColor, size: 24),
            const SizedBox(width: 8),
            // Unit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isWarlord) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      ],
                      if (isEpicHero) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.auto_awesome, size: 14, color: Colors.purple),
                      ],
                      if (isCharacter && !isEpicHero) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.person, size: 14, color: Colors.blue),
                      ],
                    ],
                  ),
                  Text(
                    '${unit.points} pts - ${unit.rank}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
