import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/crusade_models.dart';
import '../services/reference_data_service.dart';
import '../widgets/army_avatar.dart';
import '../providers/crusade_provider.dart';
import '../utils/snackbar_utils.dart';

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
          // Points summary banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: currentCrusade.remainingPoints < 0
                      ? Colors.red
                      : Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Supply Used / Limit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Supply',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.totalOobPoints}/${currentCrusade.supplyLimit}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentCrusade.remainingPoints < 0
                            ? Colors.red
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
                // Remaining Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.remainingPoints}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentCrusade.remainingPoints < 0
                            ? Colors.red
                            : const Color(0xFFFFB6C1),
                      ),
                    ),
                  ],
                ),
                // Total CP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Total CP',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.totalCrusadePoints}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF90CAF9),
                      ),
                    ),
                  ],
                ),
                // Available RP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'RP',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.rp}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFF59D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

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
                  for (final component in item.components!) {
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
                            _DetailRow(label: 'Experience', value: '${component.xp} XP'),
                            _DetailRow(label: 'Models', value: '${component.modelsCurrent}/${component.modelsMax}'),
                            _DetailRow(label: 'Crusade Points', value: '${component.crusadePoints}'),
                            if (component.tallies['played'] != null)
                              _DetailRow(label: 'Battles Played', value: '${component.tallies['played']}'),
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
                          ],
                        ),
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
                              if (component.pendingRankUp) ...[
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
                          if (item.pendingRankUp)
                            _HighlightedXPRow(xp: item.xp, rank: item.rank)
                          else
                            _DetailRow(label: 'Experience', value: '${item.xp} XP'),
                          _DetailRow(label: 'Models', value: '${item.modelsCurrent}/${item.modelsMax}'),
                          _DetailRow(label: 'Crusade Points', value: '${item.crusadePoints}'),
                          if (item.tallies['played'] != null)
                            _DetailRow(label: 'Battles Played', value: '${item.tallies['played']}'),
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
                        ],
                      ),
                    ),
                  );
                  expansionChildren.add(const Divider());
                }

                // Add Claim Battle Honour button if unit has pending rank up
                if (item.type != 'group' && item.pendingRankUp) {
                  expansionChildren.add(
                    ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.amber),
                      title: const Text('Claim Battle Honour', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
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
                        if (item.type != 'group' && item.pendingRankUp) ...[
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String groupName = '';
        final selectedUnitIds = <String>{};

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filter out only units (not groups) for selection
            final availableUnits = currentCrusade.oob.where((item) => item.type == 'unit').toList();

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
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g., Sailor Venus Squad',
                    ),
                    onChanged: (value) => groupName = value,
                  ),
                  const SizedBox(height: 16),

                  const Text('Select Units to Add:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),

                  if (availableUnits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No units available. Add some units first!'),
                    )
                  else
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
                        if (groupName.trim().isEmpty) {
                          SnackBarUtils.showError(context, 'Enter a group name');
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
      builder: (context) {
        String? selectedFaction = crusadeFaction; // Pre-populate with crusade faction
        String? selectedUnit;
        int points = 0;
        int models = 1;
        String customName = '';
        bool isWarlord = false;
        int? selectedSizeIndex;
        bool addEnhancement = false; // For first character enhancement option
        String? selectedEnhancementKey; // Use string key instead of Map for dropdown value

      return StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                    // Preload units for this faction
                    await ReferenceDataService.getUnits(value);
                  }
                  setModalState(() {
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
                    setModalState(() {
                      selectedUnit = value;
                      // Pre-select the smallest unit size (first option)
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
                    setModalState(() {
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

              // Custom name
              TextField(
                decoration: const InputDecoration(labelText: 'Custom Name (optional)'),
                onChanged: (value) => customName = value,
              ),
              const SizedBox(height: 16),

              // Warlord toggle (show only for HQ units that are NOT Epic Heroes, and only if no warlord exists)
              if (selectedUnit != null && selectedFaction != null && currentCrusade != null)
                Builder(
                  builder: (context) {
                    final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                    final role = unitData['role'] as String? ?? '';
                    final isEpicHeroUnit = unitData['isEpicHero'] as bool? ?? false;

                    // Check if there's already a warlord in the OOB (including in groups)
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

                    // Only show toggle if: HQ role, not Epic Hero, and no existing warlord
                    if (role == 'HQ' && !isEpicHeroUnit && !hasExistingWarlord) {
                      return SwitchListTile(
                        title: const Text('Designate as Warlord'),
                        value: isWarlord,
                        onChanged: (value) => setModalState(() => isWarlord = value),
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

                    // Check if eligible for first character enhancement
                    final canUseFirstCharacterEnhancement =
                        isCharacterUnit &&
                        !isEpicHeroUnit &&
                        !crusade.usedFirstCharacterEnhancement &&
                        crusade.rp >= 1;

                    if (!canUseFirstCharacterEnhancement) {
                      return const SizedBox.shrink();
                    }

                    // Get enhancements for the crusade's detachment only
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
                          onChanged: (value) => setModalState(() {
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
                              onChanged: (value) => setModalState(() => selectedEnhancementKey = value),
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

                    // Validate enhancement selection if enabled
                    if (addEnhancement && selectedEnhancementKey == null) {
                      SnackBarUtils.showError(context, 'Select an enhancement or disable the option');
                      return;
                    }

                    // Get unit data to check for Epic Hero and Character flags
                    final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                    final isEpicHero = unitData['isEpicHero'] as bool? ?? false;
                    final isCharacter = unitData['isCharacter'] as bool? ?? false;

                    // Look up enhancement points if selected
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

                    // Add unit and update crusade state if enhancement was used
                    if (addEnhancement && currentCrusade != null) {
                      // Create history events for the addition and enhancement
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

                      // Create updated crusade with enhancement flag, RP deduction, and history
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
                      Navigator.pop(context);
                    }
                  },
                  child: Text(addEnhancement ? 'Add (1 RP)' : 'Add'),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  void _editUnit(BuildContext context, WidgetRef ref, int index, UnitOrGroup unit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String customName = unit.customName ?? '';
        String notes = unit.notes ?? '';

        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
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
                Text('Edit Unit: ${unit.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Custom Name',
                    hintText: 'Leave empty to use default name',
                  ),
                  controller: TextEditingController(text: customName),
                  onChanged: (value) => customName = value,
                ),
                const SizedBox(height: 16),

                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add any custom notes here',
                  ),
                  controller: TextEditingController(text: notes),
                  maxLines: 3,
                  onChanged: (value) => notes = value,
                ),
                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedUnit = UnitOrGroup(
                        id: unit.id,
                        type: unit.type,
                        name: unit.name,
                        customName: customName.trim().isEmpty ? null : customName.trim(),
                        points: unit.points,
                        modelsCurrent: unit.modelsCurrent,
                        modelsMax: unit.modelsMax,
                        notes: notes.trim().isEmpty ? null : notes.trim(),
                        isWarlord: unit.isWarlord,
                        isEpicHero: unit.isEpicHero,
                      );

                      ref.read(currentCrusadeNotifierProvider.notifier).updateUnitOrGroup(index, updatedUnit);
                      Navigator.pop(context);

                      SnackBarUtils.showSuccess(context, 'Unit updated!');
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFF59D)),
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
    try {
      final jsonString = await DefaultAssetBundle.of(context).loadString('assets/data/battle_honours.json');
      final data = await Future.value(jsonString).then((s) {
        return Map<String, dynamic>.from(
          (const JsonDecoder().convert(s)) as Map,
        );
      });
      if (mounted) {
        setState(() {
          _battleHonoursData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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

    // Clear pending rank up flag
    updatedUnit.pendingRankUp = false;

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

// Helper widget for displaying detail rows in unit expansion
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
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