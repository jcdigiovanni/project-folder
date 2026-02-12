import 'package:uuid/uuid.dart';

import '../common.dart';
import '../models/faction_crusade_system.dart';
import '../services/reference_data_service.dart';
import '../utils/game_state_utils.dart';
import '../widgets/army_avatar.dart';
import '../widgets/crusade_stats_bar.dart';
import '../widgets/d6_roller.dart';
import '../widgets/detail_row.dart';

class OOBModifyScreen extends ConsumerWidget {
  const OOBModifyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.watch(currentCrusadeNotifierProvider);

    if (currentCrusade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modify OOB')),
        body: const Center(child: Text('No Crusade loaded. Create one first.')),
      );
    }

    final factionSystem = FactionCrusadeSystemRegistry.forFaction(currentCrusade.faction);

    // Preload faction unit data so the Add Unit modal opens instantly
    ReferenceDataService.getUnits(currentCrusade.faction);

    return Scaffold(
      appBar: AppBar(
        title: Text('Modify OOB - ${currentCrusade.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech),
            tooltip: 'Requisitions',
            onPressed: () => _showRequisitionsDialog(context, ref),
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
          // Points summary banner - using reusable widget
          CrusadeStatsBar(crusade: currentCrusade),

          // OOB list
          Expanded(
            child: currentCrusade.oob.isEmpty
                ? const Center(child: Text('No units or groups yet. Add some!'))
                : ListView.builder(
                    itemCount: currentCrusade.oob.length,
                    itemBuilder: (context, index) {
                final item = currentCrusade.oob[index];

                // Determine icon based on type and flags
                Widget leadingIcon;
                if (item.type == 'group') {
                  leadingIcon = const Icon(Icons.folder, color: Colors.blue);
                } else if (item.isEpicHero == true) {
                  leadingIcon = const Icon(Icons.military_tech, color: Colors.purple);
                } else if (item.isWarlord == true) {
                  leadingIcon = const Icon(Icons.star, color: Colors.yellow);
                } else {
                  leadingIcon = const Icon(Icons.person);
                }

                // Build children list for expansion tile
                final List<Widget> expansionChildren = [];

                // If it's a group, show component units in hierarchical style
                if (item.type == 'group' && item.components != null && item.components!.isNotEmpty) {
                  for (var componentIndex = 0; componentIndex < item.components!.length; componentIndex++) {
                    final component = item.components![componentIndex];
                    // Build nested unit details
                    final List<Widget> nestedExpansionChildren = [];
                    nestedExpansionChildren.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Unit Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DetailRow(label: 'Experience', value: '${component.xp} XP'),
                            DetailRow(label: 'Models', value: '${component.modelsCurrent}/${component.modelsMax}'),
                            DetailRow(label: 'Crusade Points', value: '${component.crusadePoints}'),
                            if (component.tallies['played'] != null)
                              DetailRow(label: 'Battles Played', value: '${component.tallies['played']}'),
                            DetailRow(label: 'Total Kills', value: '${component.tallies['kills'] ?? 0}'),
                            if (component.honours.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Battle Honours:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ...component.honours.map((honour) => Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Text('• $honour', style: const TextStyle(fontSize: 13)),
                              )),
                            ],
                            if (component.enhancements.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Enhancements:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ...component.enhancements.map((enhancement) => Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Text('• $enhancement', style: const TextStyle(fontSize: 13)),
                              )),
                            ],
                            if (component.scars.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Battle Scars:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                              ...component.scars.map((scar) => Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Text('• $scar', style: const TextStyle(fontSize: 13, color: Colors.red)),
                              )),
                            ],
                            if (component.notes != null && component.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Notes:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Text(component.notes!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                              ),
                            ],
                            // Faction progression info (component units)
                            if (factionSystem != null && (component.tallies[ProgressionKeys.trialId] ?? 0) > 0)
                              _TrialInfoSection(unit: component, system: factionSystem),
                            if (factionSystem != null && component.tallies[ProgressionKeys.isAscended] == 1)
                              _AscendedBadge(system: factionSystem),
                          ],
                        ),
                      ),
                    );

                    // Faction progression actions for component units
                    if (factionSystem != null) {
                      if (factionSystem.isDesignated(component)) {
                        nestedExpansionChildren.add(
                          ListTile(
                            dense: true,
                            leading: Icon(factionSystem.icon, color: factionSystem.color.withValues(alpha: 0.8), size: 20),
                            title: Text(factionSystem.removeActionLabel, style: TextStyle(color: factionSystem.color.withValues(alpha: 0.8), fontSize: 14)),
                            onTap: () => _removeDesignation(context, ref, component, factionSystem),
                          ),
                        );
                      } else if (factionSystem.canDesignate(component) &&
                          !factionSystem.hasExistingDesignation(currentCrusade)) {
                        nestedExpansionChildren.add(
                          ListTile(
                            dense: true,
                            leading: Icon(factionSystem.icon, color: factionSystem.color.withValues(alpha: 0.8), size: 20),
                            title: Text(factionSystem.beginActionLabel, style: TextStyle(color: factionSystem.color.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 14)),
                            onTap: () => _beginTrial(context, ref, component, factionSystem),
                          ),
                        );
                      }
                    }

                    // Add Claim Battle Honour button if component has available Battle Honours (BUG-018 fix)
                    if (component.availableBattleHonours > 0) {
                      nestedExpansionChildren.add(
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                          title: const Text('Claim Battle Honour', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                          onTap: () => _showComponentBattleHonourModal(context, ref, index, componentIndex, component),
                        ),
                      );
                    }

                    // Add Edit button for component units (BUG-018 fix)
                    nestedExpansionChildren.add(
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.edit, size: 20),
                        title: const Text('Edit Unit', style: TextStyle(fontSize: 14)),
                        onTap: () => _editComponentUnit(context, ref, index, componentIndex, component),
                      ),
                    );

                    expansionChildren.add(
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0), // Indent for hierarchy
                        child: ExpansionTile(
                          leading: component.isWarlord == true
                              ? const Icon(Icons.star, color: Colors.yellow, size: 18)
                              : component.isEpicHero == true
                                  ? const Icon(Icons.military_tech, color: Colors.purple, size: 18)
                                  : const Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.grey),
                          title: Text(
                            component.customName != null
                                ? '${component.customName} (${component.name})'
                                : component.name,
                            style: const TextStyle(fontSize: 14), // Smaller text for nested items
                          ),
                          subtitle: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${component.rank} • ${component.points} pts • ${component.crusadePoints} CP',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (component.availableBattleHonours > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                  ),
                                  child: const Text(
                                    'Level Up!',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                              ],
                              if ((component.tallies['trialId'] ?? 0) > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                  ),
                                  child: const Text('Saint Potentia', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.amber)),
                                ),
                              ],
                              if (component.tallies[ProgressionKeys.isAscended] == 1) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                                  ),
                                  child: Text('Living Saint', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.yellow.shade300)),
                                ),
                              ],
                            ],
                          ),
                          dense: true,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                          childrenPadding: EdgeInsets.zero,
                          children: nestedExpansionChildren,
                        ),
                      ),
                    );
                  }
                  expansionChildren.add(const Divider());
                }

                // If it's a unit (not a group), show detailed stats section
                if (item.type == 'unit') {
                  expansionChildren.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unit Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (item.availableBattleHonours > 0)
                            _HighlightedXPRow(xp: item.xp, rank: item.rank)
                          else
                            DetailRow(label: 'Experience', value: '${item.xp} XP'),
                          DetailRow(label: 'Models', value: '${item.modelsCurrent}/${item.modelsMax}'),
                          DetailRow(label: 'Crusade Points', value: '${item.crusadePoints}'),
                          if (item.tallies['played'] != null)
                            DetailRow(label: 'Battles Played', value: '${item.tallies['played']}'),
                          DetailRow(label: 'Total Kills', value: '${item.tallies['kills'] ?? 0}'),
                          if (item.honours.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Battle Honours:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ...item.honours.map((honour) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('• $honour', style: const TextStyle(fontSize: 13)),
                            )),
                          ],
                          if (item.enhancements.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Enhancements:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ...item.enhancements.map((enhancement) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('• $enhancement', style: const TextStyle(fontSize: 13)),
                            )),
                          ],
                          if (item.scars.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Battle Scars:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                            ...item.scars.map((scar) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('• $scar', style: const TextStyle(fontSize: 13, color: Colors.red)),
                            )),
                          ],
                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Notes:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text(item.notes!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                            ),
                          ],
                          // Faction progression info (top-level units)
                          if (factionSystem != null && (item.tallies[ProgressionKeys.trialId] ?? 0) > 0)
                            _TrialInfoSection(unit: item, system: factionSystem),
                          if (factionSystem != null && item.tallies[ProgressionKeys.isAscended] == 1)
                            _AscendedBadge(system: factionSystem),
                        ],
                      ),
                    ),
                  );
                  expansionChildren.add(const Divider());
                }

                // Faction progression actions for top-level units
                if (factionSystem != null && item.type == 'unit') {
                  if (factionSystem.isDesignated(item)) {
                    expansionChildren.add(
                      ListTile(
                        leading: Icon(factionSystem.icon, color: factionSystem.color.withValues(alpha: 0.8)),
                        title: Text(factionSystem.removeActionLabel, style: TextStyle(color: factionSystem.color.withValues(alpha: 0.8))),
                        onTap: () => _removeDesignation(context, ref, item, factionSystem),
                      ),
                    );
                  } else if (factionSystem.canDesignate(item) &&
                      !factionSystem.hasExistingDesignation(currentCrusade)) {
                    expansionChildren.add(
                      ListTile(
                        leading: Icon(factionSystem.icon, color: factionSystem.color.withValues(alpha: 0.8)),
                        title: Text(factionSystem.beginActionLabel, style: TextStyle(color: factionSystem.color.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                        onTap: () => _beginTrial(context, ref, item, factionSystem),
                      ),
                    );
                  }
                }

                // Add Claim Battle Honour button if unit has available Battle Honours
                if (item.type != 'group' && item.availableBattleHonours > 0) {
                  expansionChildren.add(
                    ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.amber),
                      title: Text(
                        item.availableBattleHonours > 1
                            ? 'Claim Battle Honour (${item.availableBattleHonours} available)'
                            : 'Claim Battle Honour',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Select your rank-up reward'),
                      onTap: () => _showBattleHonourModal(context, ref, index, item),
                    ),
                  );
                }

                // Add Edit and Delete options
                expansionChildren.add(
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () {
                      if (item.type == 'group') {
                        _editGroup(context, ref, index, item);
                      } else {
                        _editUnit(context, ref, index, item);
                      }
                    },
                  ),
                );
                expansionChildren.add(
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      if (item.type == 'group' && item.components != null && item.components!.isNotEmpty) {
                        // Show confirmation dialog for groups with units
                        _showDeleteGroupDialog(context, ref, index, item);
                      } else {
                        // Direct delete for units or empty groups
                        ref.read(currentCrusadeNotifierProvider.notifier).removeUnitOrGroup(index);
                        ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
                          type: CrusadeEventType.unitRemoved,
                          description: 'Removed ${item.customName ?? item.name} (${item.points} pts)',
                          unitId: item.id,
                          unitName: item.customName ?? item.name,
                          metadata: {
                            'points': item.points,
                          },
                        ));
                      }
                    },
                  ),
                );

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: ExpansionTile(
                    leading: leadingIcon,
                    title: Text(
                      item.customName != null
                          ? '${item.customName} (${item.name})'
                          : item.name
                    ),
                    subtitle: Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.type == 'group'
                                ? '${item.points} pts • ${item.totalCrusadePoints} CP • ${item.components?.length ?? 0} units'
                                : '${item.rank} • ${item.points} pts • ${item.crusadePoints} CP',
                          ),
                        ),
                        if (item.type != 'group' && item.availableBattleHonours > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                            ),
                            child: const Text(
                              'Level Up!',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                        // SAINT POTENTIA chip
                        if (item.type != 'group' && (item.tallies['trialId'] ?? 0) > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              'Saint Potentia',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                          ),
                        ],
                        // LIVING SAINT chip
                        if (item.type != 'group' && item.tallies[ProgressionKeys.isAscended] == 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              'Living Saint',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.yellow.shade300),
                            ),
                          ),
                        ],
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    collapsedBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: item.type == 'group' ? Colors.blue.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                      ),
                    ),
                    children: expansionChildren,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add_circle),
                  title: const Text('Add Unit'),
                  onTap: () {
                    Navigator.pop(context);
                    _addUnitOrGroup(context, ref, false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: const Text('Add Group'),
                  onTap: () {
                    Navigator.pop(context);
                    _addUnitOrGroup(context, ref, true);
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addUnitOrGroup(BuildContext context, WidgetRef ref, bool isGroup) {
    if (isGroup) {
      _createGroup(context, ref);
    } else {
      _addUnit(context, ref);
    }
  }

  /// Shows a confirmation dialog when deleting a group with component units
  void _showDeleteGroupDialog(BuildContext context, WidgetRef ref, int index, UnitOrGroup group) {
    final unitCount = group.components?.length ?? 0;
    final unitNames = group.components?.map((u) => u.customName ?? u.name).take(3).toList() ?? [];
    final moreCount = unitCount > 3 ? unitCount - 3 : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This group contains $unitCount unit${unitCount == 1 ? '' : 's'}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...unitNames.map((name) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('• $name'),
            )),
            if (moreCount > 0)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• ...and $moreCount more', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 16),
            const Text('What would you like to do?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Ungroup: return units to OOB, then remove the empty group entry
              final currentCrusade = ref.read(currentCrusadeNotifierProvider);
              if (currentCrusade != null && group.components != null) {
                final updatedOob = List<UnitOrGroup>.from(currentCrusade.oob);
                // Remove the group
                updatedOob.removeAt(index);
                // Add the component units back to OOB
                updatedOob.addAll(group.components!);

                final updatedCrusade = Crusade(
                  id: currentCrusade.id,
                  name: currentCrusade.name,
                  faction: currentCrusade.faction,
                  detachment: currentCrusade.detachment,
                  supplyLimit: currentCrusade.supplyLimit,
                  rp: currentCrusade.rp,
                  armyIconPath: currentCrusade.armyIconPath,
                  factionIconAsset: currentCrusade.factionIconAsset,
                  oob: updatedOob,
                  templates: currentCrusade.templates,
                  usedFirstCharacterEnhancement: currentCrusade.usedFirstCharacterEnhancement,
                  history: currentCrusade.history,
                  rosters: currentCrusade.rosters,
                  games: currentCrusade.games,
                );
                ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(updatedCrusade);
                SnackBarUtils.showSuccess(context, 'Group disbanded. Units returned to Order of Battle.');
              }
            },
            child: const Text('Ungroup Only'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete group and all units
              ref.read(currentCrusadeNotifierProvider.notifier).removeUnitOrGroup(index);
              SnackBarUtils.showSuccess(context, 'Group and all units deleted.');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _createGroup(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    // Filter out only units (not groups) for selection - check before showing modal
    final availableUnits = currentCrusade.oob.where((item) => item.type == 'unit').toList();

    // If no units available, show a message instead of the full modal
    if (availableUnits.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Units Available'),
          content: const Text(
            'You need to add some units to your Order of Battle before you can create a group.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Use a TextEditingController to maintain focus
    final groupNameController = TextEditingController();
    final selectedUnitIds = <String>{};
    String? nameError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Calculate total points from selected units
            final totalPoints = availableUnits
                .where((unit) => selectedUnitIds.contains(unit.id))
                .fold<int>(0, (sum, unit) => sum + unit.points);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Create Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: groupNameController,
                    autofocus: true,
                    inputFormatters: nameFormatters,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g., Sailor Venus Squad',
                      errorText: nameError,
                    ),
                    onChanged: (value) {
                      if (nameError != null && value.trim().isNotEmpty) {
                        setModalState(() => nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Select Units to Add:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableUnits.length,
                      itemBuilder: (context, index) {
                        final unit = availableUnits[index];
                        return CheckboxListTile(
                          title: Text(unit.customName ?? unit.name),
                          subtitle: Text('${unit.points} pts • ${unit.modelsCurrent}/${unit.modelsMax} models'),
                          value: selectedUnitIds.contains(unit.id),
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                selectedUnitIds.add(unit.id);
                              } else {
                                selectedUnitIds.remove(unit.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text('Total Points: $totalPoints', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final groupName = groupNameController.text;
                        if (groupName.trim().isEmpty) {
                          setModalState(() => nameError = 'Enter a group name');
                          return;
                        }
                        if (selectedUnitIds.isEmpty) {
                          SnackBarUtils.showError(context, 'Select at least one unit');
                          return;
                        }

                        // Get the selected units
                        final selectedUnits = availableUnits
                            .where((unit) => selectedUnitIds.contains(unit.id))
                            .toList();

                        // Create the group
                        final newGroup = UnitOrGroup(
                          id: const Uuid().v4(),
                          type: 'group',
                          name: groupName.trim(),
                          points: totalPoints,
                          components: selectedUnits,
                          modelsCurrent: selectedUnits.fold(0, (sum, u) => sum + u.modelsCurrent),
                          modelsMax: selectedUnits.fold(0, (sum, u) => sum + u.modelsMax),
                        );

                        // Add group and remove the units from main OOB
                        ref.read(currentCrusadeNotifierProvider.notifier).addGroupFromUnits(
                          newGroup,
                          selectedUnitIds.toList(),
                        );
                        Navigator.pop(context);

                        SnackBarUtils.showSuccess(context, 'Group "${groupName.trim()}" created!');
                      },
                      child: const Text('Create Group'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addUnit(BuildContext context, WidgetRef ref) async {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    final crusadeFaction = currentCrusade?.faction;

    // Preload units for the crusade's faction and wait for them to load
    if (crusadeFaction != null) {
      await ReferenceDataService.getUnits(crusadeFaction);
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddUnitModalContent(
        currentCrusade: currentCrusade,
        ref: ref,
      ),
    );
  }

  void _editUnit(BuildContext context, WidgetRef ref, int index, UnitOrGroup unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditUnitModalContent(
        unit: unit,
        title: 'Edit Unit: ${unit.name}',
        onSave: (customName, notes) {
          final updatedUnit = UnitOrGroup(
            id: unit.id,
            type: unit.type,
            name: unit.name,
            customName: customName,
            points: unit.points,
            modelsCurrent: unit.modelsCurrent,
            modelsMax: unit.modelsMax,
            notes: notes,
            isWarlord: unit.isWarlord,
            isEpicHero: unit.isEpicHero,
          );
          ref.read(currentCrusadeNotifierProvider.notifier).updateUnitOrGroup(index, updatedUnit);
          Navigator.pop(context);
          SnackBarUtils.showSuccess(context, 'Unit updated!');
        },
      ),
    );
  }

  /// Edit a component unit within a group (BUG-018 fix)
  void _editComponentUnit(BuildContext context, WidgetRef ref, int groupIndex, int componentIndex, UnitOrGroup component) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditUnitModalContent(
        unit: component,
        title: 'Edit Unit: ${component.name}',
        subtitle: '(in group)',
        onSave: (customName, notes) {
          final updatedComponent = UnitOrGroup(
            id: component.id,
            type: component.type,
            name: component.name,
            customName: customName,
            points: component.points,
            components: component.components,
            modelsCurrent: component.modelsCurrent,
            modelsMax: component.modelsMax,
            notes: notes,
            statsText: component.statsText,
            isWarlord: component.isWarlord,
            isEpicHero: component.isEpicHero,
            isCharacter: component.isCharacter,
            xp: component.xp,
            honours: component.honours,
            scars: component.scars,
            enhancements: component.enhancements,
            crusadePoints: component.crusadePoints,
            tallies: component.tallies,
            pendingRankUp: component.pendingRankUp,
            availableBattleHonours: component.availableBattleHonours,
            battleTraits: component.battleTraits,
            weaponEnhancements: component.weaponEnhancements,
            crusadeRelic: component.crusadeRelic,
          );
          _updateComponentInGroup(ref, groupIndex, componentIndex, updatedComponent);
          Navigator.pop(context);
          SnackBarUtils.showSuccess(context, 'Unit updated!');
        },
      ),
    );
  }

  /// Helper to update a component unit within its parent group
  void _updateComponentInGroup(WidgetRef ref, int groupIndex, int componentIndex, UnitOrGroup updatedComponent) {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    final group = currentCrusade.oob[groupIndex];
    if (group.type != 'group' || group.components == null) return;

    // Create updated components list
    final updatedComponents = List<UnitOrGroup>.from(group.components!);
    updatedComponents[componentIndex] = updatedComponent;

    // Create updated group with new components (preserving all other fields)
    final updatedGroup = UnitOrGroup(
      id: group.id,
      type: group.type,
      name: group.name,
      customName: group.customName,
      points: group.points,
      components: updatedComponents,
      modelsCurrent: group.modelsCurrent,
      modelsMax: group.modelsMax,
      notes: group.notes,
      statsText: group.statsText,
      isWarlord: group.isWarlord,
      isEpicHero: group.isEpicHero,
      isCharacter: group.isCharacter,
      xp: group.xp,
      honours: group.honours,
      scars: group.scars,
      enhancements: group.enhancements,
      crusadePoints: group.crusadePoints,
      tallies: group.tallies,
      pendingRankUp: group.pendingRankUp,
      availableBattleHonours: group.availableBattleHonours,
      battleTraits: group.battleTraits,
      weaponEnhancements: group.weaponEnhancements,
      crusadeRelic: group.crusadeRelic,
    );

    // Update the group in OOB
    ref.read(currentCrusadeNotifierProvider.notifier).updateUnitOrGroup(groupIndex, updatedGroup);
  }

  /// Show Battle Honour modal for a component unit within a group (BUG-018 fix)
  void _showComponentBattleHonourModal(BuildContext context, WidgetRef ref, int groupIndex, int componentIndex, UnitOrGroup component) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _ComponentBattleHonourModalContent(
              groupIndex: groupIndex,
              componentIndex: componentIndex,
              component: component,
              scrollController: scrollController,
              updateCallback: (updatedComponent) {
                _updateComponentInGroup(ref, groupIndex, componentIndex, updatedComponent);
              },
            );
          },
        );
      },
    );
  }

  void _editGroup(BuildContext context, WidgetRef ref, int index, UnitOrGroup group) {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String groupName = group.customName ?? group.name;
        final selectedUnitIds = <String>{};

        // Pre-populate with current group components
        if (group.components != null) {
          for (var component in group.components!) {
            selectedUnitIds.add(component.id);
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Get available units (ungrouped units only)
            final ungroupedUnits = currentCrusade.oob
                .where((item) => item.type == 'unit')
                .toList();

            // Get current group components
            final currentComponents = group.components ?? [];

            // Calculate total points from selected units
            final totalPoints = [
              ...ungroupedUnits.where((unit) => selectedUnitIds.contains(unit.id)),
              ...currentComponents.where((unit) => selectedUnitIds.contains(unit.id)),
            ].fold<int>(0, (sum, unit) => sum + unit.points);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Edit Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                    ),
                    inputFormatters: nameFormatters,
                    controller: TextEditingController(text: groupName),
                    onChanged: (value) => groupName = value,
                  ),
                  const SizedBox(height: 16),

                  const Text('Current Units:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (currentComponents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No units in this group.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: currentComponents.length,
                        itemBuilder: (context, idx) {
                          final unit = currentComponents[idx];
                          return CheckboxListTile(
                            title: Text(unit.customName ?? unit.name),
                            subtitle: Text('${unit.points} pts'),
                            value: selectedUnitIds.contains(unit.id),
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedUnitIds.add(unit.id);
                                } else {
                                  selectedUnitIds.remove(unit.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Text('Add Ungrouped Units:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (ungroupedUnits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No ungrouped units available.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: ungroupedUnits.length,
                        itemBuilder: (context, idx) {
                          final unit = ungroupedUnits[idx];
                          return CheckboxListTile(
                            title: Text(unit.customName ?? unit.name),
                            subtitle: Text('${unit.points} pts'),
                            value: selectedUnitIds.contains(unit.id),
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedUnitIds.add(unit.id);
                                } else {
                                  selectedUnitIds.remove(unit.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                  Text('Total Points: $totalPoints', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (groupName.trim().isEmpty) {
                          SnackBarUtils.showError(context, 'Enter a group name');
                          return;
                        }
                        if (selectedUnitIds.isEmpty) {
                          SnackBarUtils.showError(context, 'Select at least one unit');
                          return;
                        }

                        // Collect all selected units (from both current components and ungrouped)
                        final selectedUnits = <UnitOrGroup>[];

                        // Add selected units from current components
                        for (var component in currentComponents) {
                          if (selectedUnitIds.contains(component.id)) {
                            selectedUnits.add(component);
                          }
                        }

                        // Add selected units from ungrouped units
                        for (var unit in ungroupedUnits) {
                          if (selectedUnitIds.contains(unit.id)) {
                            selectedUnits.add(unit);
                          }
                        }

                        // Determine which units to remove from main OOB (newly added ungrouped units)
                        final unitsToRemoveFromOob = ungroupedUnits
                            .where((unit) => selectedUnitIds.contains(unit.id))
                            .map((u) => u.id)
                            .toList();

                        // Determine which units to return to OOB (units removed from group)
                        final unitsToReturnToOob = <UnitOrGroup>[];
                        for (var component in currentComponents) {
                          if (!selectedUnitIds.contains(component.id)) {
                            unitsToReturnToOob.add(component);
                          }
                        }

                        // Update the group
                        final updatedGroup = UnitOrGroup(
                          id: group.id,
                          type: 'group',
                          name: groupName.trim(),
                          points: totalPoints,
                          components: selectedUnits,
                          modelsCurrent: selectedUnits.fold(0, (sum, u) => sum + u.modelsCurrent),
                          modelsMax: selectedUnits.fold(0, (sum, u) => sum + u.modelsMax),
                        );

                        // Build new OOB: remove newly grouped units, add returned units, update the group
                        final updatedOob = currentCrusade.oob
                            .where((item) => !unitsToRemoveFromOob.contains(item.id))
                            .map((item) => item.id == group.id ? updatedGroup : item)
                            .toList();

                        // Add units that were removed from the group back to OOB
                        updatedOob.addAll(unitsToReturnToOob);

                        // Update the crusade
                        final updatedCrusade = Crusade(
                          id: currentCrusade.id,
                          name: currentCrusade.name,
                          faction: currentCrusade.faction,
                          detachment: currentCrusade.detachment,
                          supplyLimit: currentCrusade.supplyLimit,
                          rp: currentCrusade.rp,
                          armyIconPath: currentCrusade.armyIconPath,
                          factionIconAsset: currentCrusade.factionIconAsset,
                          oob: updatedOob,
                          templates: currentCrusade.templates,
                          usedFirstCharacterEnhancement: currentCrusade.usedFirstCharacterEnhancement,
                          history: currentCrusade.history,
                          rosters: currentCrusade.rosters,
                          games: currentCrusade.games,
                        );

                        ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(updatedCrusade);
                        Navigator.pop(context);

                        SnackBarUtils.showSuccess(context, 'Group "${groupName.trim()}" updated!');
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Shows the requisitions dialog with available requisition options
  static void _showRequisitionsDialog(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Requisitions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${currentCrusade.rp} RP',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kAccentGold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                title: const Text('Renowned Heroes'),
                subtitle: const Text('Add an enhancement when a unit gains a rank (1 RP)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _applyRenownedHeroes(context, ref);
                },
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'More requisitions coming soon...',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Applies the Renowned Heroes requisition (add enhancement to character)
  /// Per rules: Can only be used when a unit gains a rank (instead of Battle Honour)
  /// Unit must be CHARACTER, not EPIC HERO, no existing enhancement,
  /// and cannot have Disgraced or Mark of Shame battle scars
  static void _applyRenownedHeroes(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    // Check if user has enough RP
    if (currentCrusade.rp < 1) {
      SnackBarUtils.showError(context, 'Not enough RP! You need 1 RP for this requisition.');
      return;
    }

    // Get all eligible character units with full validation
    final eligibleUnits = <MapEntry<int, UnitOrGroup>>[];
    for (var i = 0; i < currentCrusade.oob.length; i++) {
      final item = currentCrusade.oob[i];
      // Only ungrouped units are eligible (groups can't have enhancements)
      if (item.type != 'unit') continue;
      if (item.isCharacter != true) continue;
      if (item.isEpicHero == true) continue;
      if (item.enhancements.isNotEmpty) continue;
      // Check for disqualifying battle scars
      if (item.scars.any((scar) =>
          scar.toLowerCase().contains('disgraced') ||
          scar.toLowerCase().contains('mark of shame'))) continue;

      eligibleUnits.add(MapEntry(i, item));
    }

    if (eligibleUnits.isEmpty) {
      SnackBarUtils.showError(
        context,
        'No eligible characters! Must be CHARACTER, not Epic Hero, no existing enhancement, and no Disgraced/Mark of Shame scars.',
      );
      return;
    }

    // Get ALL available enhancements from ALL detachments for the faction
    final allEnhancements = ReferenceDataService.getAllEnhancementsForFaction(currentCrusade.faction);

    if (allEnhancements.isEmpty) {
      SnackBarUtils.showError(context, 'No enhancements available for ${currentCrusade.faction} faction.');
      return;
    }

    // Flatten enhancements for dropdown (include detachment name for clarity)
    final flatEnhancements = <Map<String, dynamic>>[];
    for (final entry in allEnhancements.entries) {
      final detachmentName = entry.key;
      for (final enh in entry.value) {
        flatEnhancements.add({
          ...enh,
          'detachment': detachmentName,
        });
      }
    }

    // Show unit selection dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        MapEntry<int, UnitOrGroup>? selectedUnit;
        Map<String, dynamic>? selectedEnhancement;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Renowned Heroes',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a character and enhancement (1 RP)',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Character selection dropdown
                  DropdownButtonFormField<MapEntry<int, UnitOrGroup>>(
                    decoration: const InputDecoration(
                      labelText: 'Character',
                      border: OutlineInputBorder(),
                    ),
                    items: eligibleUnits.map((entry) {
                      final unit = entry.value;
                      return DropdownMenuItem(
                        value: entry,
                        child: Text(unit.customName ?? unit.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedUnit = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Enhancement selection dropdown (shows all detachment enhancements)
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      labelText: 'Enhancement',
                      border: OutlineInputBorder(),
                    ),
                    items: flatEnhancements.map((enh) {
                      return DropdownMenuItem(
                        value: enh,
                        child: Text('${enh['name']} (+${enh['points']} pts) - ${enh['detachment']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedEnhancement = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedUnit != null && selectedEnhancement != null
                          ? () {
                              final unitIndex = selectedUnit!.key;
                              final unit = selectedUnit!.value;
                              final enhName = selectedEnhancement!['name'] as String;
                              final enhPoints = selectedEnhancement!['points'] as int;

                              // Create updated unit with enhancement
                              final updatedUnit = UnitOrGroup(
                                id: unit.id,
                                type: unit.type,
                                name: unit.name,
                                customName: unit.customName,
                                points: unit.points + enhPoints, // Add enhancement points
                                modelsCurrent: unit.modelsCurrent,
                                modelsMax: unit.modelsMax,
                                notes: unit.notes,
                                statsText: unit.statsText,
                                isWarlord: unit.isWarlord,
                                isEpicHero: unit.isEpicHero,
                                isCharacter: unit.isCharacter,
                                xp: unit.xp,
                                honours: unit.honours,
                                scars: unit.scars,
                                enhancements: [...unit.enhancements, enhName],
                                crusadePoints: unit.crusadePoints,
                                tallies: unit.tallies,
                              );

                              // Update OOB
                              final updatedOob = List<UnitOrGroup>.from(currentCrusade.oob);
                              updatedOob[unitIndex] = updatedUnit;

                              // Create history event for the requisition
                              final enhancementEvent = CrusadeEvent.create(
                                type: CrusadeEventType.requisition,
                                description: 'Renowned Heroes: Added $enhName to ${unit.customName ?? unit.name}',
                                unitId: unit.id,
                                unitName: unit.customName ?? unit.name,
                                metadata: {
                                  'requisition': 'Renowned Heroes',
                                  'enhancement': enhName,
                                  'enhancementPoints': enhPoints,
                                  'rpCost': 1,
                                  'onRankUp': true,
                                },
                              );

                              // Create updated crusade with -1 RP and history event
                              final updatedCrusade = Crusade(
                                id: currentCrusade.id,
                                name: currentCrusade.name,
                                faction: currentCrusade.faction,
                                detachment: currentCrusade.detachment,
                                supplyLimit: currentCrusade.supplyLimit,
                                rp: currentCrusade.rp - 1, // Deduct RP
                                armyIconPath: currentCrusade.armyIconPath,
                                factionIconAsset: currentCrusade.factionIconAsset,
                                oob: updatedOob,
                                templates: currentCrusade.templates,
                                usedFirstCharacterEnhancement: currentCrusade.usedFirstCharacterEnhancement,
                                history: [...currentCrusade.history, enhancementEvent],
                                rosters: currentCrusade.rosters,
                                games: currentCrusade.games,
                              );

                              ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(updatedCrusade);
                              Navigator.pop(context);

                              SnackBarUtils.showSuccess(
                                context,
                                'Enhancement "$enhName" added to ${unit.customName ?? unit.name}!',
                              );
                            }
                          : null,
                      child: const Text('Apply Enhancement (1 RP)'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Shows the Battle Honour selection modal for a unit that has ranked up
  static void _showBattleHonourModal(BuildContext context, WidgetRef ref, int unitIndex, UnitOrGroup unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _BattleHonourModalContent(
              unitIndex: unitIndex,
              unit: unit,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  /// Begin faction progression trial — designate a unit
  void _beginTrial(BuildContext context, WidgetRef ref, UnitOrGroup unit, FactionCrusadeSystem system) async {
    final trials = await loadTrials(system.trialDataAsset);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              system.systemName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${unit.customName ?? unit.name} will become ${system.designationKeyword}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.casino, color: system.color),
              title: const Text('Roll D6', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Randomly determine your Trial'),
              onTap: () {
                Navigator.pop(modalContext);
                _rollForTrial(context, ref, unit, trials, system);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.list_alt, color: system.color),
              title: const Text('Select Trial', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Choose your Trial from the list'),
              onTap: () {
                Navigator.pop(modalContext);
                _selectTrial(context, ref, unit, trials, system);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _rollForTrial(BuildContext context, WidgetRef ref, UnitOrGroup unit, List<TrialDefinition> trials, FactionCrusadeSystem system) async {
    final result = await showD6RollerModal(
      context: context,
      title: system.systemName,
      subtitle: 'Rolling for ${unit.customName ?? unit.name}',
      mode: DiceMode.d6,
      allowReroll: false,
    );
    if (result == null || !context.mounted) return;

    final trialId = result.total;
    final trial = trials.firstWhere((t) => t.id == trialId);
    _confirmTrial(context, ref, unit, trial, system);
  }

  void _selectTrial(BuildContext context, WidgetRef ref, UnitOrGroup unit, List<TrialDefinition> trials, FactionCrusadeSystem system) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Select a Trial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...trials.map((trial) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: system.color.withValues(alpha: 0.2),
                  child: Text('${trial.id}', style: TextStyle(color: system.color, fontWeight: FontWeight.bold)),
                ),
                title: Text(trial.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(trial.description, style: const TextStyle(fontSize: 12)),
                trailing: Text('${trial.requiredPoints} pts', style: TextStyle(color: system.color, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(modalContext);
                  _confirmTrial(context, ref, unit, trial, system);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _confirmTrial(BuildContext context, WidgetRef ref, UnitOrGroup unit, TrialDefinition trial, FactionCrusadeSystem system) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Trial'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${unit.customName ?? unit.name} will undertake:'),
            const SizedBox(height: 8),
            Text(trial.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: system.color)),
            const SizedBox(height: 4),
            Text(trial.description, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Required ${system.pointsLabel}: ${trial.requiredPoints}', style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              unit.tallies[ProgressionKeys.trialId] = trial.id;
              final crusade = ref.read(currentCrusadeNotifierProvider);
              if (crusade != null) {
                crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
                ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
                ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
                  type: CrusadeEventType.requisition,
                  description: system.designationEventDescription(unit.customName ?? unit.name, trial.name),
                  unitId: unit.id,
                  unitName: unit.customName ?? unit.name,
                  metadata: {'trialId': trial.id, 'trialName': trial.name},
                ));
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${unit.customName ?? unit.name} begins the ${trial.name}!'),
                    backgroundColor: system.color.withValues(alpha: 0.8),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: kAccentPink),
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Remove progression designation from a unit
  void _removeDesignation(BuildContext context, WidgetRef ref, UnitOrGroup unit, FactionCrusadeSystem system) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${system.designationKeyword}?'),
        content: Text(
          '${unit.customName ?? unit.name} will no longer be designated as ${system.designationKeyword}. '
          'Current ${system.pointsLabel} (${system.getPoints(unit)}) will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              unit.tallies.remove(ProgressionKeys.trialId);
              final crusade = ref.read(currentCrusadeNotifierProvider);
              if (crusade != null) {
                crusade.lastModified = DateTime.now().millisecondsSinceEpoch;
                ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(crusade);
                ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
                  type: CrusadeEventType.requisition,
                  description: system.removalEventDescription(unit.customName ?? unit.name),
                  unitId: unit.id,
                  unitName: unit.customName ?? unit.name,
                ));
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${unit.customName ?? unit.name} is no longer ${system.designationKeyword}.')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Modal content for Battle Honour selection - StatefulWidget for managing state
class _BattleHonourModalContent extends ConsumerStatefulWidget {
  final int unitIndex;
  final UnitOrGroup unit;
  final ScrollController scrollController;

  const _BattleHonourModalContent({
    required this.unitIndex,
    required this.unit,
    required this.scrollController,
  });

  @override
  ConsumerState<_BattleHonourModalContent> createState() => _BattleHonourModalContentState();
}

class _BattleHonourModalContentState extends ConsumerState<_BattleHonourModalContent> {
  String? _selectedHonourType;
  String? _selectedHonour;
  Map<String, dynamic>? _battleHonoursData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBattleHonoursData();
  }

  Future<void> _loadBattleHonoursData() async {
    final data = await loadBattleHonoursJsonData(context);
    if (mounted) {
      setState(() {
        _battleHonoursData = data;
        _isLoading = false;
      });
      if (data == null) {
        SnackBarUtils.showError(context, 'Failed to load Battle Honours data');
      }
    }
  }

  List<Map<String, dynamic>> _getHonourOptions() {
    if (_battleHonoursData == null || _selectedHonourType == null) return [];

    final typeData = _battleHonoursData![_selectedHonourType];
    if (typeData == null) return [];

    if (_selectedHonourType == 'crusadeRelics') {
      return List<Map<String, dynamic>>.from(typeData['relics'] ?? []);
    } else {
      return List<Map<String, dynamic>>.from(typeData['table'] ?? []);
    }
  }

  void _applyBattleHonour() {
    if (_selectedHonour == null) return;

    // Show confirmation dialog before applying
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Battle Honour'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit: ${widget.unit.customName ?? widget.unit.name}'),
            const SizedBox(height: 8),
            Text('Honour Type: ${_getHonourTypeName()}'),
            const SizedBox(height: 4),
            Text(
              _selectedHonour!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            Text(
              'This will clear the pending rank-up status.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _doApplyBattleHonour();
            },
            style: TextButton.styleFrom(foregroundColor: kAccentPink),
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getHonourTypeName() {
    switch (_selectedHonourType) {
      case 'battleTraits':
        return 'Battle Trait';
      case 'weaponEnhancements':
        return 'Weapon Enhancement';
      case 'crusadeRelics':
        return 'Crusade Relic';
      case 'psychicFortitudes':
        return 'Psychic Fortitude';
      default:
        return 'Unknown';
    }
  }

  void _doApplyBattleHonour() {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    if (currentCrusade == null) return;

    // Update the unit with the new honour
    final updatedOob = List<UnitOrGroup>.from(currentCrusade.oob);
    final updatedUnit = updatedOob[widget.unitIndex];

    // Add to appropriate list based on honour type
    switch (_selectedHonourType) {
      case 'battleTraits':
        updatedUnit.battleTraits.add(_selectedHonour!);
        updatedUnit.honours.add('Trait: $_selectedHonour');
        break;
      case 'weaponEnhancements':
        updatedUnit.weaponEnhancements.add(_selectedHonour!);
        updatedUnit.honours.add('Weapon: $_selectedHonour');
        break;
      case 'crusadeRelics':
        updatedUnit.crusadeRelic = _selectedHonour;
        updatedUnit.honours.add('Relic: $_selectedHonour');
        break;
      case 'psychicFortitudes':
        updatedUnit.battleTraits.add(_selectedHonour!);
        updatedUnit.honours.add('Psychic: $_selectedHonour');
        break;
    }

    // Increment Crusade Points for the Battle Honour (+1 CP per honour)
    updatedUnit.crusadePoints += 1;

    // Debit one available Battle Honour
    updatedUnit.availableBattleHonours -= 1;

    // Create history event
    final honourEvent = CrusadeEvent.create(
      type: CrusadeEventType.honour,
      description: 'Battle Honour gained: $_selectedHonour',
      unitId: updatedUnit.id,
      unitName: updatedUnit.customName ?? updatedUnit.name,
      metadata: {
        'honourType': _selectedHonourType,
        'honour': _selectedHonour,
      },
    );

    // Update crusade
    final updatedCrusade = Crusade(
      id: currentCrusade.id,
      name: currentCrusade.name,
      faction: currentCrusade.faction,
      detachment: currentCrusade.detachment,
      supplyLimit: currentCrusade.supplyLimit,
      rp: currentCrusade.rp,
      armyIconPath: currentCrusade.armyIconPath,
      factionIconAsset: currentCrusade.factionIconAsset,
      oob: updatedOob,
      templates: currentCrusade.templates,
      usedFirstCharacterEnhancement: currentCrusade.usedFirstCharacterEnhancement,
      history: [...currentCrusade.history, honourEvent],
      rosters: currentCrusade.rosters,
      games: currentCrusade.games,
    );

    ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(updatedCrusade);
    Navigator.pop(context);

    SnackBarUtils.showSuccess(
      context,
      'Battle Honour "$_selectedHonour" added to ${widget.unit.customName ?? widget.unit.name}!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unit = widget.unit;
    final isCharacter = unit.isCharacter == true;
    final hasRelic = unit.crusadeRelic != null;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Claim Battle Honour',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  unit.customName ?? unit.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${unit.rank} • ${unit.xp} XP',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Honour type selection
                const Text(
                  'Select Honour Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Battle Trait option
                _HonourTypeCard(
                  title: 'Battle Trait',
                  subtitle: 'Tactical ability from battle experience',
                  icon: Icons.shield,
                  color: Colors.blue,
                  isSelected: _selectedHonourType == 'battleTraits',
                  onTap: () => setState(() {
                    _selectedHonourType = 'battleTraits';
                    _selectedHonour = null;
                  }),
                ),

                // Weapon Enhancement option
                _HonourTypeCard(
                  title: 'Weapon Enhancement',
                  subtitle: 'Upgrade a weapon with special properties',
                  icon: Icons.gpp_good,
                  color: Colors.orange,
                  isSelected: _selectedHonourType == 'weaponEnhancements',
                  onTap: () => setState(() {
                    _selectedHonourType = 'weaponEnhancements';
                    _selectedHonour = null;
                  }),
                ),

                // Crusade Relic option (Characters only, limit 1)
                if (isCharacter && !hasRelic)
                  _HonourTypeCard(
                    title: 'Crusade Relic',
                    subtitle: 'Powerful artifact (Characters only, limit 1)',
                    icon: Icons.auto_awesome,
                    color: Colors.purple,
                    isSelected: _selectedHonourType == 'crusadeRelics',
                    onTap: () => setState(() {
                      _selectedHonourType = 'crusadeRelics';
                      _selectedHonour = null;
                    }),
                  ),

                // Psychic Fortitude option (could check for PSYKER keyword if data available)
                _HonourTypeCard(
                  title: 'Psychic Fortitude',
                  subtitle: 'Warp-enhanced ability (Psykers only)',
                  icon: Icons.psychology,
                  color: Colors.indigo,
                  isSelected: _selectedHonourType == 'psychicFortitudes',
                  onTap: () => setState(() {
                    _selectedHonourType = 'psychicFortitudes';
                    _selectedHonour = null;
                  }),
                ),

                // Honour selection (if type selected)
                if (_selectedHonourType != null) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Honour',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _rollForHonour(),
                        icon: const Icon(Icons.casino, size: 18),
                        label: const Text('Roll Random'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Honour options list
                  ..._getHonourOptions().map((honour) {
                    final name = honour['name'] as String;
                    final effect = honour['effect'] as String;
                    final roll = honour['roll'];

                    return _HonourOptionCard(
                      name: name,
                      effect: effect,
                      roll: roll?.toString(),
                      isSelected: _selectedHonour == name,
                      onTap: () => setState(() => _selectedHonour = name),
                    );
                  }),
                ],
              ],
            ),
          ),

          // Confirm button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedHonour != null ? _applyBattleHonour : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Claim Honour'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rollForHonour() {
    // Show D6 roller for trait selection
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _DiceRollScreen(
          title: _getHonourTypeTitle(),
          mode: _selectedHonourType == 'weaponEnhancements' ? '2d6' : '1d6',
          options: _getHonourOptions(),
          onResult: (honour) {
            setState(() => _selectedHonour = honour);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  String _getHonourTypeTitle() {
    switch (_selectedHonourType) {
      case 'battleTraits':
        return 'Battle Trait Roll';
      case 'weaponEnhancements':
        return 'Weapon Enhancement Roll';
      case 'crusadeRelics':
        return 'Crusade Relic';
      case 'psychicFortitudes':
        return 'Psychic Fortitude Roll';
      default:
        return 'Honour Roll';
    }
  }
}

/// Card for selecting honour type
class _HonourTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _HonourTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? color.withValues(alpha: 0.15) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
        onTap: onTap,
      ),
    );
  }
}

/// Card for selecting specific honour option
class _HonourOptionCard extends StatelessWidget {
  final String name;
  final String effect;
  final String? roll;
  final bool isSelected;
  final VoidCallback onTap;

  const _HonourOptionCard({
    required this.name,
    required this.effect,
    this.roll,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (roll != null)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      roll!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      effect,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen for rolling dice to determine honour
class _DiceRollScreen extends StatefulWidget {
  final String title;
  final String mode; // '1d6' or '2d6'
  final List<Map<String, dynamic>> options;
  final void Function(String honour) onResult;

  const _DiceRollScreen({
    required this.title,
    required this.mode,
    required this.options,
    required this.onResult,
  });

  @override
  State<_DiceRollScreen> createState() => _DiceRollScreenState();
}

class _DiceRollScreenState extends State<_DiceRollScreen> {
  int? _roll1;
  int? _roll2;
  bool _isRolling = false;
  String? _resultHonour;

  int get _total {
    if (widget.mode == '2d6') {
      return (_roll1 ?? 0) + (_roll2 ?? 0);
    }
    return _roll1 ?? 0;
  }

  void _rollDice() async {
    setState(() {
      _isRolling = true;
      _resultHonour = null;
    });

    // Animate through random values
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() {
        _roll1 = (DateTime.now().millisecondsSinceEpoch % 6) + 1;
        if (widget.mode == '2d6') {
          _roll2 = ((DateTime.now().millisecondsSinceEpoch ~/ 7) % 6) + 1;
        }
      });
    }

    // Final roll
    final random = DateTime.now().millisecondsSinceEpoch;
    int finalRoll1 = (random % 6) + 1;
    int? finalRoll2;

    if (widget.mode == '2d6') {
      finalRoll2 = ((random ~/ 7) % 6) + 1;

      // Reroll if duplicates
      if (finalRoll1 == finalRoll2) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        finalRoll2 = ((DateTime.now().millisecondsSinceEpoch ~/ 13) % 6) + 1;
        if (finalRoll1 == finalRoll2) {
          // Try once more
          finalRoll2 = (finalRoll2 % 6) + 1;
        }
      }
    }

    setState(() {
      _roll1 = finalRoll1;
      _roll2 = finalRoll2;
      _isRolling = false;
    });

    // Find matching honour
    final total = widget.mode == '2d6' ? (finalRoll1 + (finalRoll2 ?? 0)) : finalRoll1;
    for (final option in widget.options) {
      if (option['roll'] == total) {
        setState(() => _resultHonour = option['name'] as String);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dice display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DiceDisplay(value: _roll1, isRolling: _isRolling),
                  if (widget.mode == '2d6') ...[
                    const SizedBox(width: 16),
                    Text('+', style: TextStyle(fontSize: 32, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                    _DiceDisplay(value: _roll2, isRolling: _isRolling),
                    const SizedBox(width: 16),
                    Text('=', style: TextStyle(fontSize: 32, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_total',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Result display
              if (_resultHonour != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Result:',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _resultHonour!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons
              if (_roll1 == null)
                FilledButton.icon(
                  onPressed: _rollDice,
                  icon: const Icon(Icons.casino),
                  label: Text('Roll ${widget.mode.toUpperCase()}'),
                )
              else if (!_isRolling) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _rollDice,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reroll'),
                    ),
                    const SizedBox(width: 16),
                    if (_resultHonour != null)
                      FilledButton.icon(
                        onPressed: () => widget.onResult(_resultHonour!),
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Single dice display widget
class _DiceDisplay extends StatelessWidget {
  final int? value;
  final bool isRolling;

  const _DiceDisplay({this.value, this.isRolling = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: value != null ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: value != null
            ? Text(
                '$value',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : Icon(
                Icons.casino,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}


/// Highlighted XP row shown when a unit has a pending rank up
class _HighlightedXPRow extends StatelessWidget {
  final int xp;
  final String rank;

  const _HighlightedXPRow({required this.xp, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_upward, color: Colors.amber, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Experience',
                style: TextStyle(fontSize: 13, color: Colors.amber, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '$xp XP',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  rank,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows faction progression trial info for designated units
class _TrialInfoSection extends StatelessWidget {
  final UnitOrGroup unit;
  final FactionCrusadeSystem system;

  const _TrialInfoSection({required this.unit, required this.system});

  @override
  Widget build(BuildContext context) {
    final trialId = unit.tallies[ProgressionKeys.trialId] ?? 0;
    if (trialId <= 0) return const SizedBox.shrink();

    return FutureBuilder<List<TrialDefinition>>(
      future: loadTrials(system.trialDataAsset),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final trial = snapshot.data!.where((t) => t.id == trialId).firstOrNull;
        if (trial == null) return const SizedBox.shrink();

        final currentPoints = system.getPoints(unit);
        final progress = (currentPoints / trial.requiredPoints).clamp(0.0, 1.0);
        final fieldLabels = FactionFieldLabels.forFaction(system.faction);

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: system.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: system.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(system.icon, color: system.color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      system.designationKeyword,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: system.color, letterSpacing: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(trial.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(trial.description, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('${system.pointsLabel}: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('$currentPoints / ${trial.requiredPoints}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: system.color)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.green : system.color,
                    ),
                    minHeight: 6,
                  ),
                ),
                if (unit.factionPoints2 > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${fieldLabels?.points2Label ?? 'Secondary Points'}: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('${unit.factionPoints2}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
                if (unit.factionPoints3 > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${fieldLabels?.points3Label ?? 'Tertiary Points'}: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('${unit.factionPoints3}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Badge shown for units that have ascended (completed faction progression)
class _AscendedBadge extends StatelessWidget {
  final FactionCrusadeSystem system;

  const _AscendedBadge({required this.system});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.yellow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.yellow.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(system.icon, color: Colors.yellow.shade300, size: 16),
                const SizedBox(width: 6),
                Text(
                  system.ascendedKeyword,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.yellow.shade300, letterSpacing: 1),
                ),
              ],
            ),
            if (system.ascendedAbilityText != null) ...[
              const SizedBox(height: 4),
              Text(
                system.ascendedAbilityText!,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modal content for Battle Honour selection for component units within groups (BUG-018 fix)
class _ComponentBattleHonourModalContent extends ConsumerStatefulWidget {
  final int groupIndex;
  final int componentIndex;
  final UnitOrGroup component;
  final ScrollController scrollController;
  final void Function(UnitOrGroup) updateCallback;

  const _ComponentBattleHonourModalContent({
    required this.groupIndex,
    required this.componentIndex,
    required this.component,
    required this.scrollController,
    required this.updateCallback,
  });

  @override
  ConsumerState<_ComponentBattleHonourModalContent> createState() => _ComponentBattleHonourModalContentState();
}

class _ComponentBattleHonourModalContentState extends ConsumerState<_ComponentBattleHonourModalContent> {
  String? _selectedHonourType;
  String? _selectedHonour;
  Map<String, dynamic>? _battleHonoursData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBattleHonoursData();
  }

  Future<void> _loadBattleHonoursData() async {
    final data = await loadBattleHonoursJsonData(context);
    if (mounted) {
      setState(() {
        _battleHonoursData = data;
        _isLoading = false;
      });
      if (data == null) {
        SnackBarUtils.showError(context, 'Failed to load Battle Honours data');
      }
    }
  }

  List<Map<String, dynamic>> _getHonourOptions() {
    if (_battleHonoursData == null || _selectedHonourType == null) return [];

    final typeData = _battleHonoursData![_selectedHonourType];
    if (typeData == null) return [];

    if (_selectedHonourType == 'crusadeRelics') {
      return List<Map<String, dynamic>>.from(typeData['relics'] ?? []);
    } else {
      return List<Map<String, dynamic>>.from(typeData['table'] ?? []);
    }
  }

  void _applyBattleHonour() {
    if (_selectedHonour == null) return;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Battle Honour'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unit: ${widget.component.customName ?? widget.component.name}'),
            const SizedBox(height: 4),
            const Text('(in group)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Honour Type: ${_getHonourTypeName()}'),
            const SizedBox(height: 4),
            Text(
              _selectedHonour!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _doApplyBattleHonour();
            },
            style: TextButton.styleFrom(foregroundColor: kAccentPink),
            child: const Text('Confirm'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getHonourTypeName() {
    switch (_selectedHonourType) {
      case 'battleTraits':
        return 'Battle Trait';
      case 'weaponEnhancements':
        return 'Weapon Enhancement';
      case 'crusadeRelics':
        return 'Crusade Relic';
      case 'psychicFortitudes':
        return 'Psychic Fortitude';
      default:
        return 'Unknown';
    }
  }

  void _doApplyBattleHonour() {
    final component = widget.component;

    // Create updated lists
    final updatedHonours = List<String>.from(component.honours);
    final updatedBattleTraits = List<String>.from(component.battleTraits);
    final updatedWeaponEnhancements = List<String>.from(component.weaponEnhancements);
    String? updatedCrusadeRelic = component.crusadeRelic;

    // Add to appropriate list based on honour type
    switch (_selectedHonourType) {
      case 'battleTraits':
        updatedBattleTraits.add(_selectedHonour!);
        updatedHonours.add('Trait: $_selectedHonour');
        break;
      case 'weaponEnhancements':
        updatedWeaponEnhancements.add(_selectedHonour!);
        updatedHonours.add('Weapon: $_selectedHonour');
        break;
      case 'crusadeRelics':
        updatedCrusadeRelic = _selectedHonour;
        updatedHonours.add('Relic: $_selectedHonour');
        break;
      case 'psychicFortitudes':
        updatedBattleTraits.add(_selectedHonour!);
        updatedHonours.add('Psychic: $_selectedHonour');
        break;
    }

    // Create updated component with all fields preserved
    final updatedComponent = UnitOrGroup(
      id: component.id,
      type: component.type,
      name: component.name,
      customName: component.customName,
      points: component.points,
      components: component.components,
      modelsCurrent: component.modelsCurrent,
      modelsMax: component.modelsMax,
      notes: component.notes,
      statsText: component.statsText,
      isWarlord: component.isWarlord,
      isEpicHero: component.isEpicHero,
      isCharacter: component.isCharacter,
      xp: component.xp,
      honours: updatedHonours,
      scars: component.scars,
      enhancements: component.enhancements,
      crusadePoints: component.crusadePoints + 1, // +1 CP for honour
      tallies: component.tallies,
      availableBattleHonours: component.availableBattleHonours - 1, // Debit one Battle Honour
      battleTraits: updatedBattleTraits,
      weaponEnhancements: updatedWeaponEnhancements,
      crusadeRelic: updatedCrusadeRelic,
    );

    // Use callback to update
    widget.updateCallback(updatedComponent);

    // Close modal
    Navigator.pop(context);
    SnackBarUtils.showSuccess(context, 'Battle Honour claimed!');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final component = widget.component;
    final isCharacter = component.isCharacter == true;
    final hasRelic = component.crusadeRelic != null;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Claim Battle Honour',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  component.customName ?? component.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${component.rank} • ${component.xp} XP (in group)',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Select Honour Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Battle Trait option
                _HonourTypeCard(
                  title: 'Battle Trait',
                  subtitle: 'Tactical ability from battle experience',
                  icon: Icons.shield,
                  color: Colors.blue,
                  isSelected: _selectedHonourType == 'battleTraits',
                  onTap: () => setState(() {
                    _selectedHonourType = 'battleTraits';
                    _selectedHonour = null;
                  }),
                ),

                // Weapon Enhancement option
                _HonourTypeCard(
                  title: 'Weapon Enhancement',
                  subtitle: 'Upgrade a weapon with special properties',
                  icon: Icons.gpp_good,
                  color: Colors.orange,
                  isSelected: _selectedHonourType == 'weaponEnhancements',
                  onTap: () => setState(() {
                    _selectedHonourType = 'weaponEnhancements';
                    _selectedHonour = null;
                  }),
                ),

                // Crusade Relic option (Characters only, limit 1)
                if (isCharacter && !hasRelic)
                  _HonourTypeCard(
                    title: 'Crusade Relic',
                    subtitle: 'Powerful artifact (Characters only, limit 1)',
                    icon: Icons.auto_awesome,
                    color: Colors.purple,
                    isSelected: _selectedHonourType == 'crusadeRelics',
                    onTap: () => setState(() {
                      _selectedHonourType = 'crusadeRelics';
                      _selectedHonour = null;
                    }),
                  ),

                // Honour selection
                if (_selectedHonourType != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    'Select ${_getHonourTypeName()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ..._getHonourOptions().map((option) {
                    final name = option['name'] as String? ?? 'Unknown';
                    final effect = option['effect'] as String? ?? '';
                    final isSelected = _selectedHonour == name;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected ? Colors.amber.withValues(alpha: 0.2) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? Colors.amber : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          effect,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected ? const Icon(Icons.check, color: Colors.amber) : null,
                        onTap: () => setState(() => _selectedHonour = name),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedHonour != null ? _applyBattleHonour : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Claim Honour'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted StatefulWidget for Edit Unit modal — fixes BUG-020.
/// Uses TextEditingControllers so text persists across MediaQuery rebuilds.
class _EditUnitModalContent extends StatefulWidget {
  final UnitOrGroup unit;
  final String title;
  final String? subtitle;
  final void Function(String? customName, String? notes) onSave;

  const _EditUnitModalContent({
    required this.unit,
    required this.title,
    required this.onSave,
    this.subtitle,
  });

  @override
  State<_EditUnitModalContent> createState() => _EditUnitModalContentState();
}

class _EditUnitModalContentState extends State<_EditUnitModalContent> {
  late final TextEditingController _customNameController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _customNameController = TextEditingController(text: widget.unit.customName ?? '');
    _notesController = TextEditingController(text: widget.unit.notes ?? '');
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (widget.subtitle != null)
            Text(widget.subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          TextField(
            controller: _customNameController,
            inputFormatters: nameFormatters,
            decoration: const InputDecoration(
              labelText: 'Custom Name',
              hintText: 'Leave empty to use default name',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            inputFormatters: notesFormatters,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Add any custom notes here',
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),

          Center(
            child: ElevatedButton(
              onPressed: () {
                final name = _customNameController.text.trim();
                final notes = _notesController.text.trim();
                widget.onSave(
                  name.isEmpty ? null : name,
                  notes.isEmpty ? null : notes,
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Extracted StatefulWidget for Add Unit modal — fixes BUG-020.
/// Form state is held in the State object so it persists when the modal
/// rebuilds due to MediaQuery/keyboard inset changes on Android.
class _AddUnitModalContent extends StatefulWidget {
  final Crusade? currentCrusade;
  final WidgetRef ref;

  const _AddUnitModalContent({
    required this.currentCrusade,
    required this.ref,
  });

  @override
  State<_AddUnitModalContent> createState() => _AddUnitModalContentState();
}

class _AddUnitModalContentState extends State<_AddUnitModalContent> {
  late String? selectedFaction;
  String? selectedUnit;
  int points = 0;
  int models = 1;
  bool isWarlord = false;
  int? selectedSizeIndex;
  bool addEnhancement = false;
  String? selectedEnhancementKey;
  final TextEditingController _customNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedFaction = widget.currentCrusade?.faction;
  }

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCrusade = widget.currentCrusade;
    final ref = widget.ref;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Unit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Faction dropdown
          DropdownButtonFormField<String>(
            initialValue: selectedFaction,
            decoration: const InputDecoration(labelText: 'Faction'),
            items: ReferenceDataService.getFactions().map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (value) async {
              if (value != null) {
                await ReferenceDataService.getUnits(value);
              }
              setState(() {
                selectedFaction = value;
                selectedUnit = null;
                selectedSizeIndex = null;
              });
            },
          ),
          const SizedBox(height: 16),

          if (selectedFaction != null)
            DropdownButtonFormField<String>(
              initialValue: selectedUnit,
              decoration: const InputDecoration(labelText: 'Unit Name'),
              items: ReferenceDataService.getUnitsSync(selectedFaction!).map((unitData) {
                final unitName = (unitData as Map<String, dynamic>)['name'] as String? ?? 'Unknown Unit';
                return DropdownMenuItem<String>(
                  value: unitName,
                  child: Text(unitName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUnit = value;
                  if (value != null && selectedFaction != null) {
                    final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, value);
                    final sizeOptions = unitData['sizeOptions'] as List? ?? [];
                    final pointsOptions = unitData['pointsOptions'] as List? ?? [];
                    if (sizeOptions.isNotEmpty) {
                      selectedSizeIndex = 0;
                      final sizeValue = sizeOptions[0];
                      models = (sizeValue is int) ? sizeValue : int.tryParse(sizeValue.toString()) ?? 1;
                      if (pointsOptions.isNotEmpty) {
                        final pointsValue = pointsOptions[0];
                        points = (pointsValue is int) ? pointsValue : int.tryParse(pointsValue.toString()) ?? 0;
                      }
                    } else {
                      selectedSizeIndex = null;
                    }
                  } else {
                    selectedSizeIndex = null;
                  }
                });
              },
            ),
          const SizedBox(height: 16),

          // Size variant dropdown
          if (selectedUnit != null)
            DropdownButtonFormField<int>(
              initialValue: selectedSizeIndex,
              decoration: const InputDecoration(labelText: 'Size'),
              items: () {
                final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                final sizeOptions = unitData['sizeOptions'] as List? ?? [];
                final pointsOptions = unitData['pointsOptions'] as List? ?? [];
                return sizeOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sizeValue = entry.value;
                  final size = (sizeValue is int) ? sizeValue : int.tryParse(sizeValue.toString()) ?? 0;
                  final pointsValue = pointsOptions.isNotEmpty && index < pointsOptions.length ? pointsOptions[index] : 0;
                  final pointsOption = (pointsValue is int) ? pointsValue : int.tryParse(pointsValue.toString()) ?? 0;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text('$size models - $pointsOption pts'),
                  );
                }).toList();
              }(),
              onChanged: (value) {
                setState(() {
                  selectedSizeIndex = value;
                  if (value != null) {
                    final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                    final sizeOptions = unitData['sizeOptions'] as List? ?? [];
                    final pointsOptions = unitData['pointsOptions'] as List? ?? [];
                    if (value < sizeOptions.length) {
                      final sizeValue = sizeOptions[value];
                      models = (sizeValue is int) ? sizeValue : int.tryParse(sizeValue.toString()) ?? 1;
                    }
                    if (value < pointsOptions.length) {
                      final pointsValue = pointsOptions[value];
                      points = (pointsValue is int) ? pointsValue : int.tryParse(pointsValue.toString()) ?? 0;
                    }
                  }
                });
              },
            ),
          const SizedBox(height: 16),

          // Custom name — uses TextEditingController so text persists across rebuilds
          TextField(
            controller: _customNameController,
            inputFormatters: nameFormatters,
            decoration: const InputDecoration(labelText: 'Custom Name (optional)'),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),

          // Warlord toggle
          if (selectedUnit != null && selectedFaction != null && currentCrusade != null)
            Builder(
              builder: (context) {
                final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                final role = unitData['role'] as String? ?? '';
                final isEpicHeroUnit = unitData['isEpicHero'] as bool? ?? false;

                bool hasExistingWarlord = false;
                for (final item in currentCrusade.oob) {
                  if (item.isWarlord == true) {
                    hasExistingWarlord = true;
                    break;
                  }
                  if (item.type == 'group' && item.components != null) {
                    for (final component in item.components!) {
                      if (component.isWarlord == true) {
                        hasExistingWarlord = true;
                        break;
                      }
                    }
                  }
                  if (hasExistingWarlord) break;
                }

                if (role == 'HQ' && !isEpicHeroUnit && !hasExistingWarlord) {
                  return SwitchListTile(
                    title: const Text('Designate as Warlord'),
                    value: isWarlord,
                    onChanged: (value) => setState(() => isWarlord = value),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // First Character Enhancement option (Renowned Heroes requisition)
          if (selectedUnit != null && selectedFaction != null && currentCrusade != null)
            Builder(
              builder: (context) {
                final crusade = currentCrusade;
                final faction = selectedFaction!;
                final unit = selectedUnit!;
                final unitData = ReferenceDataService.getUnitDataSync(faction, unit);
                final isEpicHeroUnit = unitData['isEpicHero'] as bool? ?? false;
                final isCharacterUnit = unitData['isCharacter'] as bool? ?? false;

                final canUseFirstCharacterEnhancement =
                    isCharacterUnit &&
                    !isEpicHeroUnit &&
                    !crusade.usedFirstCharacterEnhancement &&
                    crusade.rp >= 1;

                if (!canUseFirstCharacterEnhancement) {
                  return const SizedBox.shrink();
                }

                final detachmentEnhancements = ReferenceDataService.getEnhancements(
                  crusade.faction,
                  crusade.detachment,
                );
                if (detachmentEnhancements.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Add Enhancement (Renowned Heroes)'),
                      subtitle: Text(
                        'First character bonus! Costs 1 RP (${crusade.rp} available)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: addEnhancement,
                      onChanged: (value) => setState(() {
                        addEnhancement = value;
                        if (!value) selectedEnhancementKey = null;
                      }),
                    ),
                    if (addEnhancement)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Enhancement',
                            border: OutlineInputBorder(),
                          ),
                          items: detachmentEnhancements.map((enh) {
                            final name = enh['name'] as String;
                            final points = enh['points'] as int;
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                '$name (+$points pts)',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => selectedEnhancementKey = value),
                        ),
                      ),
                  ],
                );
              },
            ),

          const SizedBox(height: 32),

          // Add button
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (selectedUnit == null || points <= 0) {
                  SnackBarUtils.showError(context, 'Select unit and enter points');
                  return;
                }

                if (addEnhancement && selectedEnhancementKey == null) {
                  SnackBarUtils.showError(context, 'Select an enhancement or disable the option');
                  return;
                }

                final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                final isEpicHero = unitData['isEpicHero'] as bool? ?? false;
                final isCharacter = unitData['isCharacter'] as bool? ?? false;

                final customName = _customNameController.text;

                int enhancementPoints = 0;
                String? enhancementName;
                if (addEnhancement && selectedEnhancementKey != null && currentCrusade != null) {
                  final enhancements = ReferenceDataService.getEnhancements(
                    currentCrusade.faction,
                    currentCrusade.detachment,
                  );
                  for (final enh in enhancements) {
                    if (enh['name'] == selectedEnhancementKey) {
                      enhancementPoints = enh['points'] as int;
                      enhancementName = selectedEnhancementKey;
                      break;
                    }
                  }
                }

                final newUnit = UnitOrGroup(
                  id: const Uuid().v4(),
                  type: 'unit',
                  name: selectedUnit!,
                  customName: customName.isNotEmpty ? customName : null,
                  points: points + enhancementPoints,
                  modelsCurrent: models,
                  modelsMax: models,
                  isWarlord: isWarlord,
                  isEpicHero: isEpicHero,
                  isCharacter: isCharacter,
                  enhancements: enhancementName != null ? [enhancementName] : null,
                );

                if (addEnhancement && currentCrusade != null) {
                  final unitAddedEvent = CrusadeEvent.create(
                    type: CrusadeEventType.unitAdded,
                    description: 'Added ${newUnit.customName ?? newUnit.name} to Order of Battle',
                    unitId: newUnit.id,
                    unitName: newUnit.customName ?? newUnit.name,
                    metadata: {'points': newUnit.points - enhancementPoints},
                  );

                  final enhancementEvent = CrusadeEvent.create(
                    type: CrusadeEventType.requisition,
                    description: 'Renowned Heroes: Added $enhancementName to ${newUnit.customName ?? newUnit.name}',
                    unitId: newUnit.id,
                    unitName: newUnit.customName ?? newUnit.name,
                    metadata: {
                      'requisition': 'Renowned Heroes',
                      'enhancement': enhancementName,
                      'enhancementPoints': enhancementPoints,
                      'rpCost': 1,
                      'firstCharacter': true,
                    },
                  );

                  final updatedCrusade = Crusade(
                    id: currentCrusade.id,
                    name: currentCrusade.name,
                    faction: currentCrusade.faction,
                    detachment: currentCrusade.detachment,
                    supplyLimit: currentCrusade.supplyLimit,
                    rp: currentCrusade.rp - 1,
                    armyIconPath: currentCrusade.armyIconPath,
                    factionIconAsset: currentCrusade.factionIconAsset,
                    oob: [...currentCrusade.oob, newUnit],
                    templates: currentCrusade.templates,
                    usedFirstCharacterEnhancement: true,
                    history: [...currentCrusade.history, unitAddedEvent, enhancementEvent],
                    rosters: currentCrusade.rosters,
                    games: currentCrusade.games,
                  );
                  ref.read(currentCrusadeNotifierProvider.notifier).setCurrent(updatedCrusade);

                  Navigator.pop(context);
                  SnackBarUtils.showSuccess(
                    context,
                    'Added ${newUnit.customName ?? newUnit.name} with $enhancementName enhancement!',
                  );
                } else {
                  ref.read(currentCrusadeNotifierProvider.notifier).addUnitOrGroup(newUnit);
                  ref.read(currentCrusadeNotifierProvider.notifier).addEvent(CrusadeEvent.create(
                    type: CrusadeEventType.unitAdded,
                    description: 'Added ${newUnit.customName ?? newUnit.name} (${newUnit.points} pts)',
                    unitId: newUnit.id,
                    unitName: newUnit.customName ?? newUnit.name,
                    metadata: {
                      'points': newUnit.points,
                      'unitType': newUnit.type,
                    },
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text(addEnhancement ? 'Add (1 RP)' : 'Add'),
            ),
          ),
        ],
      ),
    );
  }
}