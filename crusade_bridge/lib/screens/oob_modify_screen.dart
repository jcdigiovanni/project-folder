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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supply Limit',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.totalOobPoints} / ${currentCrusade.supplyLimit} pts',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${currentCrusade.remainingPoints} pts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentCrusade.remainingPoints < 0
                            ? Colors.red
                            : const Color(0xFFFFB6C1),
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
                    expansionChildren.add(
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0), // Indent for hierarchy
                        child: ListTile(
                          leading: component.isWarlord == true
                              ? const Icon(Icons.star, color: Colors.yellow, size: 18)
                              : const Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.grey),
                          title: Text(
                            component.customName != null
                                ? '${component.customName} (${component.name})'
                                : component.name,
                            style: const TextStyle(fontSize: 14), // Smaller text for nested items
                          ),
                          subtitle: Text(
                            '${component.rank} • ${component.xp} XP • ${component.points} pts • ${component.modelsCurrent}/${component.modelsMax} models',
                            style: const TextStyle(fontSize: 12), // Even smaller for subtitle
                          ),
                          dense: true, // More compact display
                        ),
                      ),
                    );
                  }
                  expansionChildren.add(const Divider());
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
                      ref.read(currentCrusadeNotifierProvider.notifier).removeUnitOrGroup(index);
                    },
                  ),
                );

                return ExpansionTile(
                  leading: leadingIcon,
                  title: Text(
                    item.customName != null
                        ? '${item.customName} (${item.name})'
                        : item.name
                  ),
                  subtitle: Text(
                    item.type == 'group'
                        ? '${item.points} pts • ${item.components?.length ?? 0} units • ${item.modelsCurrent}/${item.modelsMax} models'
                        : '${item.rank} • ${item.xp} XP • ${item.points} pts • ${item.modelsCurrent}/${item.modelsMax} models'
                  ),
                  children: expansionChildren,
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
                  const Text('Create Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  void _addUnit(BuildContext context, WidgetRef ref) {
    final currentCrusade = ref.read(currentCrusadeNotifierProvider);
    final crusadeFaction = currentCrusade?.faction;

    // Preload units for the crusade's faction
    if (crusadeFaction != null) {
      ReferenceDataService.getUnits(crusadeFaction);
    }

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
              const Text('Add Unit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      selectedSizeIndex = null;
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

              // Warlord toggle (show only for HQ units that are NOT Epic Heroes)
              if (selectedUnit != null && selectedFaction != null)
                Builder(
                  builder: (context) {
                    final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                    final role = unitData['role'] as String? ?? '';
                    final isEpicHeroUnit = unitData['isEpicHero'] as bool? ?? false;

                    if (role == 'HQ' && !isEpicHeroUnit) {
                      return SwitchListTile(
                        title: const Text('Designate as Warlord'),
                        value: isWarlord,
                        onChanged: (value) => setModalState(() => isWarlord = value),
                      );
                    }
                    return const SizedBox.shrink();
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

                    // Get unit data to check for Epic Hero flag
                    final unitData = ReferenceDataService.getUnitDataSync(selectedFaction!, selectedUnit!);
                    final isEpicHero = unitData['isEpicHero'] as bool? ?? false;

                    final newUnit = UnitOrGroup(
                      id: const Uuid().v4(),
                      type: 'unit',
                      name: selectedUnit!,
                      customName: customName.isNotEmpty ? customName : null,
                      points: points,
                      modelsCurrent: models,
                      modelsMax: models,
                      isWarlord: isWarlord,
                      isEpicHero: isEpicHero,
                    );

                    ref.read(currentCrusadeNotifierProvider.notifier).addUnitOrGroup(newUnit);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
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
                  const Text('Edit Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
}